#' Reformats a kinship matrix into a long-format table.
#'
## Copyright(c) 2017-2020 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Part of Group Formation
#'
#' @return A dataframe with columns \code{id1}, \code{id2}, and \code{kinship}.
#' This is the kinship data reformatted from a matrix, to a long-format table.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
#' reformattedKmat <- kinMatrix2LongForm(kmat, rm.dups = FALSE)
#' nrow(reformattedKmat)
#' reformattedNoDupsKmat <- kinMatrix2LongForm(kmat, rm.dups = TRUE)
#' nrow(reformattedNoDupsKmat)
#' }
#' @param kinMatrix numerical matrix of pairwise kinship values. The row and
#' column names correspond to animal IDs.
#' @param rm.dups logical value indication whether or not reverse-order ID
#' pairs be filtered out? (i.e., "ID1 ID2 kin_val" and "ID2 ID1 kin_val" will
#' be collapsed into a single entry if rm.dups = TRUE)
#'
#' @importFrom utils stack
#' @export
kinMatrix2LongForm <- function(kinMatrix, rm.dups = FALSE) {
  if (rm.dups) {
    kinMatrix[upper.tri(kinMatrix)] <- NA
  }

  kmat <- as.data.frame(kinMatrix)
  k <- stack(kmat)
  k["id2"] <- row.names(kmat)

  colnames(k) <- c("kinship", "id1", "id2")
  k$id1 <- as.character(k$id1)

  k <- k[!is.na(k$kinship), ]

  return(k[, c("id1", "id2", "kinship")])
}
