## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# nolint start: commented_code_linter.
## Hill & Weir (2011) universal integration function, closed form (their
## eqn 4b): phi_0(l) = 0; for n >= 1, phi_n(l) is
## 1/(2*l^2) * (1/4)^n * the sum over r = 1..n of choose(n,r) times
## (2*r*l - 1 + exp(-2*r*l)) / r^2.
## l is a single chromosome's genetic map length in Morgans; n indexes the
## specific relationship-variance combination (see .hillWeirVarianceR()).
## Internal only -- not exported.
# nolint end: commented_code_linter.
.hillWeirPhi <- function(l, n) {
  if (n == 0L) {
    return(0L)
  }
  r <- seq_len(n)
  s <- sum(choose(n, r) * (2L * r * l - 1L + exp(-2L * r * l)) / r^2L)
  (1L / (2L * l^2L)) * (1L / 4L)^n * s
}

## Variance of actual (realized) relationship R-breve around its
## pedigree-expected value R = 2*kinship, for a single equal-length
## chromosome of length l, combined across nChr equal-length chromosomes as
## Var/nChr (the equal-length approximation to Hill & Weir's eqn 5,
## verified this session against their Table 2 -- see
## tests/testthat/test_markerRealizedRelatednessVariance.R header).
## Returns NA_real_ for any relation category outside the three this slice
## covers (D3a): Parent-Offspring, Full-Siblings, Half-Siblings. Internal
## only -- not exported.
.hillWeirVarianceR <- function(relation, l, nChr) {
  single <- switch(relation,
    "Parent-Offspring" = .hillWeirPhi(l, 0L),
    "Full-Siblings" = 2L * .hillWeirPhi(l, 2L) - .hillWeirPhi(l, 1L),
    "Half-Siblings" = .hillWeirPhi(l, 2L) - 0.5 * .hillWeirPhi(l, 1L),
    NA_real_
  )
  if (is.na(single)) {
    return(NA_real_)
  }
  single / nChr
}

#' Estimate the variance of realized relatedness around pedigree kinship
#'
#' Pedigree-expected relatedness (this package's existing \code{\link{kinship}}
#' output, doubled) is only an average -- the \emph{actual} proportion of
#' genome shared identical-by-descent (IBD) between two relatives varies
#' around that expectation because of Mendelian sampling and linkage (finite
#' chromosome number/map length creates covariance in IBD status among
#' nearby loci). This function estimates that variance for
#' Parent-Offspring, Full-Siblings, and Half-Siblings pairs (issue #153,
#' D3a) -- the closed-form solution of Hill & Weir (2011), extending the
#' pedigree kinship this package already computes rather than requiring a
#' new population-genetics framework. Every other pedigree-relationship
#' category (grandparent, cousin, avuncular, more distant, unrelated, self)
#' returns \code{NA} for the variance, not an error -- a pedigree-wide call
#' will legitimately include many such pairs as a matter of course.
#'
#' @details
#' Relationship pairs are classified from the pedigree structure via the
#' existing \code{\link{convertRelationships}} (not re-derived). The
#' variance combines \code{nChr} chromosomes, each approximated as the
#' average length \code{mapLength / nChr} -- Hill & Weir (2011) give an
#' exact weighted-sum combination rule (their equation 5) only for lineal
#' descendants; for Full-Sib/Half-Sib pairs they state in prose that this
#' equal-length approximation closely matches a real heterogeneous-length
#' genome, which this package's own PRE-RED research verified numerically
#' against their published human-genome Table 2 (within ~2%; see the test
#' file header for the full derivation).
#'
#' @param kmat square kinship matrix, as produced by \code{\link{kinship}}.
#' @param ped dataframe with (at least) \code{id}, \code{sire}, and
#' \code{dam} columns, as used by \code{\link{convertRelationships}}.
#' @param nChr chromosome count (e.g. autosome count for the species), meant
#' to be a whole number. Only a single positive numeric value is enforced, so
#' a non-integer such as \code{20.5} is accepted.
#' @param mapLength numeric; total autosomal genetic map length in Morgans.
#' Must be a single positive value.
#' @param ids character vector of IDs or \code{NULL} to which the analysis
#' should be restricted, as in \code{\link{convertRelationships}}.
#'
#' @return A dataframe with columns \code{id1}, \code{id2}, \code{kinship},
#' \code{relation}, \code{R} (pedigree relationship, \code{2 * kinship}),
#' \code{varR} (the realized-relatedness variance estimate), and
#' \code{sdR} (its square root). \code{varR}/\code{sdR} are \code{NA} for
#' every \code{relation} other than \code{"Parent-Offspring"},
#' \code{"Full-Siblings"}, or \code{"Half-Siblings"}.
#'
#' @references Hill WG, Weir BS. 2011. Variation in actual relationship as
#' a consequence of Mendelian sampling and linkage. Genetics Research
#' 93(1):47-64.
#'
#' @seealso \code{\link{kinship}}, \code{\link{convertRelationships}}
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::smallPed
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
#' ## Rhesus macaque autosome count/map length are used only as an example
#' ## scale -- callers should supply values appropriate to their own species.
#' markerRealizedRelatednessVariance(kmat, ped, nChr = 20L, mapLength = 28)
markerRealizedRelatednessVariance <- function(kmat, ped, nChr, mapLength,
                                               ids = NULL) {
  if (is.null(ped) || !is.data.frame(ped) ||
    !all(c("id", "sire", "dam") %in% names(ped))) {
    stop("markerRealizedRelatednessVariance() requires a pedigree data ",
         "frame with 'id', 'sire', and 'dam' columns.")
  }
  if (!is.numeric(nChr) || length(nChr) != 1L || is.na(nChr) || nChr <= 0L) {
    stop("nChr must be a single positive integer (chromosome count).")
  }
  if (!is.numeric(mapLength) || length(mapLength) != 1L || is.na(mapLength) ||
    mapLength <= 0L) {
    stop("mapLength must be a single positive number (total genetic map ",
         "length in Morgans).")
  }

  if (!is.null(ids)) {
    kmat <- filterKinMatrix(ids, kmat)
  }
  ## Only these three kinds get a variance, so only their pairs are listed
  ## (owner ruling S1082); on the example that is 13,286 of 6,824,665 pairs.
  kinds <- c("Parent-Offspring", "Full-Siblings", "Half-Siblings")
  rel <- varianceKindPairs(kmat, ped, kinds)
  l <- mapLength / nChr
  variance <- vapply(kinds, .hillWeirVarianceR, numeric(1L), l = l,
                     nChr = nChr)

  rel$R <- 2L * rel$kinship
  rel$varR <- unname(variance[match(rel$relation, kinds)])
  rel$sdR <- sqrt(rel$varR)
  rel[c("id1", "id2", "kinship", "relation", "R", "varR", "sdR")]
}

