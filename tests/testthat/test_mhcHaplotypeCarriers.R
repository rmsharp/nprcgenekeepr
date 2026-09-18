## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #148 Slice 2): mhcHaplotypeCarriers() -- the carrier
## detail table (design plan D5, ratified S704). Contract (plan sec 4
## row 4): data.frame haplotype, id, uncertain -- one row per
## (haplotype x carrying animal), ordered by haplotype then id;
## rareOnly = TRUE (default) restricts to D4-flagged haplotypes,
## FALSE lists all summary haplotypes. The haplotype universe is the
## summary's (distinct CERTAIN haplotypes) -- an uncertain-only label
## has no carrier rows (D3: never a distinct haplotype). A carrier row's
## uncertain flag is per-(haplotype x animal): FALSE when the animal has
## at least one certain call of that haplotype, TRUE when its carriage
## is only provisional (all its calls of that haplotype are uncertain) --
## the disclosure column D5 mandates ("with the carrier's uncertain
## status"). Provisional carriers are listed but never counted in the
## summary's nCarriers (see test_mhcHaplotypeFrequency.R). Thresholds
## are validated as in mhcHaplotypeFrequency(); input is re-validated
## defensively via checkMhcHaplotypeFile().
##
## Fixture: same 7 synthetic animals as test_mhcHaplotypeFrequency.R --
## certain calls H01 x5 (A1 homozygote, A2, A5, A7), H02 x1 (A3),
## H03 x3 (A2, A4, A6); uncertain calls A3 "H02?", A6 "H99?" (an
## uncertain-only label), A7 "H02?" (a provisional carrier of H02);
## missing A4.h1, A5.h2. At the D4 defaults only H02 is rare (1 certain
## carrier).

statsFixture <- data.frame(
  id = c("A1", "A2", "A3", "A4", "A5", "A6", "A7"),
  haplotype1 = c("H01", "H01", "H02?", NA, "H01", "H99?", "H02?"),
  haplotype2 = c("H01", "H03", "H02", "H03", "", "H03", "H01"),
  stringsAsFactors = FALSE
)

test_that("mhcHaplotypeCarriers returns the carrier-table contract", {
  carriers <- mhcHaplotypeCarriers(statsFixture)
  expect_s3_class(carriers, "data.frame")
  expect_identical(names(carriers), c("haplotype", "id", "uncertain"))
  expect_type(carriers$haplotype, "character")
  expect_type(carriers$id, "character")
  expect_type(carriers$uncertain, "logical")
})

test_that("rareOnly = TRUE (default) lists rare-haplotype carriers only", {
  carriers <- mhcHaplotypeCarriers(statsFixture)
  ## Only H02 is D4-flagged. Its carriers: A3 (has a certain H02 call ->
  ## uncertain FALSE, even though its other H02 call is uncertain) and
  ## A7 (only an uncertain H02 call -> a provisional carrier, TRUE).
  ## Ordered by haplotype then id.
  expect_identical(carriers$haplotype, c("H02", "H02"))
  expect_identical(carriers$id, c("A3", "A7"))
  expect_identical(carriers$uncertain, c(FALSE, TRUE))
})

test_that("rareOnly = FALSE lists every summary haplotype's carriers", {
  carriers <- mhcHaplotypeCarriers(statsFixture, rareOnly = FALSE)
  ## H01: A1 (homozygote -- exactly ONE row), A2, A5, A7; H02: A3, A7;
  ## H03: A2, A4, A6. H99 is uncertain-only: no summary row, no carrier
  ## rows.
  expect_identical(nrow(carriers), 9L)
  expect_identical(carriers$haplotype,
                   c(rep("H01", 4L), rep("H02", 2L), rep("H03", 3L)))
  expect_identical(carriers$id,
                   c("A1", "A2", "A5", "A7", "A3", "A7", "A2", "A4", "A6"))
  expect_identical(carriers$uncertain,
                   c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE,
                     FALSE))
  expect_false("H99" %in% carriers$haplotype)
  expect_identical(sum(carriers$haplotype == "H01" & carriers$id == "A1"),
                   1L)
})

