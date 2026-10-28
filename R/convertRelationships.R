## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convert pairwise kinship values to relationship categories
#'
#' Part of Relations
#'
#' @inheritParams meanKinship
#' @inheritParams getDescendantPedigree
#' @param ids character vector of IDs or NULL to which the analysis should be
#' restricted. If provided, only relationships between these IDs will be
#' converted to relationships.
#' @param updateProgress function or NULL. If this function is defined, it
#' will be called during each iteration to update a
#' \code{shiny::Progress} object.
#' @return A dataframe with columns \code{id1}, \code{id2}, \code{kinship},
#' \code{relation}. It is a long-form table of pairwise kinships, with
#' relationship categories included for each pair. IDs that are not in
#' \code{kmat} are ignored. One ID gives that animal's own \code{Self} row, and
#' no ID in \code{kmat} (or an empty \code{ids}) gives a table with no rows.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::smallPed
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
#' ids <- c("A", "B", "D", "E", "F", "G", "I", "J", "L", "M", "O", "P")
#' relIds <- convertRelationships(kmat, ped, ids)
#' rel <- convertRelationships(kmat, ped, updateProgress = function() {})
#' head(rel)
#' ped <- nprcgenekeepr::qcPed
#' bkmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen,
#'   sparse = FALSE
#' )
#' relBIds <- convertRelationships(bkmat, ped, c("4LFS70", "DD1U77"))
#' relBIds
convertRelationships <- function(kmat, ped, ids = NULL, updateProgress = NULL) {
  if (!is.null(ids)) {
    kmat <- filterKinMatrix(ids, kmat)
  }
  # No id of `ids` is in `kmat`: a matrix with no cells has no pairs to name.
  if (length(kmat) == 0L) {
    return(data.frame(
      id1 = character(0L), id2 = character(0L), kinship = numeric(0L),
      relation = character(0L), stringsAsFactors = FALSE
    ))
  }
  kin <- kinMatrix2LongForm(kmat, removeDups = TRUE)
  plan <- relationsPlan(kin, ped)
  if (is.null(plan)) {
    return(convertRelationshipsGeneral(kin, ped, updateProgress))
  }
  kin["relation"] <- relationNames(kin, plan)
  # One argument-free progress call per pair, as today.
  if (!is.null(updateProgress)) {
    for (i in seq_len(nrow(kin))) {
      notifyProgress(updateProgress)
    }
  }
  kin
}

## The relation of each pair of `kin` (id1, id2, kinship), given
## relationsPlan(kin, ped). Performance plan Phase 3: every pair is classified
## by vector comparisons in the order of today's rules, about a million pairs
## at a time, and the first rule a pair meets names it, as today's if/else
## chain does. convertRelationships() names every pair with it, and
## markerRealizedRelatednessVariance() the pairs that share a parent (S1082).
## Internal only.
relationNames <- function(kin, plan) {
  ruleOrder <- c(
    "self", "fullSiblings", "parentOffspring", "halfSiblings",
    "grandparentGrandchild", "fullCousins", "cousinOther", "fullAvuncular",
    "avuncularOther", "other", "noRelation"
  )
  nPairs <- nrow(kin)
  outside <- length(plan$id) + 1L
  k1 <- match(kin$id1, plan$id, nomatch = outside)
  k2 <- match(kin$id2, plan$id, nomatch = outside)
  classes <- integer(nPairs)
  blockSize <- relationBlockSize
  for (block in seq_len(ceiling(nPairs / blockSize))) {
    rows <- ((block - 1L) * blockSize + 1L):min(nPairs, block * blockSize)
    classes[rows] <- relationClasses(
      k1[rows], k2[rows], kin$kinship[rows], kin$id1[rows] == kin$id2[rows],
      plan
    )
  }
  unname(relationClassNames[ruleOrder])[classes]
}

# The number of pairs relationNames() classifies at a time.
# In blocks, the example's table of 6,824,665 pairs peaked at 936.6 MB, about
# its long form's own peak; classified at once, at 1,152 MB (S1055). A test
# swaps it for a small number to run several blocks.
relationBlockSize <- 1048576L

