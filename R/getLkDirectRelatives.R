#' Get the direct ancestors of selected animals
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Gets direct ancestors from labkey \code{study} schema and \code{demographics}
#' table.
#'
#' @return A data.frame with pedigree structure having all of the direct
#' ancestors for the Ids provided.
#'
#' @param ids character vector with Ids.
#' @param unrelatedParents logical vector when \code{FALSE} the unrelated
#' parents of offspring do not get a record as an ego; when \code{TRUE}
#' a place holder record where parent (\code{sire},
#' \code{dam}) IDs are set to \code{NA}.
#'
#' @export
#' @examples
#' \donttest{
#' # Requires LabKey connection
#' library(nprcgenekeepr)
#' ## Have to a vector of focal animals
#' focalAnimals <- c("1X2701", "1X0101")
#' suppressWarnings(getLkDirectRelatives(ids = focalAnimals))
#' }
getLkDirectRelatives <- function(ids, unrelatedParents = FALSE) {
  pedSourceDf <- getPedigreeSource(sourceType = "labkey")
  if (is.null(pedSourceDf)) {
    return(NULL)
  }
  parents <- ids
  offspring <- ids
  len <- length(parents)
  relativesDf <- pedSourceDf[pedSourceDf$id %in% ids, ]
  while (len > 0L) {
    parents <- getParents(pedSourceDf, parents)
    offspring <- getOffspring(pedSourceDf, offspring)
    len <- length(parents) + length(offspring)
    if (len > 0L) {
      if (length(parents) > 0L) {
        relativesDf <- rbind(relativesDf,
          pedSourceDf[pedSourceDf$id %in% parents, ],
          stringsAsFactors = FALSE
        )
      }
      if (length(offspring) > 0L) {
        relativesDf <- rbind(relativesDf,
          pedSourceDf[pedSourceDf$id %in% offspring, ],
          stringsAsFactors = FALSE
        )
      }
      relativesDf <- relativesDf[!duplicated(relativesDf$id), ]
    }
  }
  unrelated <- unique(c(
    relativesDf$sire[!relativesDf$sire %in% relativesDf$id],
    relativesDf$dam[!relativesDf$dam %in% relativesDf$id]
  ))
  addIdRecords(ids = unrelated, fullPed = pedSourceDf, partialPed = relativesDf)
}