test_that("custom thresholds change which carriers rareOnly returns", {
  ## Carrier leg at 3, frequency leg disabled: H02 (1 <= 3) and H03
  ## (3 <= 3) are rare; H01 (4 carriers) is not.
  carriers <- mhcHaplotypeCarriers(statsFixture,
                                   rareFrequencyThreshold = 0,
                                   rareCarrierThreshold = 3L)
  expect_identical(nrow(carriers), 5L)
  expect_setequal(unique(carriers$haplotype), c("H02", "H03"))
  expect_false("H01" %in% carriers$haplotype)
})

test_that("malformed thresholds and malformed input stop with an error", {
  expect_error(mhcHaplotypeCarriers(statsFixture,
                                    rareFrequencyThreshold = "0.01"),
               "rareFrequencyThreshold")
  expect_error(mhcHaplotypeCarriers(statsFixture,
                                    rareFrequencyThreshold = -0.01),
               "rareFrequencyThreshold")
  expect_error(mhcHaplotypeCarriers(statsFixture,
                                    rareCarrierThreshold = NA_integer_),
               "rareCarrierThreshold")
  expect_error(mhcHaplotypeCarriers(statsFixture,
                                    rareCarrierThreshold = c(1L, 2L)),
               "rareCarrierThreshold")
  expect_error(
    mhcHaplotypeCarriers(data.frame(id = "A1", haplotype1 = "H01")),
    "exactly three columns"
  )
})

test_that("degenerate inputs yield an empty, correctly-shaped table", {
  ## Nothing rare: both legs disabled at 0 -- no observed haplotype has
  ## frequency <= 0 or carriers <= 0.
  nothingRare <- mhcHaplotypeCarriers(statsFixture,
                                      rareFrequencyThreshold = 0,
                                      rareCarrierThreshold = 0L)
  expect_identical(nrow(nothingRare), 0L)
  expect_identical(names(nothingRare), c("haplotype", "id", "uncertain"))
  ## An all-missing/uncertain file has no summary haplotypes at all.
  degenerate <- data.frame(
    id = c("D1", "D2"),
    haplotype1 = c(NA, "X?"),
    haplotype2 = c("", "Y?"),
    stringsAsFactors = FALSE
  )
  expect_identical(nrow(mhcHaplotypeCarriers(degenerate)), 0L)
  expect_identical(nrow(mhcHaplotypeCarriers(degenerate, rareOnly = FALSE)),
                   0L)
})

test_that("the bundled real pair reproduces the measured carrier pins", {
  ## Measured S706 against the shipped Slice 1 parse of rhesusGenotypes:
  ## 60 certain (haplotype x id) pairs + exactly 1 provisional carriage
  ## (0F4FY1's uncertain A008_B015b call -- its only call of that
  ## haplotype) = 61 rows at rareOnly = FALSE; the 26 D4-flagged
  ## haplotypes carry 31 certain pairs + that same provisional row = 32
  ## rows at the defaults. GBANSD's uncertain A002a_B015 call yields NO
  ## row (uncertain-only label, no summary row), while GBANSD still
  ## appears as a CERTAIN carrier of A008_B015b -- the uncertain flag is
  ## per-(haplotype x animal), not per-animal.
  all <- mhcHaplotypeCarriers(rhesusGenotypes, rareOnly = FALSE)
  expect_identical(nrow(all), 61L)
  expect_false("A002a_B015" %in% all$haplotype)
  b015b <- all[all$haplotype == "A008_B015b", ]
  expect_setequal(b015b$id, c("ZPVN1V", "GBANSD", "0F4FY1"))
  expect_identical(b015b$uncertain[b015b$id == "0F4FY1"], TRUE)
  expect_identical(b015b$uncertain[b015b$id == "GBANSD"], FALSE)
  expect_identical(b015b$uncertain[b015b$id == "ZPVN1V"], FALSE)
  rare <- mhcHaplotypeCarriers(rhesusGenotypes)
  expect_identical(nrow(rare), 32L)
  expect_identical(length(unique(rare$haplotype)), 26L)
  expect_true("A008_B015b" %in% rare$haplotype)
  expect_identical(sum(rare$uncertain), 1L)
})