## The rows of convertRelationships(kmat, ped) whose relation is one of
## `kinds` (Parent-Offspring, Full-Siblings, Half-Siblings), in the same order,
## without the table of every pair: only an animal with each of its parents,
## and two animals sharing a parent (by name, as sire or dam), can be of those
## kinds, and those pairs are named by convertRelationships()' own rules. A
## matrix or pedigree this build is not made for (no cells, not a double matrix
## with the same row and column names, an id not in the pedigree, a pedigree
## relationsPlan() refuses) runs convertRelationships() itself. Internal only.
varianceKindPairs <- function(kmat, ped, kinds) {
  ids <- rownames(kmat)
  fits <- length(kmat) > 0L && longFormFits(kmat, removeDups = TRUE) &&
    identical(ids, colnames(kmat)) && all(ids %in% ped$id)
  plan <- NULL
  if (fits) {
    child <- match(rep(ped$id, 2L), ids)
    parentName <- c(ped$sire, ped$dam)
    known <- !is.na(child) & !is.na(parentName)
    families <- lapply(split(child[known], parentName[known]), unique)
    siblings <- lapply(families[lengths(families) > 1L], utils::combn, 2L)
    a <- c(child, unlist(lapply(siblings, function(pairs) pairs[1L, ])))
    b <- c(match(parentName, ids),
           unlist(lapply(siblings, function(pairs) pairs[2L, ])))
    keep <- !is.na(a) & !is.na(b) & a != b
    ## A pair's cell in the lower triangle, as kinMatrix2LongForm(removeDups =
    ## TRUE) lists it: the earlier animal's column, the later animal's row.
    cells <- sort(unique((pmin(a[keep], b[keep]) - 1L) * length(ids) +
                           pmax(a[keep], b[keep])))
    cells <- cells[!is.na(kmat[cells])]
    kin <- longFormRows(kmat, cells, cells)
    plan <- relationsPlan(kin, ped)
  }
  if (is.null(plan)) {
    rel <- convertRelationships(kmat, ped)
    return(rel[rel$relation %in% kinds, ])
  }
  ruleOrder <- c(
    "self", "fullSiblings", "parentOffspring", "halfSiblings",
    "grandparentGrandchild", "fullCousins", "cousinOther", "fullAvuncular",
    "avuncularOther", "other", "noRelation"
  )
  outside <- length(plan$id) + 1L
  classes <- relationClasses(
    match(kin$id1, plan$id, nomatch = outside),
    match(kin$id2, plan$id, nomatch = outside),
    kin$kinship, kin$id1 == kin$id2, plan
  )
  kin["relation"] <- unname(relationClassNames[ruleOrder])[classes]
  kin[kin$relation %in% kinds, ]
}
