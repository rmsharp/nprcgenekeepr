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
