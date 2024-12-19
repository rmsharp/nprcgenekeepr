#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("dataframe2string")
library(stringi)
## See change in calendar result for sire age; changed 20200412
pedOne <- nprcgenekeepr::pedOne
errorLst <- qcStudbook(pedOne, reportErrors = TRUE)
text <- summary(errorLst)
lines <- dataframe2string(text$sp, rowNames = FALSE, digits = 2)
test_that("dataframe2string forms single character vector from dataframe", {
  expect_true( ## 8.67 was changed to 8.66 to work; 8.66 is a new result
    stri_detect_regex(dataframe2string(text$sp, addRowNames = FALSE,
                                       digits = 2), "8.66  -6.5 \\n"))
  expect_true(stri_detect_regex(dataframe2string(text$sp, addRowNames = TRUE,
                                                 digits = 2), "Age\\n2d2"))
  expect_true(stri_detect_regex(dataframe2string(text$sp, addRowNames = FALSE,
                                                 digits = 2), "Age\\nd2"))
  expect_true(stri_detect_regex(dataframe2string(text$sp[0, ],
                                                 addRowNames = FALSE,
                                                 digits = 2),
                                "(or 0-length row names)"))
  expect_true(stri_detect_regex(dataframe2string(text$sp[, 0],
                                                 addRowNames = FALSE,
                                                 digits = 2),
                                "data frame with 0 columns and 3 rows"))
  expect_true(stri_detect_regex(dataframe2string(
    data.frame(text$sp, row.names = NULL), addRowNames = FALSE,
    digits = 2), "Age\\nd2"))
})
