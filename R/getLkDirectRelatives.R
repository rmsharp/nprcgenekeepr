#' Get the direct relatives of selected animals from the LabKey EHR
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Builds the pedigree of relatives for the provided focal animals from the
#' LabKey \code{study} schema \code{demographics} table, obtained through the
#' internal \code{getPedigreeSource()} adapter. The pedigree walk is delegated
#' to \code{getPedDirectRelatives()}, so the result is the full connected
#' pedigree component (ancestors, descendants, and collaterals such as siblings
#' and mates) reachable from the focal animals.
#'
#' @return A data.frame with pedigree structure containing all direct relatives
#' -- the full connected pedigree component (ancestors, descendants, and
#' collaterals) -- for the Ids provided.
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
  getPedDirectRelatives(
    ids = ids, ped = pedSourceDf,
    unrelatedParents = unrelatedParents
  )
}
