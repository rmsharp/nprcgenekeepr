#' Creates a folder with CSV files containing example pedigrees and ID lists
#' used to demonstrate the package.
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of mprcgenekeepr
#' Creates a folder named \code{~/tmp/ExamplePedigrees} if it does not already
#' exist. It then proceeds to write each example pedigree into a CSV file named
#' based on the name of the example pedigree.
#'
#' @return A vector of the names of the files written.
#'
#' @export
#' @examples
#' library(mprcgenekeepr)
#' files <- createExampleFiles()
createExampleFiles <- function() {
  examplePedigrees <-
    list(
      examplePedigree = mprcgenekeepr::examplePedigree,
      focalAnimals = mprcgenekeepr::focalAnimals,
      lacy1989Ped = mprcgenekeepr::lacy1989Ped,
      pedDuplicateIds = mprcgenekeepr::pedDuplicateIds,
      pedFemaleSireMaleDam = mprcgenekeepr::pedFemaleSireMaleDam,
      pedGood = mprcgenekeepr::pedGood,
      pedInvalidDates = mprcgenekeepr::pedInvalidDates,
      pedMissingBirth = mprcgenekeepr::pedMissingBirth,
      pedOne = mprcgenekeepr::pedOne,
      pedSameMaleIsSireAndDam = mprcgenekeepr::pedSameMaleIsSireAndDam,
      pedSix = mprcgenekeepr::pedSix,
      pedWithGenotype = mprcgenekeepr::pedWithGenotype,
      qcBreeders = as.data.frame(mprcgenekeepr::qcBreeders, drop = FALSE),
      qcPed = mprcgenekeepr::qcPed,
      smallPed = mprcgenekeepr::smallPed
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
