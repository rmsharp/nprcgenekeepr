## Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
library(testthat)

test_that("obfuscatePed creates correctly obfuscated pedigree", {
  pedSix <- qcStudbook(nprcgenekeepr::pedSix)
  ped <- obfuscatePed(pedSix, size = 3L, maxDelta = 20L)
  expect_identical(nrow(ped), nrow(pedSix))
  expect_identical(ncol(ped), ncol(pedSix))
  expect_identical(ped$id[1L], ped$dam[7L])
  expect_identical(ped$id[1L], ped$dam[7L])
  expect_true(all(ped$id[2L] == ped$dam[c(8L, 11L, 12L)]))
  expect_true(max(abs(pedSix$birth[!is.na(pedSix$birth)] -
    ped$birth[!is.na(ped$birth)])) <= 20L)
})
test_that("obfuscatePed creates ID map on request", {
  pedSix <- qcStudbook(nprcgenekeepr::pedSix)
  ped <- obfuscatePed(pedSix, size = 3L, maxDelta = 20L, map = TRUE)
  expect_true(class(ped) == "list")
  expect_named(ped, c("ped", "map"))
  expect_s3_class(ped$ped, "data.frame")
  expect_identical(class(ped$map), "character")
  expect_named(ped$map, pedSix$id)
  expect_identical(as.character(ped$map), ped$ped$id)
})
test_that("obfuscatePed drops name values to NA (issue #136 D8)", {
  # A name is the only genuinely PII-shaped field this package has ever
  # contemplated (docs/planning/issue136-name-labels-pedigree-diagram-
  # plan.md sec 2.6): obfuscatePed() must scrub it in the same slice that
  # introduces the column, or a "de-identified" export would carry scrubbed
  # ids alongside intact real names.
  pedSix <- qcStudbook(nprcgenekeepr::pedSix)
  pedSix$name <- paste0("Name", seq_len(nrow(pedSix)))
  ped <- obfuscatePed(pedSix, size = 3L, maxDelta = 20L)
  expect_true(all(is.na(ped$name)))
})

test_that("obfuscatePed with linkedDateShift = TRUE (explicit) shifts every Date column of one individual by the same offset, preserving exact gaps and never producing a negative age (issue #150 D3)", {
  # docs/planning/issue150-deidentified-pedigree-export-plan.md sec 2.4: the
  # OLD behavior calls obfuscateDate() once per Date column independently,
  # which can invert birth/exit order for a short-lived individual. Empirically
  # reproduced against this exact fixture in Session 514: 2 of 8 individuals
  # get a negative recomputed age. linkedDateShift = TRUE must close this by
  # drawing exactly ONE random offset per individual and applying it to every
  # Date column for that row -- so the invariance assertion (gap unchanged),
  # not just a bounds assertion (age >= 0), is the correct proof (Dragon 2:
  # a bounds-only test could pass by luck on some seeds while the underlying
  # per-column-independent mechanism is still wrong).
  #
  # Uses set_seed() (this package's own R-version-agnostic RNG pinning
  # helper, R/set_seed.R), not base set.seed() -- set_seed() forces
  # RNGkind(sample.kind = "Rounding"), which every OTHER test file in this
  # suite that calls set_seed() also leaves in place globally for the rest
  # of the testthat session. A bare set.seed() call here would silently
  # inherit whatever RNGkind an earlier-run test file left behind, making
  # this test's outcome depend on test execution order (verified: the
  # obfuscateId() alias draw consumes runif()/sample() state ahead of the
  # date-shift draws, so a different sample.kind changes which offsets get
  # drawn). set_seed() is idempotent/order-independent by construction.
  ped <- qcStudbook(nprcgenekeepr::pedGood)
  ped$exit <- ped$birth + 10L
  originalGap <- as.numeric(ped$exit - ped$birth)

  set_seed(3L)
  obf <- obfuscatePed(ped, size = 6L, maxDelta = 30L, linkedDateShift = TRUE)

  expect_equal(as.numeric(obf$exit - obf$birth), originalGap)
  expect_true(all(obf$age >= 0))
})

test_that("obfuscatePed's ratified default (linkedDateShift omitted) is the safe linked-per-individual shift, not the old independent one (issue #150 D3)", {
  # The owner ratified linkedDateShift = TRUE as the DEFAULT (sec 3 D3, sec 11
  # ratification outcome) -- an additive behavior change to an already-shipped
  # @export-ed function. This pins that default without requiring callers to
  # opt in explicitly. See set_seed() rationale in the test above.
  ped <- qcStudbook(nprcgenekeepr::pedGood)
  ped$exit <- ped$birth + 10L
  originalGap <- as.numeric(ped$exit - ped$birth)

  set_seed(3L)
  obf <- obfuscatePed(ped, size = 6L, maxDelta = 30L)

  expect_equal(as.numeric(obf$exit - obf$birth), originalGap)
  expect_true(all(obf$age >= 0))
})

test_that("obfuscatePed with linkedDateShift = FALSE still reproduces the old independent per-column date shifting, proving the parameter is a real toggle (issue #150 D3)", {
  # See set_seed() rationale above.
  ped <- qcStudbook(nprcgenekeepr::pedGood)
  ped$exit <- ped$birth + 10L

  set_seed(3L)
  obf <- obfuscatePed(ped, size = 6L, maxDelta = 30L, linkedDateShift = FALSE)

  expect_true(any(obf$age < 0))
})
