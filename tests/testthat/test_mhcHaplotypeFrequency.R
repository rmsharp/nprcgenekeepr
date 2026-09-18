## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #148 Slice 2): mhcHaplotypeFrequency() -- per-haplotype
## frequency and rare-haplotype summary (design plan D4/D5, ratified
## S704). Contract (plan sec 4 row 3): list(summary, counts); summary =
## one row per DISTINCT CERTAIN haplotype -- haplotype, nCopies,
## nCarriers, nUncertain, frequency, isRare; counts = one-row data.frame
## nAnimals, nCalls, nMissing, nUncertain, denominator. Denominator =
## certain calls among genotyped animals (2N - missing - uncertain, the
## D3 exclude-and-disclose rule). isRare = frequency <=
## rareFrequencyThreshold OR nCarriers <= rareCarrierThreshold (D4 dual
## criterion, both "<=" -- Kanthaswamy's "0.01 or lower"). nCarriers
## counts CERTAIN carriers only: counting the real file's one provisional
## carrier would move A008_B015b to 3 carriers and break the plan's own
## ratified 26-flagged pin (measured S706). A homozygote adds 2 copies /
## 1 carrier. An uncertain-only label ("never counted as a distinct
## haplotype", D3) gets NO summary row -- it is disclosed in the
## file-level counts only. stop() on malformed thresholds; input is
## re-validated defensively via checkMhcHaplotypeFile().
##
## Fixture: 7 synthetic animals (hand-computed expectations) covering
## missing calls, uncertain calls, a certain homozygote, an
## uncertain-only label, and a provisional carrier -- plus the bundled
## real pair pinning the plan sec 2.1 measured numbers.

statsFixture <- data.frame(
  id = c("A1", "A2", "A3", "A4", "A5", "A6", "A7"),
  haplotype1 = c("H01", "H01", "H02?", NA, "H01", "H99?", "H02?"),
  haplotype2 = c("H01", "H03", "H02", "H03", "", "H03", "H01"),
  stringsAsFactors = FALSE
)
## Hand-computed: 14 calls; missing 2 (A4.h1, A5.h2); uncertain 3
## (A3 "H02?", A6 "H99?", A7 "H02?"); denominator 14 - 2 - 3 = 9.
## Certain calls: H01 x5 (A1 x2, A2, A5, A7), H02 x1 (A3), H03 x3
## (A2, A4, A6). H99 exists ONLY as an uncertain call.

test_that("mhcHaplotypeFrequency returns the list(summary, counts) contract", {
  result <- mhcHaplotypeFrequency(statsFixture)
  expect_type(result, "list")
  expect_identical(names(result), c("summary", "counts"))
  expect_s3_class(result$summary, "data.frame")
  expect_identical(names(result$summary),
                   c("haplotype", "nCopies", "nCarriers", "nUncertain",
                     "frequency", "isRare"))
  expect_type(result$summary$haplotype, "character")
  expect_type(result$summary$nCopies, "integer")
  expect_type(result$summary$nCarriers, "integer")
  expect_type(result$summary$nUncertain, "integer")
  expect_type(result$summary$frequency, "double")
  expect_type(result$summary$isRare, "logical")
  expect_s3_class(result$counts, "data.frame")
  expect_identical(nrow(result$counts), 1L)
  expect_identical(names(result$counts),
                   c("nAnimals", "nCalls", "nMissing", "nUncertain",
                     "denominator"))
  expect_true(all(vapply(result$counts, is.integer, logical(1L))))
})

