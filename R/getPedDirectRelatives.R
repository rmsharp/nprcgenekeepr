## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get the direct relatives of selected animals from a pedigree
#'
#' Gets the direct relatives (ancestors and descendants) of the selected
#' animals from the supplied pedigree (\code{ped}).
#'
#' @inheritParams getParents
#' @param ped pedigree dataframe object that is used as the source of
#' pedigree information.
#' @param unrelatedParents logical vector when \code{FALSE} the unrelated
#' parents of offspring do not get a record as an ego; when \code{TRUE} they
#' get a place holder record as an ego in which the parent (\code{sire},
#' \code{dam}) IDs are set to \code{NA}.
#'
#' @return A data.frame of pedigree records for the selected animals and
#' their direct relatives (ancestors and descendants) in \code{ped}.
#'
#' @importFrom data.table rbindlist
#' @importFrom stringi stri_c
#' @family direct relatives
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## A pedigree to search and a focal animal whose direct relatives we want
#' ped <- nprcgenekeepr::lacy1989Ped
#' getPedDirectRelatives(ids = "E", ped = ped)
getPedDirectRelatives <- function(ids, ped, unrelatedParents = FALSE) {
  if (missing(ids)) {
    stop("Need to specify IDs in 'id' parameter.")
  }

  if (missing(ped)) {
    stop("Need to specify pedigree in 'ped' parameter.")
  }

  if (is.null(ped)) {
    return(NULL)
  }

  if (!is.data.frame(ped)) {
    stop("ped must be a data.frame object.")
  }


  offspring <- parents <- ids
  len <- length(ids)
  while (len > 0L) {
    parents <- getParents(ped, ids)
    offspring <- getOffspring(ped, ids)
    added <- unique(union(parents, offspring))
    added <- setdiff(added, ids)
    len <- length(added)
    if (len == 0L) {
      break
    }
    ids <- union(added, ids)
    ids <- ids[!is.na(ids)]
  }

  relatives <- ped[ped$id %in% ids, ]
  if (unrelatedParents) {
    unrelated <- unique(ids[!ids %in% ped$id])
    unrelated <- unrelated[!is.na(unrelated)]
    if (length(unrelated) > 0L) {
      placeholders <- relatives[rep(NA_integer_, length(unrelated)), ]
      placeholders$id <- unrelated
      placeholders$sire <- NA
      placeholders$dam <- NA
      relatives <- rbind(relatives, placeholders)
      rownames(relatives) <- NULL
    }
  }
  relatives
}
