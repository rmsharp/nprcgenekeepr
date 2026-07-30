## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Convert a pedigree data frame into visNetwork-ready diagram data
#'
#' Builds the node and edge tables consumed by \code{visNetwork::visNetwork()}
#' from a pedigree data frame: one node per individual, sex-coded to a node
#' shape, positioned by generation; one directed edge per known sire and one
#' per known dam, pointing from parent to child.
#'
#' @param ped data frame with \code{id}, \code{sire}, \code{dam}, \code{sex},
#'   and \code{gen} columns (\code{sire}/\code{dam} \code{NA} for unknown
#'   parents; \code{gen} an integer generation number, 0 for founders, as
#'   produced by \code{\link{findGeneration}}).
#' @return A list with two data frames: \code{nodes} (\code{id}, \code{label},
#'   \code{shape}, \code{level}) and \code{edges} (\code{from}, \code{to}).
#'
#' @examples
#' library(nprcgenekeepr)
#' diagramData <- makePedigreeDiagramData(nprcgenekeepr::examplePedigree)
#'
#' @export
makePedigreeDiagramData <- function(ped) {
  if (!is.data.frame(ped)) {
    stop("makePedigreeDiagramData() requires 'ped' to be a data frame.")
  }
  required <- c("id", "sire", "dam", "sex", "gen")
  missingCols <- setdiff(required, names(ped))
  if (length(missingCols) > 0L) {
    stop("makePedigreeDiagramData() requires 'ped' to have columns: ",
         paste(required, collapse = ", "), ". Missing: ",
         paste(missingCols, collapse = ", "))
  }

  shapeMap <- c(F = "dot", M = "square", H = "star", U = "triangle")
  shapes <- unname(shapeMap[as.character(ped$sex)])
  shapes[is.na(shapes)] <- "diamond"

  nodes <- data.frame(
    id = ped$id,
    label = ped$id,
    shape = shapes,
    level = ped$gen,
    stringsAsFactors = FALSE
  )

  hasSire <- !is.na(ped$sire)
  hasDam <- !is.na(ped$dam)
  edges <- data.frame(
    from = c(ped$sire[hasSire], ped$dam[hasDam]),
    to = c(ped$id[hasSire], ped$id[hasDam]),
    stringsAsFactors = FALSE
  )

  list(nodes = nodes, edges = edges)
}