test_that("summary rows match the hand-computed fixture values", {
  summary <- mhcHaplotypeFrequency(statsFixture)$summary
  ## Alphabetical by haplotype; a homozygote (A1) adds 2 copies, 1
  ## carrier; A3's certain H02 call makes it a carrier even though its
  ## other call of H02 is uncertain.
  expect_identical(summary$haplotype, c("H01", "H02", "H03"))
  expect_identical(summary$nCopies, c(5L, 1L, 3L))
  expect_identical(summary$nCarriers, c(4L, 1L, 3L))
  expect_identical(summary$nUncertain, c(0L, 2L, 0L))
  expect_equal(summary$frequency, c(5, 1, 3) / 9)
  ## D4 defaults (0.01 / 2): only H02 (1 carrier) flags -- the frequency
  ## leg cannot fire at denominator 9.
  expect_identical(summary$isRare, c(FALSE, TRUE, FALSE))
})

test_that("counts are the hand-computed file-level totals", {
  counts <- mhcHaplotypeFrequency(statsFixture)$counts
  expect_identical(counts$nAnimals, 7L)
  expect_identical(counts$nCalls, 14L)
  expect_identical(counts$nMissing, 2L)
  expect_identical(counts$nUncertain, 3L)
  expect_identical(counts$denominator, 9L)
})

test_that("an uncertain-only label gets no summary row, only counts", {
  result <- mhcHaplotypeFrequency(statsFixture)
  ## H99 appears only as "H99?" -- never counted as a distinct haplotype
  ## (D3): no summary row, but its call IS disclosed in the file-level
  ## nUncertain (3), which therefore exceeds the per-haplotype column's
  ## total (2, both calls of H02).
  expect_false("H99" %in% result$summary$haplotype)
  expect_identical(result$counts$nUncertain, 3L)
  expect_identical(sum(result$summary$nUncertain), 2L)
})

test_that("both rarity legs use <= (boundary equality flags)", {
  ## Frequency leg alone (carrier leg disabled at 0): threshold exactly
  ## equal to H02's frequency (1/9) must flag it -- "0.01 or lower"
  ## semantics, <= not < -- while a threshold just below must not.
  atBoundary <- mhcHaplotypeFrequency(statsFixture,
                                      rareFrequencyThreshold = 1 / 9,
                                      rareCarrierThreshold = 0L)$summary
  expect_identical(atBoundary$isRare[atBoundary$haplotype == "H02"], TRUE)
  belowBoundary <- mhcHaplotypeFrequency(statsFixture,
                                         rareFrequencyThreshold = 0.11,
                                         rareCarrierThreshold = 0L)$summary
  expect_identical(belowBoundary$isRare[belowBoundary$haplotype == "H02"],
                   FALSE)
  ## Carrier leg alone (frequency leg disabled at 0): carriers exactly
  ## equal to the threshold (H03, 3 carriers) must flag; above (H01, 4)
  ## must not.
  carrierLeg <- mhcHaplotypeFrequency(statsFixture,
                                      rareFrequencyThreshold = 0,
                                      rareCarrierThreshold = 3L)$summary
  expect_identical(carrierLeg$isRare, c(FALSE, TRUE, TRUE))
})

test_that("malformed thresholds stop with an error naming the parameter", {
  expect_error(mhcHaplotypeFrequency(statsFixture,
                                     rareFrequencyThreshold = "0.01"),
               "rareFrequencyThreshold")
  expect_error(mhcHaplotypeFrequency(statsFixture,
                                     rareFrequencyThreshold = -0.01),
               "rareFrequencyThreshold")
  expect_error(mhcHaplotypeFrequency(statsFixture,
                                     rareFrequencyThreshold = NA_real_),
               "rareFrequencyThreshold")
  expect_error(mhcHaplotypeFrequency(statsFixture,
                                     rareFrequencyThreshold = c(0.01, 0.05)),
               "rareFrequencyThreshold")
  expect_error(mhcHaplotypeFrequency(statsFixture,
                                     rareCarrierThreshold = "2"),
               "rareCarrierThreshold")
  expect_error(mhcHaplotypeFrequency(statsFixture,
                                     rareCarrierThreshold = -1L),
               "rareCarrierThreshold")
  expect_error(mhcHaplotypeFrequency(statsFixture,
                                     rareCarrierThreshold = NA_integer_),
               "rareCarrierThreshold")
  expect_error(mhcHaplotypeFrequency(statsFixture,
                                     rareCarrierThreshold = c(1L, 2L)),
               "rareCarrierThreshold")
})

