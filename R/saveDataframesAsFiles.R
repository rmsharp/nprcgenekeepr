## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Write copy of dataframes to either CSV, TXT, or Excel file
#'
#' Takes a list of dataframes and creates a file based on the list name of
#' the dataframe and the extension for the file type.
#'
#' @param dfList list of dataframes to be stored as files.
#' \code{"txt"}, \code{"csv"}, or \code{"xlsx"}. Default value is \code{"csv"}.
#' @param baseDir character vector of length on with the directory path.
#' @param fileType character vector of length one with possible values of
#' \code{"txt"}, \code{"csv"}, or \code{"xlsx"}. Default value is \code{"csv"}.
#'
#' @return Full path name of files saved.
#'
#' @importFrom utils write.table write.csv
## ## rmsutilityr create_wkbk
#' @export
#' @examples
#' library(nprcgenekeepr)
#' dfList <- list(
#'   lacy1989Ped = nprcgenekeepr::lacy1989Ped,
#'   pedGood = nprcgenekeepr::pedGood
#' )
#' ## Write each data frame to a CSV file under a temporary directory.
#' files <- saveDataframesAsFiles(dfList,
#'   baseDir = tempdir(), fileType = "csv"
#' )
#' basename(files)
saveDataframesAsFiles <- function(dfList, baseDir, fileType = "csv") {
  if (!(inherits(dfList, "list") &&
    all(vapply(dfList, inherits, logical(1L), what = "data.frame")))) {
    stop("dfList must be a list containing only dataframes.")
  }
  stopifnot(any(fileType %in% c("txt", "csv", "excel")))
  filesWritten <- character(0L)
  for (i in seq_along(dfList)) {
    filename <- paste0(baseDir, "/", names(dfList)[i], ".", fileType)
    if (fileType == "csv") {
      write.csv(dfList[[i]],
        file = filename,
        row.names = FALSE
      )
    } else if (fileType == "excel") {
      status <-
        create_wkbk(
          file = filename,
          df_list = dfList[i],
          sheetnames = names(dfList)[i],
          replace = TRUE
        )
      if (!status) {
        stop("Failed to write example data out to ", filename, ".")
      }
    } else { # txt; tab delimited
      write.table(
        dfList[[i]],
        file = filename,
        row.names = FALSE,
        sep = "\t"
      )
    }
    filesWritten <- c(filesWritten, filename)
  }
  filesWritten
}
