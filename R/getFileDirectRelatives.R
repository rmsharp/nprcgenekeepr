## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Get the direct relatives of selected animals from a pedigree file
#'
#' File-sourced sibling of \code{\link{getLkDirectRelatives}}: reads a pedigree
#' file through the internal \code{getPedigreeSource()} \code{"file"} provider
#' (via \code{\link{getPedigree}}), then delegates the pedigree walk to the
#' source-agnostic \code{\link{getPedDirectRelatives}}. The result is the full
#' connected pedigree component (ancestors, descendants, and collaterals such as
#' siblings and mates) reachable from the focal animals. It is fully offline and
#' deterministic.
#'
#' Unlike the LabKey source, which fails soft (returns \code{NULL}) when its
#' fetch fails, the file source errors loudly: a \code{NULL} or missing
#' \code{fileName}, a file that does not exist, or a file lacking the
#' \code{id}, \code{sire}, and \code{dam} columns each raises an error.
#'
#' @param ids character vector with Ids.
#' @param fileName path to a pedigree file (CSV or Excel) read via
#' \code{\link{getPedigree}}; the file must provide at least \code{id},
#' \code{sire}, and \code{dam} columns.
#' @param sep column separator passed to the file reader for delimited text
#' files (default \code{","}); ignored for Excel files.
#' @param unrelatedParents logical vector when \code{FALSE} the unrelated
#' parents of offspring do not get a record as an ego; when \code{TRUE}
#' a place holder record where parent (\code{sire},
#' \code{dam}) IDs are set to \code{NA}.
#'
#' @return A data.frame with pedigree structure containing all direct relatives
#' -- the full connected pedigree component (ancestors, descendants, and
#' collaterals) -- for the Ids provided.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ## Build a tiny pedigree file, then pull the relatives of a focal animal.
#' ped <- data.frame(
#'   id = c("A", "B", "C"), sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
#'   stringsAsFactors = FALSE
#' )
#' pedFile <- tempfile(fileext = ".csv")
#' write.csv(ped, pedFile, row.names = FALSE)
#' getFileDirectRelatives(ids = "C", fileName = pedFile)
#' unlink(pedFile)
getFileDirectRelatives <- function(ids, fileName = NULL, sep = ",",
                                   unrelatedParents = FALSE) {
  pedSourceDf <- getPedigreeSource(
    sourceType = "file", fileName = fileName, sep = sep
  )
  getPedDirectRelatives(
    ids = ids, ped = pedSourceDf,
    unrelatedParents = unrelatedParents
  )
}
