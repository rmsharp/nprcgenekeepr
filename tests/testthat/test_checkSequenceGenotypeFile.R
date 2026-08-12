## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #152 Slice 1 (RED): checkSequenceGenotypeFile(genotype, locusMetadata = NULL,
# maxLoci = 50000L) is a new, sibling validator to checkMarkerGenotypeFile() (D2/D4,
# docs/planning/issue152-sequence-input-genetic-metrics-plan.md sec 4 interface catalog):
# same 4-column long-format id/locus/allele1/allele2 schema, same column-count/
# first-column/duplicate-row/biallelic-only checks (sec 2.2), PLUS two new rules this
# design adds: (1) a literal "." allele value (the VCF missing-genotype placeholder) is
# rejected as a first-class malformed-input case (sec 7 Dragon 4) rather than silently
# mis-counted as a real allele; (2) a panel above the D1 ~50,000-locus scope-tier ceiling
# gets a soft warning(), not a hard stop() (sec 7 Dragon 2), via an overridable maxLoci
# parameter (this session's own PRE-RED decision, mirroring
# markerParentageExclusion()'s own documented maxExclusions-default precedent).
#
# Return contract: unlike the plan's own interface-catalog wording ("TRUE invisibly"),
# this session's PRE-RED (AskUserQuestion) chose to return the checked/coerced
# dataframe, matching the actual established sibling-validator convention
# (checkMarkerGenotypeFile(), checkLinkageMarkerGenotypeFile(), checkLocusMetadata()
# all return the checked dataframe) over the plan's literal wording, which predates
# issue #153's own convention-setting implementation.
#
# Also validates an optional locusMetadata sidecar (D3) by REUSING checkLocusMetadata()
# (already shipped as issue #153 Slice 1, S520 -- its own roxygen docs credit #152's
# design decision as the schema's origin) rather than reinventing a second validator.
#
# This file also covers Slice 1's fixture DONE criterion: a new synthetic sequence-scale
# fixture pair (data-raw/generate_sequence_fixtures.R, GREEN work), sized to D1's
# lower-middle scope-tier range (1,000 loci x 50 individuals -- this session's own
# PRE-RED AskUserQuestion, weighed against every existing bundled fixture topping out at
# 271 KB), round-trips through checkSequenceGenotypeFile() and the existing, UNMODIFIED
# buildMarkerGenotypeMatrix() -- "reusable by every later slice" per the plan's own
# Slice 1 DONE criterion. Its locusMetadata sidecar is deliberately 100% "full" coverage
# (unlike issue #153's own STR fixture, which deliberately models a realistic sparse
# mix) because this fixture's stated purpose is scale/performance exercise (Slice 2) and
# reuse by the future F_ROH metric (Slice 3), which needs position data for every locus
# to define contiguous homozygous runs -- sparse coverage would silently narrow what
# later slices can test against it.

smallGenotype <- function() {
  ## 3 individuals x 3 loci. L1: alleles {A, T} (2, biallelic). L2: alleles
  ## {C, A} (2, biallelic). L3: alleles {G} (1, monomorphic -- still legal,
  ## the rejection rule is ">2 distinct alleles", not "!=2").
  data.frame(
    id = c("A", "A", "A", "B", "B", "B", "C", "C", "C"),
    locus = c("L1", "L2", "L3", "L1", "L2", "L3", "L1", "L2", "L3"),
    allele1 = c("A", "C", "G", "A", "C", "G", "T", "C", "G"),
    allele2 = c("A", "C", "G", "T", "C", "G", "T", "A", "G"),
    stringsAsFactors = FALSE
  )
}

smallLocusMetadata <- function() {
  data.frame(
    locus = c("L1", "L2", "L3"),
    chrom = c("1", "1", "2"),
    pos = c(1000L, 5000L, 20000L),
    stringsAsFactors = FALSE
  )
}

bigGenotype <- function(nLoci) {
  ## One individual, nLoci distinct loci, each biallelic (A/G) -- large
  ## enough to exercise the D1 panel-size warning path without needing the
  ## committed fixture and without any risk of tripping the biallelic-only
  ## or duplicate-row checks.
  data.frame(
    id = rep("X", nLoci),
    locus = sprintf("L%05d", seq_len(nLoci)),
    allele1 = rep("A", nLoci),
    allele2 = rep("G", nLoci),
    stringsAsFactors = FALSE
  )
}

