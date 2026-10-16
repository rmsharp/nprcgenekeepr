## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Write a data frame to a temporary .xlsx file with create_wkbk() and return
## its path. Skips the calling test when openxlsx is not installed or the write
## fails. The caller deletes the file: xf <- writeTestXlsx(df);
## on.exit(unlink(xf), add = TRUE).
writeTestXlsx <- function(df, sheetname = "sheet") {
  testthat::skip_if_not_installed("openxlsx")
  xf <- tempfile(fileext = ".xlsx")
  status <- create_wkbk(
    file = xf, df_list = list(df), sheetnames = sheetname, replace = TRUE
  )
  testthat::skip_if_not(isTRUE(status))
  xf
}
