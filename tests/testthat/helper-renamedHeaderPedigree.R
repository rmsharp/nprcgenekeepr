## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the renamed-header tests (test_checkChangedColsLst.R,
## test_runQcStudbook.R, test_modInput_qcStudbook.R; S988): the six-animal
## pedigree of datePed() (helper-datePedigree.R, whose headers need no change)
## with a `geographicorigin` column whose header is all lowercase. qcStudbook()
## renames that header to geographicOrigin, and that rename is the only change
## it makes to this file's headers.

pedLowercaseGeographicOrigin <- function() {
  ped <- datePed(recordStatus = NULL)
  ped$geographicorigin <- rep(c("India", "China"), 3L)
  ped
}
