#' Reformat names of observed genotype columns
#'
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr
#' This is not a good fix. A better solution is to avoid the problem.
#' Currently qcStudbook() blindly changes all of the column names by removing
#' the underscores.
#' @param ped the pedigree information in datatable format
fixGenotypeCols <- function(ped) {
  if (any(tolower(names(ped)) %in% "firstname")) {
    names(ped)[names(ped) == "firstname"] <- "first_name"
  }
  if (any(tolower(names(ped)) %in% "secondname")) {
    names(ped)[names(ped) == "secondname"] <- "second_name"
  }
  ped
}
