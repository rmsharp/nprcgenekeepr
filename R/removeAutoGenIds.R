#' Remove automatically generated IDs from pedigree
#'
#' Identifies automatically generated IDs via \code{isGeneratedUnknownId()},
#' the shared detection predicate derived from the configurable auto-ID format
#' (see \code{\link{getAutoIdFormat}}; default a leading "U"). Routing detection
#' through that single predicate is the "function call" the former inline
#' leading-"U" check was flagged to become.
#' @param ped datatable that is the `Pedigree`. It contains pedigree
#' information. The \code{id}, \code{sire}, and \code{dame} columns are
#' required.
#'
#' @return A pedigree with automatically generated IDs removed.
#' @export
#'
#' @examples
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' length(examplePedigree$id)
#' ped <- removeAutoGenIds(examplePedigree)
#' length(ped$id)
#'
removeAutoGenIds <- function(ped) {
  ped <- ped[!isGeneratedUnknownId(ped$id), ]
  ped$sire[isGeneratedUnknownId(ped$sire)] <- NA
  ped$dam[isGeneratedUnknownId(ped$dam)] <- NA
  ped
}