test_that("input is re-validated defensively via checkMhcHaplotypeFile", {
  expect_error(
    mhcHaplotypeFrequency(data.frame(id = "A1", haplotype1 = "H01")),
    "exactly three columns"
  )
  expect_error(
    mhcHaplotypeFrequency(data.frame(
      id = c("A1", "A1"),
      haplotype1 = c("H01", "H02"),
      haplotype2 = c("H01", "H02"),
      stringsAsFactors = FALSE
    )),
    "duplicate id"
  )
})

test_that("an all-missing/uncertain file yields an empty summary", {
  degenerate <- data.frame(
    id = c("D1", "D2"),
    haplotype1 = c(NA, "X?"),
    haplotype2 = c("", "Y?"),
    stringsAsFactors = FALSE
  )
  result <- mhcHaplotypeFrequency(degenerate)
  expect_identical(nrow(result$summary), 0L)
  expect_identical(names(result$summary),
                   c("haplotype", "nCopies", "nCarriers", "nUncertain",
                     "frequency", "isRare"))
  expect_identical(result$counts$nAnimals, 2L)
  expect_identical(result$counts$nCalls, 4L)
  expect_identical(result$counts$nMissing, 2L)
  expect_identical(result$counts$nUncertain, 2L)
  expect_identical(result$counts$denominator, 0L)
})

test_that("the bundled real pair reproduces the plan's measured numbers", {
  ## docs/planning/issue148-mhc-haplotype-reporting-plan.md sec 2.1 / D4,
  ## measured S704, re-derived S706: 31 animals / 62 calls / 0 missing /
  ## 2 uncertain / 33 distinct certain labels over denominator 60; at the
  ## D4 defaults 26/33 flag, ALL via the carrier leg (a singleton is
  ## 1/60 ~ 0.017, so the frequency leg flags 0); top frequency 0.100
  ## (A004_B001a, 6 copies); 21 singletons. Dragon 1: these pins make
  ## any future change to the defaults a visible, deliberate break.
  result <- mhcHaplotypeFrequency(rhesusGenotypes)
  summary <- result$summary
  expect_identical(nrow(summary), 33L)
  expect_identical(result$counts$nAnimals, 31L)
  expect_identical(result$counts$nCalls, 62L)
  expect_identical(result$counts$nMissing, 0L)
  expect_identical(result$counts$nUncertain, 2L)
  expect_identical(result$counts$denominator, 60L)
  expect_identical(sum(summary$isRare), 26L)
  ## All flagging is the carrier leg's: no frequency at or below 0.01.
  expect_identical(sum(summary$frequency <= 0.01), 0L)
  expect_true(all(summary$nCarriers[summary$isRare] <= 2L))
  ## A008_B015b: 2 certain copies/carriers + 1 uncertain call disclosed;
  ## flagged rare via the carrier leg. The provisional carrier (0F4FY1)
  ## does NOT count toward nCarriers -- counting it would give 3 and
  ## unflag the haplotype, breaking the ratified 26.
  b015b <- summary[summary$haplotype == "A008_B015b", ]
  expect_identical(b015b$nCopies, 2L)
  expect_identical(b015b$nCarriers, 2L)
  expect_identical(b015b$nUncertain, 1L)
  expect_identical(b015b$isRare, TRUE)
  ## A002a_B015 exists only as an uncertain call: no summary row (D3).
  expect_false("A002a_B015" %in% summary$haplotype)
  ## Top haplotype and singleton spread.
  top <- summary[summary$haplotype == "A004_B001a", ]
  expect_identical(top$nCopies, 6L)
  expect_equal(top$frequency, 0.1)
  expect_identical(sum(summary$nCopies == 1L), 21L)
  ## Deterministic alphabetical ordering.
  expect_false(is.unsorted(summary$haplotype))
})
