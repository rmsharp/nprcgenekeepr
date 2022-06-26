#' Get the direct ancestors of selected animals from supplied pedigree.
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Gets direct ancestors from labkey \code{study} schema and \code{demographics}
#' table.
#'
#' @return A data.frame with pedigree structure having all of the direct
#' ancestors for the Ids provided.
#'
#' @examples
#' \donttest{
#' library(nprcgenekeepr)
#' ## Have to a vector of focal animals
#' focalAnimals <- c("1X2701", "1X0101")
#' suppressWarnings(getLkDirectRelatives(ids = focalAnimals))
#' }
#'
#' @param ids character vector with Ids.
#' @param ped pedigree dataframe object that is used as the source of
#' pedigree information.
#' @param unrelatedParents logical vector when \code{FALSE} the unrelated
#' parents of offspring do not get a record as an ego; when \code{TRUE}
#' a place holder record where parent (\code{sire},
#' \code{dam}) IDs are set to \code{NA}.
#'
#' @import futile.logger
#' @importFrom data.table rbindlist
#' @importFrom stringi stri_c
#' @export
getPedDirectRelatives <- function(ids, ped, unrelatedParents = FALSE) {
  if (missing(ids))
    stop("Need to specify IDs in 'id' parameter.")

  if (missing(ped))
    stop("Need to specify pedigree in 'ped' parameter.")

  if (is.null(ped))
    return(NULL)

  if (!is.data.frame(ped))
    stop("ped must be a data.frame object.")


  parents <- ids
  offspring <- ids
  len <- length(parents)
  relativesDf <- ped[ped$id %in% ids, ]
  while (len > 0) {
    parents <- getParents(ped, parents)
    offspring <- getOffspring(ped, offspring)
    len <- length(parents) + length(offspring)
    if (len > 0) {
      if (length(parents) > 0) {
        relativesDf <- rbindlist(list(relativesDf,
                             ped[ped$id %in% parents, ]))
      }
      if (length(offspring) > 0) {
        relativesDf <- rbindlist(list(relativesDf,
                             ped[ped$id %in% offspring, ]))
      }
      relativesDf <- relativesDf[!duplicated(relativesDf$id), ]
    }
  }
  unrelated <- unique(c(
    relativesDf$sire[!relativesDf$sire %in% relativesDf$id],
    relativesDf$dam[!relativesDf$dam %in% relativesDf$id]))
  addIdRecords(ids = unrelated, fullPed = ped, partialPed = relativesDf)
}
