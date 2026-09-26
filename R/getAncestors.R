## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Recursively collect an individual's ancestors
#'
#' Part of Pedigree Sampling
#' From PedigreeSampling.R
#' 2016-01-28
#'
#' Contains functions to build pedigrees from sub-samples
#' of genotyped individuals.
#'
#' The goal of sampling is to reduce the number of inbreeding
#' loops in the resulting pedigree, and thus, reduce the
#' amount of time required to perform calculations with
#' SIMWALK2 or similar programs.
#'
#' @param id character vector of length 1 having the ID of interest
#' @param ptree a list of lists forming a pedigree tree as constructed by
#' \code{createPedTree(ped)} where \code{ped} is a standard pedigree dataframe.
#'
#' @return A character vector of ancestors for an individual ID.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::qcPed
#' ped <- qcStudbook(ped, minParentAge = 0)
#' pedTree <- createPedTree(ped)
#' pedLoops <- findLoops(pedTree)
#' ids <- names(pedTree)
#' allAncestors <- list()
#'
#' for (i in seq_along(ids)) {
#'   id <- ids[[i]]
#'   anc <- getAncestors(id, pedTree)
#'   allAncestors[[id]] <- anc
#' }
#' head(allAncestors)
#' countOfAncestors <- unlist(lapply(allAncestors, length))
#' idsWithMostAncestors <-
#'   names(allAncestors)[countOfAncestors == max(countOfAncestors)]
#' allAncestors[idsWithMostAncestors]
getAncestors <- function(id, ptree) {
  .getAncestorsOnPath(id, ptree, character(0L))
}

#' Recursive worker for \code{getAncestors()}
#'
#' Carries the ids on the current route from the starting id down to \code{id}
#' so a pedigree cycle (an animal that is its own ancestor) is named in an
#' error instead of recursing until R aborts. The route is kept per branch,
#' not as a global visited set: an ancestor reached through both parents is
#' still returned once per route (the documented repeats), and only an id that
#' reappears on its own route is a cycle.
#'
#' @param id character vector of length 1 having the ID of interest
#' @param ptree a list of lists forming a pedigree tree as constructed by
#' \code{createPedTree(ped)}.
#' @param path character vector of the ids already on the current route.
#' @return A character vector of ancestors for an individual ID.
#' @noRd
.getAncestorsOnPath <- function(id, ptree, path) {
  if (is.na(id)) {
    return(character(0L))
  }

  if (id %in% path) {
    cycle <- c(path[match(id, path):length(path)], id)
    stop(
      "getAncestors: the pedigree contains a cycle (an animal is its own ",
      "ancestor): ", paste(cycle, collapse = " -> "), ". Each id is a sire ",
      "or dam of the one before it; correct the sire and dam entries for ",
      "these ids.",
      call. = FALSE
    )
  }
  path <- c(path, id)

  sire <- ptree[[id]]$sire
  dam <- ptree[[id]]$dam

  if (!is.na(sire)) {
    sAnc <- .getAncestorsOnPath(sire, ptree, path)
    sireLineage <- c(sire, sAnc)
  } else {
    sireLineage <- character(0L)
  }

  if (!is.na(dam)) {
    dAnc <- .getAncestorsOnPath(dam, ptree, path)
    damLineage <- c(dam, dAnc)
  } else {
    damLineage <- character(0L)
  }

  c(sireLineage, damLineage)
}
