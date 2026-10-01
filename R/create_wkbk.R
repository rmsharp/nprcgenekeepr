## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Create an Excel workbook with worksheets
#'
#' @param file filename of workbook to be created
#' @param df_list list of data frames to be added as worksheets to workbook
#' @param sheetnames character vector of worksheet names
#' @param replace Specifies if the file should be replaced if it
#' already exist (default is FALSE).
#' @return \code{TRUE} if the Excel file was successfully created.
#' \code{FALSE}, with a warning, if the file already exists and
#' \code{replace} is \code{FALSE}. Other problems are signaled as errors
#' rather than returned as \code{FALSE}; examples are a number of
#' \code{sheetnames} that differs from the length of \code{df_list} and an
#' invalid worksheet name.
#'
#' @importFrom openxlsx write.xlsx
#' @export
#' @examples
#' library(nprcgenekeepr)
#'
#' make_df_list <- function(size) {
#'   df_list <- list(size)
#'   if (size <= 0) {
#'     return(df_list)
#'   }
#'   for (i in seq_len(size)) {
#'     n <- sample(2:10, 2, replace = TRUE)
#'     df <- data.frame(matrix(data = rnorm(n[1] * n[2]), ncol = n[1]))
#'     df_list[[i]] <- df
#'   }
#'   names(df_list) <- paste0("A", seq_len(size))
#'   df_list
#' }
#' df_list <- make_df_list(3)
#' sheetnames <- names(df_list)
#' wkbkFile <- file.path(tempdir(), "example_excel_wkbk.xlsx")
#' create_wkbk(
#'   file = wkbkFile,
#'   df_list = df_list,
#'   sheetnames = sheetnames,
#'   replace = FALSE
#' )
#' if (file.exists(wkbkFile)) {
#'   file.remove(wkbkFile)
#' }
create_wkbk <- function(file, df_list, sheetnames, replace = FALSE) {
  if (length(df_list) != length(sheetnames)) {
    stop(
        "Number of 'sheetnames' specified does not equal the number ",
        "of data frames in 'df_list'."
    )
  }

  if (file.exists(file)) {
    if (!replace) {
      warning("File, ", file, " exists and was not overwritten.")
      return(FALSE)
    }
    file.remove(file)
  }
  names(df_list) <- sheetnames
  ## Write Date/POSIXct columns as literal text (matching the prior WriteXLS
  ## backend's behavior) rather than openxlsx's native numeric-with-date-
  ## format cells: readxl::read_excel(col_types = "text") -- this package's
  ## own read path (readExcelPOSIXToCharacter()) -- returns a date-formatted
  ## numeric cell's raw serial number as text, not its rendered date string.
  df_list <- lapply(df_list, function(df) {
    isDateCol <- vapply(
      df, function(col) inherits(col, "Date") || inherits(col, "POSIXct"),
      logical(1L)
    )
    df[isDateCol] <- lapply(df[isDateCol], as.character)
    df
  })
  write.xlsx(
    x = df_list,
    file = file,
    colNames = TRUE,
    colWidths = "auto"
  )
  TRUE
}
