## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Create example pedigree and ID-list CSV files
#'
#' Creates a folder named \code{ExamplePedigrees} under the R session temporary
#' directory (as returned by \code{tempdir()}) if it does not already exist. It
#' then proceeds to write each example pedigree into a CSV file named based on
#' the name of the example pedigree.
#'
#' @return A vector of the names of the files written.
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' files <- createExampleFiles()
createExampleFiles <- function() {
  examplePedigrees <-
    list(
      examplePedigree = nprcgenekeepr::examplePedigree,
      focalAnimals = nprcgenekeepr::focalAnimals,
      lacy1989Ped = nprcgenekeepr::lacy1989Ped,
      pedDuplicateIds = nprcgenekeepr::pedDuplicateIds,
      pedFemaleSireMaleDam = nprcgenekeepr::pedFemaleSireMaleDam,
      pedGood = nprcgenekeepr::pedGood,
      pedInvalidDates = nprcgenekeepr::pedInvalidDates,
      pedMissingBirth = nprcgenekeepr::pedMissingBirth,
      pedOne = nprcgenekeepr::pedOne,
      pedSameMaleIsSireAndDam = nprcgenekeepr::pedSameMaleIsSireAndDam,
      pedSix = nprcgenekeepr::pedSix,
      pedWithGenotype = nprcgenekeepr::pedWithGenotype,
      qcBreeders = as.data.frame(nprcgenekeepr::qcBreeders, drop = FALSE),
      qcPed = nprcgenekeepr::qcPed,
      smallPed = nprcgenekeepr::smallPed
    )
  pedigreeDir <- tempdir()
  suppressWarnings(dir.create(pedigreeDir))
  pedigreeDir <- file.path(pedigreeDir, "ExamplePedigrees")
  suppressWarnings(dir.create(pedigreeDir))
  message(
    "Example pedigree files ",
    get_and_or_list(names(examplePedigrees)),
    " will be created in ",
    pedigreeDir,
    ".\n"
  )
  saveDataframesAsFiles(examplePedigrees, baseDir = pedigreeDir, "csv")
}
