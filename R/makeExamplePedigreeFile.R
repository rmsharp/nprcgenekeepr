## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Write copy of nprcgenekeepr::examplePedigree into a file
#'
#' Uses \code{examplePedigree} data structure to create an example data file
#'
#' @param file character vector of length one providing the file name
#' @param fileType character vector of length one with possible values of
#' \code{"txt"}, \code{"csv"}, or \code{"excel"}. Default value is \code{"csv"}.
#'
#' @return Full path name of file saved.
#'
#' @importFrom utils write.table write.csv
## ## rmsutilityr create_wkbk
#' @export
#' @examples
#' library(nprcgenekeepr)
#' pedigreeFile <- makeExamplePedigreeFile()
makeExamplePedigreeFile <- function(file = file.path(
                                      tempdir(),
                                      "examplePedigree.csv"
                                    ),
                                    fileType = "csv") {
  stopifnot(any(fileType %in% c("txt", "csv", "excel")))
  if (fileType == "csv") {
    write.csv(nprcgenekeepr::examplePedigree,
      file = file, row.names = FALSE
    )
  } else if (fileType == "excel") {
    status <-
      create_wkbk(
        file = file,
        df_list = list(nprcgenekeepr::examplePedigree),
        sheetnames = "Example_Pedigree", replace = FALSE
      )
    if (!status) {
      stop("Failed to write example data out to ", file, ".")
    }
  } else {
    write.table(nprcgenekeepr::examplePedigree,
      file = file, row.names = FALSE, sep = "\t"
    )
  }
  file
}
