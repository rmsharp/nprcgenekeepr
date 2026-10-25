## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Calculate founder equivalents and founder genome equivalents
#'
#' Part of the Genetic Value Analysis
#'
#' @param ped the pedigree information in datatable format.  Pedigree
#' (req. fields: id, sire, dam, gen, population).
#'
#' The pedigree must have no partial parentage (every animal has both parents
#' known or both unknown); \code{calcFEFG} stops with an error otherwise.
#'
#' Every animal with both parents unknown is treated as a separate, unrelated
#' founder, including an animal whose id was generated to stand in for an
#' unknown parent. Such a placeholder may in fact be a known founder, another
#' animal in the population, or an animal outside it, so the unrelated-founder
#' assumption can overstate \code{FE} and \code{FG} when placeholders are
#' common. \code{\link{reportGV}} lists only the \emph{known} founders, so its
#' founder counts can be smaller than the founder set used here.
#' @param alleles dataframe contains an \code{AlleleTable}. This is a
#' table of allele information produced by \code{geneDrop()}.
#' @return The list containing the founder equivalents,
#' \code{FE = 1 / sum(p ^ 2)}, and the founder genome equivalents,
#' \code{FG = 1 / sum( (p ^ 2) / r)} where \code{p} is the vector of founder
#' mean contributions to the current descendants and \code{r} is the mean
#' number of founder alleles retained in the gene dropping experiment.
#'
#' \code{FE} is deterministic and always returned. \code{FG} is \code{NA}
#' (with a warning) when a contributing founder (\code{p > 0}) is retained
#' in zero of the gene-drop iterations (\code{r == 0}), which would
#' otherwise collapse \code{FG} silently to 0; raise the number of
#' iterations. See \code{\link{calcFGSE}} for the sampling standard error
#' of \code{FG}.
#'
#' @references Lacy RC. 1989. Analysis of founder representation in
#' pedigrees: founder equivalents and founder genome equivalents. Zoo Biol
#' 8:111-123.
#' @family genetic value analysis
#' @export
#' @examples
#' data(lacy1989Ped)
#' ## Example from Analysis of Founder Representation in Pedigrees: Founder
#' ## Equivalents and Founder Genome Equivalents.
#' ## Zoo Biology 8:111-123, (1989) by Robert C. Lacy
#'
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' alleles <- lacy1989PedAlleles
#' pedFactors <- data.frame(
#'   id = as.factor(ped$id),
#'   sire = as.factor(ped$sire),
#'   dam = as.factor(ped$dam),
#'   gen = ped$gen,
#'   population = ped$population,
#'   stringsAsFactors = TRUE
#' )
#' allelesFactors <- geneDrop(pedFactors$id, pedFactors$sire, pedFactors$dam,
#'   pedFactors$gen,
#'   genotype = NULL, n = 1000,
#'   updateProgress = NULL
#' )
#' feFg <- calcFEFG(ped, alleles)
#' feFgFactors <- calcFEFG(pedFactors, allelesFactors)
calcFEFG <- function(ped, alleles) {
  ## Founder-contribution algorithm + partial-parentage guard are shared with
  ## calcFE()/calcFG() via calcFounderContributions() (NEW-13/NEW-23). fc$ped is
  ## the toCharacter()-coerced pedigree, fed to calcRetention() exactly as the
  ## pre-refactor code did.
  fc <- calcFounderContributions(ped, "calcFEFG") # nolint: object_usage_linter
  r <- calcRetention(fc$ped, alleles)
  feFgFromRetention(fc$p, r)
}

#' FE and FG from founder contributions and retention
#'
#' The arithmetic of \code{calcFEFG()} and \code{calcFG()}, and of
#' \code{reportGV()} through \code{founderStatistics()}: \code{FE = 1 /
#' sum(p^2)} and \code{FG = 1 / sum(p^2 / r)}.
#'
#' @param p founder mean contributions, named by founder, as
#' \code{calcFounderContributions()} returns them.
#' @param r each founder's mean retention, as \code{calcRetention()} returns
#' it.
#' @return A list: \code{FE}, and \code{FG}, which is \code{NA} (with a
#' warning) when a contributing founder is retained in zero iterations.
#' @noRd
feFgFromRetention <- function(p, r) {
  ## Align retention to contributions by NAME before dividing (issue #86,
  ## Dragon D-3): r is id-sorted (tapply) while p is in getFounders()
  ## pedigree-row order, so a positional p^2 / r pairs the wrong founders -- a
  ## silently wrong FG (e.g. a collapse to 0) on any pedigree whose founders
  ## are not already in sorted id order. FE (1 / sum(p^2)) has no retention
  ## term and is unaffected by the ordering.
  r <- r[names(p)]
  fe <- 1L / sum(p^2L)
  ## FE is deterministic and always returned; FG hard-fails (NA + warning)
  ## on the zero-retention silent collapse.
  if (checkFgDegeneracy(p, r)) {
    return(list(FE = fe, FG = NA_real_))
  }
  list(FE = fe, FG = 1L / sum((p^2L) / r, na.rm = TRUE))
}
