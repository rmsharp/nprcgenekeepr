#' Count the number of loops in a pedigree tree.
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
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
#'
#' Uses the \code{loops} data structure and the list of all ancestors for
#' each individual to calculate the number of loops for each individual.
#'
#' @return A list indexed with each ID in the pedigree tree (\code{ptree})
#' containing the number of loops for each individual.
#'
#' @param loops a named list of logical values where each named element is
#' named with an \code{id} from \code{ptree}. The value of the list element
#' is set to \code{TRUE} if the \code{id} has a loop in the pedigree.
#' Loops occur when an animal's sire and dam have a common ancestor.
#' @param ptree a list of lists forming a pedigree tree as constructed by
#' \code{createPedTree(ped)} where \code{ped} is a standard pedigree dataframe.
#' @export
#' @examples
#' library(nprcgenekeepr)
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' exampleTree <- createPedTree(examplePedigree)
#' exampleLoops <- findLoops(exampleTree)
#' ## You can count how many animals are in loops with the following code.
#' length(exampleLoops[exampleLoops == TRUE])
#' ## You can count how many loops you have with the following code.
#' nLoops <- countLoops(exampleLoops, exampleTree)
#' sum(unlist(nLoops[nLoops > 0]))
#' ## You can list the first 10 sets of ids, sires and dams in loops with
#' ## the following line of code:
#' examplePedigree[exampleLoops == TRUE, c("id", "sire", "dam")][1:10, ]
countLoops <- function(loops, ptree) {
  ids <- names(ptree)
  counts <- list()

  for (id in ids) {
    anc <- getAncestors(id, ptree)
    l <- loops[c(id, anc)]
    counts[id] <- sum(unlist(l))
  }
  counts
}
