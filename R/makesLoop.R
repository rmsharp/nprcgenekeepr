#' \code{makesLoop} tests for a common ancestor.
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
#'
#' @return TRUE if there is one or more common ancestors for the sire and dam.
#'
#' Tests to see if sires and dams for an individual in a ptree have a common
#' ancester.
#'
#' @param id character vector of length 1 having the ID of interest
#' @param ptree a list of lists forming a pedigree tree as constructed by
#' \code{createPedTree(ped)} where \code{ped} is a standard pedigree dataframe.
#' @export
makesLoop <- function(id, ptree) {

  sAnc <- getAncestors(ptree[[id]]$sire, ptree)
  dAnc <- getAncestors(ptree[[id]]$dam, ptree)
  overlap <- intersect(sAnc, dAnc)

  return(length(overlap) > 0)
}