# ---------------------------------------------------------------------------
# Group A -- structural checks (mirrors checkMarkerGenotypeFile()'s own rule
# set, sec 2.2), except the return value: the checked dataframe, not TRUE.
# ---------------------------------------------------------------------------

test_that("checkSequenceGenotypeFile accepts a valid biallelic long-format table and returns the checked dataframe", {
  checked <- checkSequenceGenotypeFile(smallGenotype())
  expect_s3_class(checked, "data.frame")
  expect_identical(names(checked), c("id", "locus", "allele1", "allele2"))
  expect_identical(nrow(checked), 9L)
})

test_that("checkSequenceGenotypeFile requires exactly four columns", {
  expect_error(
    checkSequenceGenotypeFile(smallGenotype()[, c("id", "locus", "allele1")]),
    "Marker genotype file must have exactly four columns",
    fixed = TRUE
  )
})

test_that("checkSequenceGenotypeFile requires 'id' as the first column", {
  bad <- smallGenotype()
  names(bad) <- c("animal", "locus", "allele1", "allele2")
  expect_error(
    checkSequenceGenotypeFile(bad),
    "Marker genotype file must have 'id' as the first column.",
    fixed = TRUE
  )
})

test_that("checkSequenceGenotypeFile rejects a duplicate id x locus row", {
  dup <- rbind(smallGenotype(), smallGenotype()[1L, ])
  expect_error(
    checkSequenceGenotypeFile(dup),
    "duplicate",
    ignore.case = TRUE
  )
})

test_that("checkSequenceGenotypeFile forces output column names, matching checkMarkerGenotypeFile's contract", {
  renamed <- smallGenotype()
  names(renamed) <- c("ID", "LOCUS", "ALLELE1", "ALLELE2")
  checked <- checkSequenceGenotypeFile(renamed)
  expect_identical(names(checked), c("id", "locus", "allele1", "allele2"))
})

# ---------------------------------------------------------------------------
# Group B -- biallelic-only rule, unchanged from D2.
# ---------------------------------------------------------------------------

test_that("checkSequenceGenotypeFile rejects a locus with more than two distinct alleles (biallelic-only, unchanged from D2)", {
  triallelic <- rbind(
    smallGenotype(),
    data.frame(id = "D", locus = "L1", allele1 = "C", allele2 = "C",
               stringsAsFactors = FALSE)
  )
  expect_error(
    checkSequenceGenotypeFile(triallelic),
    "more than two",
    ignore.case = TRUE
  )
})

test_that("checkMarkerGenotypeFile itself is unchanged -- the same triallelic input is still rejected there too (zero edits to that file this slice)", {
  triallelic <- rbind(
    smallGenotype(),
    data.frame(id = "D", locus = "L1", allele1 = "C", allele2 = "C",
               stringsAsFactors = FALSE)
  )
  expect_error(checkMarkerGenotypeFile(triallelic), "L1", fixed = TRUE)
})

# ---------------------------------------------------------------------------
# Group C -- Dragon 4: a literal "." allele value (VCF's missing-genotype
# placeholder) is a first-class malformed-input case, not an afterthought.
# ---------------------------------------------------------------------------

test_that("checkSequenceGenotypeFile rejects a literal '.' allele value as a malformed VCF-style missingness placeholder", {
  dotted <- smallGenotype()
  dotted$allele2[1L] <- "."
  expect_error(
    checkSequenceGenotypeFile(dotted),
    "literal '.'",
    fixed = TRUE
  )
})

test_that("checkSequenceGenotypeFile treats a genuine NA allele as valid missingness, not an error", {
  naGenotype <- smallGenotype()
  naGenotype$allele2[1L] <- NA
  expect_error(checkSequenceGenotypeFile(naGenotype), NA)
})

test_that("checkSequenceGenotypeFile reports the '.' placeholder specifically, not a misleading 'more than two alleles' message", {
  ## L1 already has 2 real alleles (A, T) in smallGenotype(); adding a "."
  ## at a 3rd L1 row would look like a 3rd distinct allele to a naive
  ## allele-count check. The literal-"." check must run BEFORE the
  ## biallelic-count check so the curator sees the correct, actionable
  ## error, not a confusing "more than two distinct alleles" report.
  dotted <- smallGenotype()
  dotted$allele2[4L] <- "." ## row 4 = id B, locus L1
  msg <- tryCatch(checkSequenceGenotypeFile(dotted),
                   error = function(e) conditionMessage(e))
  expect_match(msg, "literal '.'", fixed = TRUE)
  expect_false(grepl("more than two", msg, ignore.case = TRUE))
})

