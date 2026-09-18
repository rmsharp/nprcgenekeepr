## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #148 Slice 4): .buildMhcExportManifest() -- the internal
## one-row, non-sensitive record of how a de-identified MHC haplotype
## export was produced (plan D6, the .buildSequenceExportManifest() mold):
## timestamp, package version, the exported tables' sizes, the D4 rarity
## thresholds in force, the D3/D4 counts (animals, calls, missing,
## uncertain, frequency denominator), and the confirm-gate warning text.
## Without the thresholds and denominator an exported rare-haplotype report
## is uninterpretable; like its mold it never carries an id or the id map.

library(testthat)

i148Frequency <- mhcHaplotypeFrequency(rhesusGenotypes)
i148Carriers <- mhcHaplotypeCarriers(rhesusGenotypes)

test_that(".buildMhcExportManifest returns the one-row manifest contract", {
  manifest <- nprcgenekeepr:::.buildMhcExportManifest(
    summary = i148Frequency$summary, carriers = i148Carriers,
    counts = i148Frequency$counts, rareFrequencyThreshold = 0.01,
    rareCarrierThreshold = 2L, warningText = "the warning shown"
  )
  expect_s3_class(manifest, "data.frame")
  expect_identical(nrow(manifest), 1L)
  expect_named(manifest, c("timestamp", "packageVersion", "nHaplotypes",
                           "nRareHaplotypes", "nCarrierRows",
                           "rareFrequencyThreshold", "rareCarrierThreshold",
                           "nAnimals", "nCalls", "nMissing", "nUncertain",
                           "denominator", "warningText"))
})

test_that(".buildMhcExportManifest records the bundled file's sizes, thresholds and counts", {
  manifest <- nprcgenekeepr:::.buildMhcExportManifest(
    summary = i148Frequency$summary, carriers = i148Carriers,
    counts = i148Frequency$counts, rareFrequencyThreshold = 0.01,
    rareCarrierThreshold = 2L, warningText = "the warning shown"
  )
  expect_identical(manifest$nHaplotypes, 33L)
  expect_identical(manifest$nRareHaplotypes, 26L)
  expect_identical(manifest$nCarrierRows, 32L)
  expect_identical(manifest$rareFrequencyThreshold, 0.01)
  expect_identical(manifest$rareCarrierThreshold, 2L)
  expect_identical(manifest$nAnimals, 31L)
  expect_identical(manifest$nCalls, 62L)
  expect_identical(manifest$nMissing, 0L)
  expect_identical(manifest$nUncertain, 2L)
  expect_identical(manifest$denominator, 60L)
  expect_identical(manifest$warningText, "the warning shown")
  expect_identical(manifest$packageVersion, getVersion(date = FALSE))
})

test_that(".buildMhcExportManifest handles a zero-row carrier table", {
  noneRare <- mhcHaplotypeFrequency(rhesusGenotypes,
                                    rareCarrierThreshold = 0L)
  noCarriers <- mhcHaplotypeCarriers(rhesusGenotypes,
                                     rareCarrierThreshold = 0L)
  manifest <- nprcgenekeepr:::.buildMhcExportManifest(
    summary = noneRare$summary, carriers = noCarriers,
    counts = noneRare$counts, rareFrequencyThreshold = 0.01,
    rareCarrierThreshold = 0L, warningText = "w"
  )
  expect_identical(nrow(manifest), 1L)
  expect_identical(manifest$nRareHaplotypes, 0L)
  expect_identical(manifest$nCarrierRows, 0L)
})

test_that(".buildMhcExportManifest never carries an animal id", {
  manifest <- nprcgenekeepr:::.buildMhcExportManifest(
    summary = i148Frequency$summary, carriers = i148Carriers,
    counts = i148Frequency$counts, rareFrequencyThreshold = 0.01,
    rareCarrierThreshold = 2L, warningText = "the warning shown"
  )
  expect_false("id" %in% names(manifest))
  expect_false(any(unlist(manifest) %in% rhesusGenotypes$id))
})