#' An ordinary pedigree, laid out for convertRelationships()' fast path, or
#' NULL
#'
#' \code{convertRelationships()}' fast path gives today's table only where
#' that can be shown (performance plan Phase 3, decision D1). So \code{ped}
#' must be a dataframe with text \code{id}, \code{sire} and \code{dam}
#' columns, at least one animal, and no id missing, empty or repeated; and the
#' long form \code{kin} must have text ids, none missing, and numeric
#' kinships. Any other input gives NULL, and \code{convertRelationships()}
#' runs today's code, \code{convertRelationshipsGeneral()} (owner ruling
#' S1055).
#'
#' @param kin the long form of the kinship matrix: \code{id1}, \code{id2} and
#' \code{kinship}.
#' @param ped the pedigree \code{convertRelationships()} was given.
#' @return NULL, or a list: \code{id}, the pedigree's ids; and \code{side1}
#' and \code{side2}, two integer matrices with a row per animal and one more
#' for an id outside the pedigree, whose columns are the animal's sire, dam,
#' sire's sire, sire's dam, dam's sire and dam's dam as numbers (an id's
#' number is its row). An unknown is -1 in \code{side1} and -2 in
#' \code{side2}, so it never equals anything on the other side.
#' @noRd
relationsPlan <- function(kin, ped) {
  if (!is.data.frame(ped) || !all(c("id", "sire", "dam") %in% names(ped))) {
    return(NULL)
  }
  id <- ped$id
  sire <- ped$sire
  dam <- ped$dam
  isText <- function(x) is.character(x) && is.null(dim(x))
  if (!isText(id) || !isText(sire) || !isText(dam) || length(id) == 0L ||
        anyNA(id) || !all(nzchar(id)) || anyDuplicated(id) > 0L ||
        !isText(kin$id1) || !isText(kin$id2) || anyNA(kin$id1) ||
        anyNA(kin$id2) || !is.numeric(kin$kinship)) {
    return(NULL)
  }
  known <- unique(c(id, sire, dam))
  known <- known[!is.na(known)]
  sireCode <- match(sire, known)
  damCode <- match(dam, known)
  # makeCEPH() finds a parent's own row with `[.data.frame`, which matches a
  # name partially when no row has it exactly. pmatch() would match a missing
  # parent as the text "NA", so an unknown parent has no row.
  sireRow <- pmatch(sire, id, duplicates.ok = TRUE)
  damRow <- pmatch(dam, id, duplicates.ok = TRUE)
  sireRow[is.na(sire)] <- NA_integer_
  damRow[is.na(dam)] <- NA_integer_
  ancestors <- rbind(cbind(
    sireCode, damCode, sireCode[sireRow], damCode[sireRow],
    sireCode[damRow], damCode[damRow]
  ), NA_integer_)
  side1 <- ancestors
  side2 <- ancestors
  side1[is.na(side1)] <- -1L
  side2[is.na(side2)] <- -2L
  list(id = id, side1 = side1, side2 = side2)
}

#' The relationship class of each pair, by today's rules in today's order
#'
#' The rules of \code{convertRelationshipsGeneral()}'s if/else chain, as
#' vector comparisons: each pair gets the number (1 to 11, in the chain's
#' order) of the first rule it meets.
#'
#' @param k1,k2 each pair's two animals, as rows of \code{plan$side1} and
#' \code{plan$side2}; the last row is an id outside the pedigree.
#' @param kinship each pair's kinship.
#' @param same whether the pair is one id twice.
#' @param plan as \code{relationsPlan()} returns.
#' @return An integer vector, one rule number per pair.
#' @noRd
relationClasses <- function(k1, k2, kinship, same, plan) {
  outside <- k1 > length(plan$id) | k2 > length(plan$id)
  s1 <- plan$side1[k1, 1L]
  d1 <- plan$side1[k1, 2L]
  ss1 <- plan$side1[k1, 3L]
  sd1 <- plan$side1[k1, 4L]
  ds1 <- plan$side1[k1, 5L]
  dd1 <- plan$side1[k1, 6L]
  s2 <- plan$side2[k2, 1L]
  d2 <- plan$side2[k2, 2L]
  ss2 <- plan$side2[k2, 3L]
  sd2 <- plan$side2[k2, 4L]
  ds2 <- plan$side2[k2, 5L]
  dd2 <- plan$side2[k2, 6L]
  g1 <- list(ss1, sd1, ds1, dd1)
  g2 <- list(ss2, sd2, ds2, dd2)
  anyOf <- function(v, set) {
    hit <- v == set[[1L]]
    for (s in set[-1L]) {
      hit <- hit | v == s
    }
    hit
  }
  # A rule names only the pairs no earlier rule has named.
  firstRule <- function(classes, hit, rule) {
    classes[is.na(classes) & hit] <- rule
    classes
  }
  classes <- firstRule(rep(NA_integer_, length(k1)), same, 1L)
  # An id outside the pedigree has no parents to compare: today's code finds
  # no difference between them and calls the pair full siblings.
  classes <- firstRule(classes, outside | (s1 == s2 & d1 == d2), 2L)
  classes <- firstRule(classes, k1 == s2 | k1 == d2 | k2 == s1 | k2 == d1,
                       3L)
  classes <- firstRule(classes, s1 == s2 | s1 == d2 | d1 == s2 | d1 == d2,
                       4L)
  classes <- firstRule(classes, anyOf(k1, g2) | anyOf(k2, g1), 5L)
  classes <- firstRule(
    classes, (ss1 == ss2 & sd1 == sd2) | (ss1 == ds2 & sd1 == dd2) |
      (ds1 == ss2 & dd1 == sd2) | (ds1 == ds2 & dd1 == dd2), 6L
  )
  classes <- firstRule(
    classes, anyOf(ss1, g2) | anyOf(sd1, g2) | anyOf(ds1, g2) |
      anyOf(dd1, g2), 7L
  )
  classes <- firstRule(
    classes, (s1 == ss2 & d1 == sd2) | (s1 == ds2 & d1 == dd2) |
      (s2 == ss1 & d2 == sd1) | (s2 == ds1 & d2 == dd1), 8L
  )
  classes <- firstRule(
    classes, anyOf(s1, g2) | anyOf(d1, g2) | anyOf(s2, g1) | anyOf(d2, g1),
    9L
  )
  classes <- firstRule(classes, kinship > 0L, 10L)
  classes[is.na(classes)] <- 11L
  classes
}