# ---------------------------------------------------------------------------
# Group D -- D1 panel-size soft warning (sec 7 Dragon 2), overridable via
# maxLoci (default 50000L, this session's own PRE-RED decision).
# ---------------------------------------------------------------------------

test_that("checkSequenceGenotypeFile warns, but does not stop, when locus count exceeds the default 50000L ceiling (D1)", {
  big <- bigGenotype(50001L)
  expect_warning(checkSequenceGenotypeFile(big), "50000", fixed = TRUE)
  checked <- suppressWarnings(checkSequenceGenotypeFile(big))
  expect_s3_class(checked, "data.frame")
})

test_that("checkSequenceGenotypeFile does not warn when locus count is at or below the default ceiling", {
  expect_warning(checkSequenceGenotypeFile(smallGenotype()), NA)
})

test_that("checkSequenceGenotypeFile's maxLoci parameter is overridable downward -- a small panel warns under a small ceiling", {
  ## smallGenotype() has 3 distinct loci (L1, L2, L3).
  expect_warning(
    checkSequenceGenotypeFile(smallGenotype(), maxLoci = 2L),
    "2",
    fixed = TRUE
  )
})

test_that("checkSequenceGenotypeFile's maxLoci parameter is overridable upward -- suppresses the warning on a panel that would otherwise exceed the default", {
  big <- bigGenotype(50001L)
  expect_warning(checkSequenceGenotypeFile(big, maxLoci = 100000L), NA)
})

# ---------------------------------------------------------------------------
# Group E -- optional locusMetadata sidecar (D3), validated by REUSING
# checkLocusMetadata() rather than reinventing a second validator.
# ---------------------------------------------------------------------------

test_that("checkSequenceGenotypeFile propagates checkLocusMetadata()'s own error on a malformed sidecar (reuse, not reinvent)", {
  badMetadata <- smallLocusMetadata()[, c("locus", "chrom")] ## too few columns
  expect_error(
    checkSequenceGenotypeFile(smallGenotype(), locusMetadata = badMetadata),
    "Locus metadata must have three or four columns",
    fixed = TRUE
  )
})

test_that("checkSequenceGenotypeFile accepts a valid locusMetadata sidecar without changing its own return shape", {
  withMeta <- checkSequenceGenotypeFile(smallGenotype(),
                                         locusMetadata = smallLocusMetadata())
  withoutMeta <- checkSequenceGenotypeFile(smallGenotype())
  expect_identical(withMeta, withoutMeta)
})

# ---------------------------------------------------------------------------
# Group F -- committed fixture pair (data-raw/generate_sequence_fixtures.R,
# GREEN work): 1,000 loci x 50 individuals, D10's lower-middle scope-tier
# size, full locusMetadata coverage throughout (reusable by the future F_ROH
# metric, Slice 3).
# ---------------------------------------------------------------------------

test_that("the committed sequence-scale locusMetadata fixture (1,000 loci, full coverage) is valid per checkLocusMetadata()", {
  ## No skip_if() guard: system.file() returns "" when the fixture doesn't
  ## exist yet, and read.csv("") errors -- this test must genuinely FAIL at
  ## RED, not skip, until GREEN commits the fixture (data-raw/
  ## generate_sequence_fixtures.R).
  path <- system.file(
    "extdata", "examples", "example_sequence_locus_metadata.csv",
    package = "nprcgenekeepr"
  )
  locusMetadata <- read.csv(path, stringsAsFactors = FALSE)
  out <- checkLocusMetadata(locusMetadata)
  expect_identical(nrow(out), 1000L)
  expect_true(all(out$coverage == "full"))
})

test_that("the committed sequence-scale genotype fixture (50 individuals x 1,000 loci) round-trips through checkSequenceGenotypeFile() and the existing, unmodified buildMarkerGenotypeMatrix()", {
  ## No skip_if() guard -- same rationale as the test above.
  path <- system.file(
    "extdata", "examples", "example_sequence_genotypes.csv",
    package = "nprcgenekeepr"
  )
  genotype <- read.csv(path, stringsAsFactors = FALSE)
  checked <- checkSequenceGenotypeFile(genotype)
  expect_identical(nrow(checked), 50000L)

  mat <- buildMarkerGenotypeMatrix(checked)
  expect_identical(dim(mat), c(50L, 1000L))
})
