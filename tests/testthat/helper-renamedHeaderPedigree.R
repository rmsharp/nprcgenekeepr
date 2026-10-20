## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the renamed-header tests (test_checkChangedColsLst.R,
## test_runQcStudbook.R, test_modInput_qcStudbook.R; S988): the six-animal
## pedigree of datePed() (helper-datePedigree.R, whose headers need no change)
## with a `geographicorigin` column whose header is all lowercase. qcStudbook()
## renames that header to geographicOrigin, and that rename is the only change
## it makes to this file's headers.

## The text qcStudbook() records for that rename in
## changedCols$geographicoriginToGeographicOrigin.
lowercaseGeographicOriginRename <- "geographicorigin to geographicOrigin"

pedLowercaseGeographicOrigin <- function() {
  ped <- datePed(recordStatus = NULL)
  ped$geographicorigin <- rep(c("India", "China"), 3L)
  ped
}

## The same for the other two camel case headers (S1020, BACKLOG.md:168): a
## file whose only change is an all-lowercase `recordstatus` or `fromcenter`
## header, and the text qcStudbook() records for each rename.
lowercaseRecordStatusRename <- "recordstatus to recordStatus"
lowercaseFromCenterRename <- "fromcenter to fromCenter"

pedLowercaseRecordStatus <- function() {
  ped <- datePed(recordStatus = NULL)
  ped$recordstatus <- "original"
  ped
}

pedLowercaseFromCenter <- function() {
  ped <- datePed(recordStatus = NULL)
  ped$fromcenter <- rep(c("yes", "no"), 3L)
  ped
}
