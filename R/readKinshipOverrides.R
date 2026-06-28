#' Read a kinship overrides table from a file
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Reads an outside-information kinship override table (issue #13) from a
#' user-supplied file into a data frame for \code{\link{checkKinshipOverrides}}
#' and \code{\link{reportGV}}. The expected long form is the output of
#' \code{\link{kinMatrix2LongForm}}: columns \code{id1}, \code{id2}, and
#' \code{kinship}, with a header row, so a user can export the current matrix,
#' edit a few rows, and feed it back. Excel (\code{.xls}/\code{.xlsx}) and
#' delimited text (\code{.csv}/\code{.txt}) files are both accepted, mirroring
#' \code{\link{getGenotypes}}.
#'
#' This reader does not validate structure or domain -- that is
#' \code{\link{checkKinshipOverrides}}'s job. \code{kinship} is the kinship
#' coefficient \emph{f}, \strong{not} the coefficient of relatedness \emph{r}
#' (= 2\emph{f} for non-inbred animals).
#'
#' @return A data frame of the rows read from \code{fileName} (typically with
#' columns \code{id1}, \code{id2}, and \code{kinship}). Validate it with
#' \code{\link{checkKinshipOverrides}} before use.
#'
#' @param fileName character vector of length one; path to the override file
#' (typically the temporary \code{datapath} from a Shiny file upload).
#' @param sep column separator for delimited text files (default \code{","}).
#' @importFrom readxl excel_format
#' @importFrom utils read.table
#' @export
#' @examples
#' \dontrun{
#' overrides <- readKinshipOverrides(fileName = "kinship_overrides.csv")
#' overrides <- checkKinshipOverrides(overrides)
#' }
readKinshipOverrides <- function(fileName, sep = ",") {
  if (excel_format(fileName) %in% c("xls", "xlsx")) {
    overrides <- readExcelPOSIXToCharacter(fileName)
  } else {
    overrides <- muffleIncompleteFinalLine(read.table(fileName,
      header = TRUE,
      sep = sep,
      stringsAsFactors = FALSE,
      na.strings = c("", "NA"),
      check.names = FALSE
    ))
  }
  as.data.frame(overrides)
}
