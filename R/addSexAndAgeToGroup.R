#' Forms a dataframe with Id, Sex, and current Age given a list of Ids and a
#' pedigree
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @details An empty \code{ids} vector yields a zero-row data frame that still
#' contains all three columns (\code{ids}, \code{sex}, \code{age}), with
#' \code{sex} an empty factor, so the returned schema does not depend on the
#' number of ids supplied.
#'
#' @return Dataframe with Id, Sex, and Current Age
#'
#' @param ids character vector of animal Ids
#' @param ped datatable that is the `Pedigree`. It contains pedigree
#' information including the IDs listed in \code{candidates}.
#' @export
#' @examples
#' library(nprcgenekeepr)
#' data("qcBreeders")
#' data("qcPed")
#' df <- addSexAndAgeToGroup(ids = qcBreeders, ped = qcPed)
#' head(df)
addSexAndAgeToGroup <- function(ids, ped) {
  group <- data.frame(
    ids,
    sex = ped$sex[match(ids, ped$id)],
    age = vapply(ids, function(id) {
      getCurrentAge(ped$birth[ped$id == id])
    }, numeric(1L)),
    stringsAsFactors = FALSE
  )
  group
}
