## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by test_appendColonySnapshot.R, test_calcSnapshotDeltas.R,
## test_plotSnapshotTrends.R and test_exampleSnapshotHistoryValues.R (S1071,
## which found four copies): the shipped example snapshot history, read and
## validated by checkSnapshotHistory().

validatedSnapshotHistory <- function() {
  checkSnapshotHistory(read.csv(system.file(
    "extdata", "examples", "example_snapshot_history.csv",
    package = "nprcgenekeepr"
  ), stringsAsFactors = FALSE))
}
