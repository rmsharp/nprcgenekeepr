## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Reformat names of observed genotype columns
#'
##
#' This is not a good fix. A better solution is to avoid the problem.
#' Currently qcStudbook() blindly changes all of the column names by removing
#' the underscores.
#' @param ped the pedigree information in datatable format
#' @return A pedigree object where column names of "firstname" and "secondname"
#' are changed to "first_name" and "second_name" respectively.
#' @noRd
fixGenotypeCols <- function(ped) {
  if (any(tolower(names(ped)) == "firstname")) {
    names(ped)[names(ped) == "firstname"] <- "first_name"
  }
  if (any(tolower(names(ped)) == "secondname")) {
    names(ped)[names(ped) == "secondname"] <- "second_name"
  }
  ped
}
