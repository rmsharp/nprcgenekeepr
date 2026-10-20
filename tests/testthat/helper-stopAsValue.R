## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## The value of `expr`, or `STOP: <message>` when it stops. One failing case
## then does not end its test_that() block before the next expectation runs,
## and an expectation compares the stop with what was expected.
stopAsValue <- function(expr) {
  tryCatch(expr, error = function(e) paste("STOP:", conditionMessage(e)))
}