#' Today's relationship table, for any input
#'
#' \code{convertRelationships()}' code before performance plan Phase 3, word
#' for word after the long form is built: a CEPH-style pedigree, then each
#' pair classified in turn and its name added to the result.
#' \code{convertRelationships()} calls it for an input
#' \code{relationsPlan()} does not admit, which keeps that input's table,
#' error and warnings.
#'
#' @param kin the long form of the kinship matrix: \code{id1}, \code{id2} and
#' \code{kinship}.
#' @inheritParams convertRelationships
#' @return As \code{convertRelationships()}.
#' @noRd
convertRelationshipsGeneral <- function(kin, ped, updateProgress) {
  ped <- makeCEPH(ped$id, ped$sire, ped$dam)
  r <- character(0L)

  for (i in seq_len(nrow(kin))) {
    id1 <- kin$id1[i]
    id2 <- kin$id2[i]

    ceph1 <- ped[[id1]]
    ceph2 <- ped[[id2]]

    if (id1 == id2) {
      relation <- relationClassNames[["self"]]
    } else if (allTrueNoNA(ceph1$parents == ceph2$parents)) {
      relation <- relationClassNames[["fullSiblings"]]
    } else if (id1 %in% ceph2$parents || id2 %in% ceph1$parents) {
      # one animal is the parent of the other
      relation <- relationClassNames[["parentOffspring"]]
    } else if (!isEmpty(intersect(ceph1$parents, ceph2$parents))) {
      # at least 1 parent is shared
      relation <- relationClassNames[["halfSiblings"]]
    } else if (id1 %in% c(ceph2$pgp, ceph2$mgp) ||
      id2 %in% c(ceph1$pgp, ceph1$mgp)) {
      # one animals is the grandparent of the other
      relation <- relationClassNames[["grandparentGrandchild"]]
    } else if (allTrueNoNA(ceph1$pgp == ceph2$pgp) ||
      allTrueNoNA(ceph1$pgp == ceph2$mgp) ||
      allTrueNoNA(ceph1$mgp == ceph2$pgp) ||
      allTrueNoNA(ceph1$mgp == ceph2$mgp)) {
      # When a full set of grandparents are shared
      relation <- relationClassNames[["fullCousins"]]
    } else if (!isEmpty(intersect(
      c(ceph1$pgp, ceph1$mgp),
      c(ceph2$pgp, ceph2$mgp)
    ))) {
      # When at least one grandparent is in common
      relation <- relationClassNames[["cousinOther"]]
    } else if (allTrueNoNA(ceph1$parents == ceph2$pgp) ||
      allTrueNoNA(ceph1$parents == ceph2$mgp) ||
      allTrueNoNA(ceph2$parents == ceph1$pgp) ||
      allTrueNoNA(ceph2$parents == ceph1$mgp)) {
      # When parents of one proband are the grandparents of the other
      relation <- relationClassNames[["fullAvuncular"]]
    } else if (!isEmpty(intersect(ceph1$parents, c(ceph2$pgp, ceph2$mgp))) ||
      !isEmpty(intersect(ceph2$parents, c(ceph1$pgp, ceph1$mgp)))) {
      # When at least one parent of a proband is the grandparent of the other
      relation <- relationClassNames[["avuncularOther"]]
    } else if (kin$kinship[i] > 0L) {
      relation <- relationClassNames[["other"]]
    } else {
      relation <- relationClassNames[["noRelation"]]
    }

    r <- c(r, relation)

    notifyProgress(updateProgress)
  }
  kin["relation"] <- r
  kin
}
