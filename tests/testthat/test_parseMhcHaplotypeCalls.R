## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #148 Slice 1): .parseMhcHaplotypeCalls() -- the internal
## parse rule (design plan D3, ratified S704): NA/empty-string = MISSING;
## a call matching ^(.+)\?$ = an UNCERTAIN call of the stripped haplotype;
## anything else = a certain call. Labels are otherwise opaque (D9) -- no
## substructure parsing -- so a bare "?" is a CERTAIN call of the literal
## label "?" (only the something-then-"?" shape marks uncertainty). Total
## function over checkMhcHaplotypeFile()-validated input: no error paths.
## Output contract (plan sec 4): a long call table, 2 rows per animal,
## columns id, haplotype (trailing "?" stripped; NA when missing),
## uncertain (logical), missing (logical).
##
## Fixture: 7 synthetic animals covering every Dragon 6/7 edge the real
## file lacks -- certain homozygote, mixed certain+uncertain, uncertain
## homozygote, NA-missing, empty-string-missing, an uncertain-only label
## with no certain counterpart, and the bare-"?" opaque label -- plus the
## bundled real pair end-to-end, pinning the plan's measured numbers.

parseFixture <- data.frame(
  id = c("A1", "A2", "A3", "A4", "A5", "A6", "A7"),
  haplotype1 = c("H01", "H02", "H03?", NA, "", "H08?", "?"),
  haplotype2 = c("H01", "H04?", "H03?", "H06", "H07", "H09", "H10"),
  stringsAsFactors = FALSE
)

parsed <- nprcgenekeepr:::.parseMhcHaplotypeCalls(
  checkMhcHaplotypeFile(parseFixture)
)

test_that(".parseMhcHaplotypeCalls returns the long call-table contract", {
  expect_s3_class(parsed, "data.frame")
  expect_identical(names(parsed), c("id", "haplotype", "uncertain", "missing"))
  expect_identical(nrow(parsed), 14L)
  expect_type(parsed$id, "character")
  expect_type(parsed$haplotype, "character")
  expect_type(parsed$uncertain, "logical")
  expect_type(parsed$missing, "logical")
  ## Exactly 2 rows per animal, every animal present.
  expect_identical(as.integer(table(parsed$id)[parseFixture$id]),
                   rep(2L, 7L))
})

test_that("a certain homozygote yields two identical certain rows", {
  rows <- parsed[parsed$id == "A1", ]
  expect_identical(rows$haplotype, c("H01", "H01"))
  expect_identical(rows$uncertain, c(FALSE, FALSE))
  expect_identical(rows$missing, c(FALSE, FALSE))
})

test_that("a trailing '?' marks an uncertain call of the stripped label", {
  rows <- parsed[parsed$id == "A2", ]
  expect_setequal(rows$haplotype, c("H02", "H04"))
  expect_identical(rows$uncertain[rows$haplotype == "H02"], FALSE)
  ## H04 exists ONLY as an uncertain call anywhere in the fixture -- the
  ## no-certain-counterpart case has a defined output (Dragon 7).
  expect_identical(rows$uncertain[rows$haplotype == "H04"], TRUE)
  expect_identical(rows$missing, c(FALSE, FALSE))
})

test_that("an uncertain homozygote yields two uncertain rows, same label", {
  rows <- parsed[parsed$id == "A3", ]
  expect_identical(rows$haplotype, c("H03", "H03"))
  expect_identical(rows$uncertain, c(TRUE, TRUE))
  expect_identical(rows$missing, c(FALSE, FALSE))
})

test_that("an NA call is missing: haplotype NA, not uncertain", {
  rows <- parsed[parsed$id == "A4", ]
  missingRow <- rows[rows$missing, ]
  expect_identical(nrow(missingRow), 1L)
  expect_identical(missingRow$haplotype, NA_character_)
  expect_identical(missingRow$uncertain, FALSE)
  certainRow <- rows[!rows$missing, ]
  expect_identical(certainRow$haplotype, "H06")
  expect_identical(certainRow$uncertain, FALSE)
})

test_that("an empty-string call is missing, like NA", {
  ## getGenotypes() converts "" to NA on the app upload path, but a direct
  ## script caller can pass "" -- both mean missing (plan D3).
  rows <- parsed[parsed$id == "A5", ]
  missingRow <- rows[rows$missing, ]
  expect_identical(nrow(missingRow), 1L)
  expect_identical(missingRow$haplotype, NA_character_)
  expect_identical(missingRow$uncertain, FALSE)
  expect_identical(rows$haplotype[!rows$missing], "H07")
})

test_that("a bare '?' is a certain call of the literal opaque label '?'", {
  ## D9 opacity: only the ^(.+)\?$ shape marks uncertainty; a 1-character
  ## "?" has no label part to strip and is treated as an opaque label,
  ## not judged.
  rows <- parsed[parsed$id == "A7", ]
  expect_setequal(rows$haplotype, c("?", "H10"))
  expect_identical(rows$uncertain, c(FALSE, FALSE))
  expect_identical(rows$missing, c(FALSE, FALSE))
})

test_that("the bundled real pair reproduces the plan's measured numbers", {
  ## docs/planning/issue148-mhc-haplotype-reporting-plan.md sec 2.1,
  ## measured S704: 31 animals / 62 calls / 0 missing / 2 uncertain
  ## (A002a_B015?, A008_B015b?) / 33 distinct certain labels over a
  ## 60-certain-call denominator. Pinned here so a future change to the
  ## parse rule (or a silent re-export of the dataset) is a visible,
  ## deliberate break -- Slice 2 pins the frequency outputs on top.
  realParsed <- nprcgenekeepr:::.parseMhcHaplotypeCalls(
    checkMhcHaplotypeFile(nprcgenekeepr::rhesusGenotypes)
  )
  expect_identical(nrow(realParsed), 62L)
  expect_identical(sum(realParsed$missing), 0L)
  expect_identical(sum(realParsed$uncertain), 2L)
  expect_setequal(realParsed$haplotype[realParsed$uncertain],
                  c("A002a_B015", "A008_B015b"))
  certain <- realParsed[!realParsed$uncertain & !realParsed$missing, ]
  expect_identical(nrow(certain), 60L)
  expect_identical(length(unique(certain$haplotype)), 33L)
})
