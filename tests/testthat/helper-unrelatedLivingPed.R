## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by the Breeding Groups module tests that need animals to form groups
## from (test_modBreedingGroups_groupsOutsidePedigree.R,
## test_modBreedingGroups_groupLabels.R): twenty unrelated living animals, so
## every group formation succeeds.

unrelatedLivingPed <- function(ids = paste0("A", 1:20)) {
  data.frame(
    id = ids,
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), length.out = length(ids)),
    birth = as.Date("2015-01-01"),
    exit = as.Date(NA),
    stringsAsFactors = FALSE
  )
}
