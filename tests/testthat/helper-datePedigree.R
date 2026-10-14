## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the invalid-date tests (test_getDateErrorsAndConvertDatesInPed.R,
## test_modInput_qcStudbook.R; S987): one small made-up pedigree with a birth
## and an exit column, as ExamplePedigree.csv has, where `birth` and `exit` are
## the file's own text for each date. Row 3 has a birth and an exit date, row 5
## the same; the other animals have a birth date only.

datePedBirth <- c(
  "2000-01-05", "2000-02-06", "2005-03-07", "2006-04-08", "2007-05-09",
  "2008-06-10"
)
datePedExit <- c(NA, NA, "2015-03-07", NA, "2016-05-09", NA)

## The six animals. `recordStatus` is the column qcStudbook() adds; NULL leaves
## it out, as a file read from disk or a direct call to an exported function
## may.
datePed <- function(birth = datePedBirth, exit = datePedExit,
                    recordStatus = "original") {
  ped <- data.frame(
    id = paste0("a", 1L:6L),
    sire = c(NA, NA, "a1", "a1", "a1", "a1"),
    dam = c(NA, NA, "a2", "a2", "a2", "a2"),
    sex = c("M", "F", "M", "F", "M", "F"),
    birth = birth, exit = exit,
    stringsAsFactors = FALSE
  )
  if (!is.null(recordStatus)) {
    ped$recordStatus <- recordStatus
  }
  ped
}
