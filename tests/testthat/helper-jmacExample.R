## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by test_modInput_blankCells.R and test_jmacExampleData.R: where the
## shipped Japanese macaque example pedigree is. "" when it is not installed,
## so a caller skips on `path == ""`.

jmacExamplePath <- function() {
  system.file("extdata", "examples", "deidentified_jmac_ped.csv",
              package = "nprcgenekeepr")
}
