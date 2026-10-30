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
#' An ancestor reached through both parents is returned once for each route.
#' The function stops with an error that names the ids involved when
#' \code{ptree} contains a cycle (an animal that is its own ancestor), which is
#' a data error.
#'
#' A sire or dam that has no entry of its own in \code{ptree} is treated as an
#' animal with unknown parents, as \code{qcStudbook()} treats it
#' (\code{addParents()} adds the entry): it is returned as an ancestor and has
#' no ancestors of its own. The function stops with an error that names the id
#' when \code{id} itself is not in \code{ptree}.
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
#' ped <- qcStudbook(ped, minSireAge = 0, minDamAge = 0)
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
  if (!is.na(id) && !id %in% names(ptree)) {
    stop(
      "getAncestors: \"", id, "\" is not in the pedigree tree. Check the id, ",
      "or add an entry for it to the tree.",
      call. = FALSE
    )
  }
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
#' A text id is looked up once, with \code{ptree[[id]]}: matching it against
#' \code{names(ptree)} at every step made the walk twice as slow as in 2.0.0
#' (S1095). Any other id, and a text id with no entry, keeps that name check,
#' since \code{[[} reads a number or a factor as a position.
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
  node <- if (is.character(id)) ptree[[id]] else NULL
  if (is.null(node)) {
    if (!id %in% names(ptree)) {
      return(character(0L))
    }
    node <- ptree[[id]]
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

  sire <- node$sire
  dam <- node$dam

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
