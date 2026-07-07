## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
pedOne <- nprcgenekeepr::rhesusPedigree
pedOne$fromCenter <- TRUE
potentialParents <-
  getPotentialParents(
    ped = pedOne, minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  )
ids <- c("BRI2MW", "FEEN9W")
## #31: the dam-exclusion window is now gestation-derived (+/- maxGestationalPeriod,
## here +/- 210 d) instead of the old fixed +/- 182.5 d (1/2 year) "hack". Two dams
## drop from BRI2MW's set (focal birth 1998-12-06) because each delivered another
## offspring within +/- 210 d of the focal birth -- a gestation conflict that makes
## her the dam of the focal animal biologically impossible:
##   0B7XRI -- other offspring at -193 d      PHCADH -- other offspring at +195 d
## Both sat just outside the old +/- 182.5 d window, so they survived before #31.
dams_1 <- c(
  "HR70BU", "I2G9D6", "J8XZ81", "HV7LZ3", "IMF6BL"
)
## #31: three dams drop from FEEN9W's set (focal birth 1997-12-23) -- each
## delivered another offspring within +/- 210 d of the focal birth:
##   1SIP4V +183 d        DMI0QY +192 d        HV7LZ3 -192 d
## Exclusion is per-focal: PHCADH conflicts with BRI2MW but not FEEN9W, so it
## stays here; HV7LZ3 conflicts with FEEN9W but not BRI2MW, so it stays in dams_1.
dams_4 <- c(
  "3PD3U5", "J8XZ81", "73Z6NI", "T5S3BR",
  "PHCADH", "A792ZU", "F3QIL7"
)
sires_1 <- c(
  "HKTQ40", "MY1AEU", "QWUKUY", "1X40V5", "WDBGPF", "6MGJYG",
  "8LWCAD", "SLN0TF", "Q7F87W", "IQLWH8", "M0YNUR", "RYP77M",
  "8LKBV9", "D0Z114", "1W4GNT", "D1WP48", "CAN12C", "KUENM8",
  "QP1WMJ", "WCPXHD", "DKMJ2Z", "1Y8P15", "4F3ASD", "DKDP5B",
  "XL7AVE", "YPHFHF", "A3UZAN", "7U5NJD", "ELGVC6", "L07M06",
  "4U7JTW", "270UK6", "LUPGF8", "S0ZHJP", "WWZRCW", "H16EC4",
  "81MJXH", "K9TMQP", "GA204Z", "V1X2X3", "P49ZD1", "KY4G8M",
  "9JC6RF", "M5DJVP", "HJLX2B", "SPHGC9", "62PLX3", "QQ24T8",
  "9LZVTE", "VTZFWZ"
)
sires_4 <- c(
  "HKTQ40", "MY1AEU", "QWUKUY", "1X40V5", "WDBGPF", "6MGJYG",
  "8LWCAD", "SLN0TF", "Q7F87W", "IQLWH8", "M0YNUR", "RYP77M",
  "8LKBV9", "D0Z114", "1W4GNT", "D1WP48", "CAN12C", "KUENM8",
  "QP1WMJ", "WCPXHD", "DKMJ2Z", "1Y8P15", "4F3ASD", "DKDP5B",
  "XL7AVE", "YPHFHF", "A3UZAN", "ELGVC6", "L07M06", "4U7JTW",
  "270UK6", "LUPGF8", "S0ZHJP", "WWZRCW", "H16EC4", "GA204Z",
  "P49ZD1", "KY4G8M", "9JC6RF", "HJLX2B", "QQ24T8", "9LZVTE"
)
dams <- list(BRI2MW = dams_1, FEEN9W = dams_4)
sires <- list(BRI2MW = sires_1, FEEN9W = sires_4)

test_that("getPotentialParents forms list with correct lists", {
  expect_identical(potentialParents[[1L]]$id, ids[1L])
  expect_identical(potentialParents[[4L]]$id, ids[2L])
  expect_identical(potentialParents[[1L]]$dams, dams$BRI2MW)
  expect_identical(potentialParents[[4L]]$dams, dams$FEEN9W)
  expect_identical(potentialParents[[1L]]$sires, sires$BRI2MW)
  expect_identical(potentialParents[[4L]]$sires, sires$FEEN9W)
})
test_that("getPotentialParents detects pedigree without fromCenter column", {
  pedOne$fromCenter <- NULL
  expect_null(getPotentialParents(
    ped = pedOne, minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  ))
})
test_that("getPotentialParents works with records with no potential parent", {
  ## BRI2MW is a from-center founder with both parents unknown, so it normally
  ## appears in the output (the first entry). Pushing its birth back to 1950
  ## empties its breeding-age candidate set, so getPotentialParents must drop
  ## it (the early-skip when no breeding-age candidate exists) rather than emit
  ## a NULL or empty entry.
  globalIds <- vapply(potentialParents, function(x) x$id, character(1L))
  expect_true("BRI2MW" %in% globalIds) # precondition: normally present
  pedOne$birth[1] <- as.Date("1950-01-01")
  ped <- getPotentialParents(
    ped = pedOne, minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  )
  scenarioIds <- vapply(ped, function(x) x$id, character(1L))
  expect_false("BRI2MW" %in% scenarioIds) # dropped (no potential parent)
  expect_equal(length(ped), length(potentialParents) - 1L) # exactly one fewer
})
test_that("getPotentialParents returns NULL when no from-center animal has a missing parent", {
  ## NEW-34 regression: founders A and B have unknown parents but are NOT
  ## from-center, so they are excluded from pUnknown; the only from-center
  ## animal, C, has both parents known. pUnknown is therefore empty, the
  ## per-animal loop never runs, and the function must fall through to its
  ## NULL return. Before the fix this crashed with "object 'j' not found"
  ## because the loop counter `j` was bound only inside the
  ## `if (nrow(pUnknown) > 0L)` branch yet read unconditionally afterwards.
  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2003-01-01")),
    exit = as.Date(NA),
    fromCenter = c(FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )
  expect_null(getPotentialParents(
    ped = ped, minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  ))
})
test_that("getPotentialParents does not mutate the caller's pedigree (NEW-53)", {
  ## NEW-53: getPotentialParents must not flip the caller's data.frame to a
  ## data.table by reference (setDT at getPotentialParents.R:28).
  pedDF <- nprcgenekeepr::rhesusPedigree
  pedDF$fromCenter <- TRUE
  pedDF <- as.data.frame(pedDF)
  expect_identical(class(pedDF), "data.frame") # precondition
  namesSnapshot <- paste0(names(pedDF), collapse = "\r")
  invisible(getPotentialParents(
    ped = pedDF, minSireAge = 2, minDamAge = 2, maxGestationalPeriod = 210L
  ))
  expect_false(inherits(pedDF, "data.table"))
  expect_identical(class(pedDF), "data.frame")
  expect_identical(paste0(names(pedDF), collapse = "\r"), namesSnapshot)
})
test_that("getPotentialParents excludes dams by a gestation-derived window (#31)", {
  ## #31: a female who delivered another offspring within +/- maxGestationalPeriod
  ## days of the focal birth cannot have gestated the focal animal, so she is
  ## removed from the candidate dams. This replaces the old fixed +/- 182.5-day
  ## "hack" with a window driven by the existing maxGestationalPeriod parameter.
  ## Minimal hand-verifiable pedigree:
  ##   FOCAL   born 2010-01-01, from-center, both parents unknown
  ##   DAM_IN  delivered KID_IN  at +200 d -> conflict iff window >= 200 d
  ##   DAM_OUT delivered KID_OUT at +400 d -> never a conflict; stays a candidate
  ## Both DAM_IN/DAM_OUT are breeding-age females present at the focal birth and
  ## are "proven breeders" in the +/- 0.5-1.5 y preferential band, so the only
  ## thing separating them is the gestation-derived exclusion.
  D0 <- as.Date("2010-01-01")
  ped <- data.frame(
    id    = c("FOCAL", "DAM_IN", "DAM_OUT", "SIRE", "KID_IN", "KID_OUT"),
    sire  = c(NA, NA, NA, NA, "SIRE", "SIRE"),
    dam   = c(NA, NA, NA, NA, "DAM_IN", "DAM_OUT"),
    sex   = c("F", "F", "F", "M", "M", "F"),
    birth = c(
      D0, as.Date("2000-01-01"), as.Date("2000-01-01"),
      as.Date("2000-01-01"), D0 + 200L, D0 + 400L
    ),
    exit  = as.Date(NA),
    fromCenter = c(TRUE, TRUE, TRUE, TRUE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  damsAt <- function(g) {
    out <- getPotentialParents(
      ped = ped, minSireAge = 2, minDamAge = 2, maxGestationalPeriod = g
    )
    out[[1L]]$dams
  }
  ## window = 210 d: DAM_IN's +200 d offspring is INSIDE -> DAM_IN excluded
  expect_false("DAM_IN" %in% damsAt(210L))
  expect_true("DAM_OUT" %in% damsAt(210L))
  ## window = 180 d: DAM_IN's +200 d offspring is OUTSIDE -> DAM_IN retained
  ## (guards against over-exclusion; DAM_OUT is always a candidate)
  expect_true("DAM_IN" %in% damsAt(180L))
  expect_true("DAM_OUT" %in% damsAt(180L))
})
test_that("dam selection responds to maxGestationalPeriod (#31 acceptance crit. 2)", {
  ## #31 acceptance criterion 2: dam candidate selection must respond to
  ## maxGestationalPeriod, not a hard-coded 1/2-year window. On the rhesus
  ## fixture, BRI2MW's dam set differs between 165 d (actual rhesus gestation)
  ## and 210 d (the conservative max used elsewhere in this file): 0B7XRI (-193 d)
  ## and PHCADH (+195 d) fall inside +/- 210 but outside +/- 165, so they remain
  ## candidates at 165 and are excluded at 210. Before #31 the dam set was
  ## identical for any maxGestationalPeriod (the parameter affected only sires).
  damsBRI <- function(g) {
    pp <- getPotentialParents(
      ped = pedOne, minSireAge = 2, minDamAge = 2, maxGestationalPeriod = g
    )
    pp[[1L]]$dams
  }
  d165 <- damsBRI(165L)
  d210 <- damsBRI(210L)
  expect_false(identical(d165, d210))
  ## a wider gestation window only removes dams, never adds them
  expect_true(all(d210 %in% d165))
})
test_that("maxGestationalPeriod = NULL falls back to 210 on a species-less pedigree (#46 item 2)", {
  ## rhesusPedigree carries no species column, so the optional per-animal
  ## species lookup resolves to the 210-day default for every focal animal --
  ## identical to the historical explicit-210 behavior. This pins backward
  ## compatibility for species-less pedigrees when the argument is omitted.
  null_pp <- getPotentialParents(ped = pedOne, minSireAge = 2, minDamAge = 2)
  explicit_pp <- getPotentialParents(
    ped = pedOne, minSireAge = 2, minDamAge = 2, maxGestationalPeriod = 210L
  )
  expect_identical(null_pp, explicit_pp)
})
test_that("maxGestationalPeriod = NULL resolves a rhesus-species pedigree to 210 (#46 item 2)", {
  ## With a species column present and every focal animal RHESUS, the per-animal
  ## lookup must resolve to the shipped rhesus value (210), so the omitted-argument
  ## result equals the explicit-210 result. Exercises the species-column-present
  ## code path.
  pedSpecies <- pedOne
  pedSpecies$species <- "RHESUS"
  null_pp <- getPotentialParents(
    ped = pedSpecies, minSireAge = 2, minDamAge = 2
  )
  explicit_pp <- getPotentialParents(
    ped = pedSpecies, minSireAge = 2, minDamAge = 2, maxGestationalPeriod = 210L
  )
  expect_identical(null_pp, explicit_pp)
})
test_that("getPotentialParents keys the gestation window per focal animal's species (#46 item 2)", {
  ## The real discriminator: two from-center focal animals born the same day but
  ## of different species. Via the injected gestationTable, RHESUS -> a 210-day
  ## window and TESTSP -> a 90-day window. DAM delivered KID_GEST 150 d after the
  ## focal birth: inside +/-210 (so DAM is excluded as a candidate dam for the
  ## RHESUS focal) but outside +/-90 (so DAM stays a candidate for the TESTSP
  ## focal). DAM2 is a proven breeder (KID2_PROVEN at +300 d, in the +0.5-1.5 y
  ## band) with no offspring in either window, so she is always a candidate and
  ## keeps the dam set non-empty (avoiding the all-females fallback). An
  ## implementation that ignores species (one fixed window for all animals)
  ## cannot satisfy both DAM assertions at once.
  D0 <- as.Date("2010-01-01")
  ped <- data.frame(
    id   = c(
      "FOCAL_R", "FOCAL_T", "DAM", "DAM2", "SIRE",
      "KID_GEST", "KID_PROVEN", "KID2_PROVEN"
    ),
    sire = c(NA, NA, NA, NA, NA, "SIRE", "SIRE", "SIRE"),
    dam  = c(NA, NA, NA, NA, NA, "DAM", "DAM", "DAM2"),
    sex  = c("F", "F", "F", "F", "M", "M", "F", "F"),
    species = c(
      "RHESUS", "TESTSP", "RHESUS", "RHESUS", "RHESUS",
      "RHESUS", "RHESUS", "RHESUS"
    ),
    birth = c(
      D0, D0, as.Date("2000-01-01"), as.Date("2000-01-01"),
      as.Date("2000-01-01"), D0 + 150L, D0 + 300L, D0 + 300L
    ),
    exit = as.Date(NA),
    fromCenter = c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  tbl <- data.frame(
    species = c("RHESUS", "TESTSP"),
    gestation = c(210L, 90L),
    stringsAsFactors = FALSE
  )
  pp <- getPotentialParents(
    ped = ped, minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = NULL, gestationTable = tbl
  )
  damsOf <- function(animalId) {
    idx <- which(vapply(pp, function(x) x$id, character(1L)) == animalId)
    pp[[idx]]$dams
  }
  expect_false("DAM" %in% damsOf("FOCAL_R")) # 210-day window excludes DAM
  expect_true("DAM" %in% damsOf("FOCAL_T")) # 90-day window retains DAM
  ## DAM2 has no offspring in either window -> always a candidate for both
  expect_true("DAM2" %in% damsOf("FOCAL_R"))
  expect_true("DAM2" %in% damsOf("FOCAL_T"))
})

# Issue #111 coverage backfill (S293): the empty-potentialDams fallback at
# getPotentialParents.R L151-152 -- when the proven-breeder filter removes
# every candidate dam, fall back to ALL females old enough to be the dam.
test_that("getPotentialParents falls back to all old-enough females", {
  ## L151-152: when the proven-breeder filter empties the candidate dams,
  ## the function falls back to ALL females old enough to be the dam. DAM is
  ## a breeding-age female present at the focal birth but has no offspring at
  ## all, so she is not in the +/- 0.5-1.5 y "proven breeder" band and is
  ## dropped -- emptying potentialDams and forcing the fallback, which then
  ## re-admits her as an old-enough female.
  D0 <- as.Date("2010-01-01")
  ped <- data.frame(
    id    = c("FOCAL", "DAM", "SIRE"),
    sire  = c(NA, NA, NA),
    dam   = c(NA, NA, NA),
    sex   = c("F", "F", "M"),
    birth = c(D0, as.Date("2000-01-01"), as.Date("2000-01-01")),
    exit  = as.Date(NA),
    fromCenter = c(TRUE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
  pp <- getPotentialParents(
    ped = ped, minSireAge = 2, minDamAge = 2, maxGestationalPeriod = 210L
  )
  expect_identical(pp[[1L]]$id, "FOCAL")
  expect_identical(pp[[1L]]$dams, "DAM")
})

## Issue #119 Slice 2 -----------------------------------------------------
## getPotentialParents now keys the minimum breeding-age floor on each
## candidate's own species+sex (via resolveBreedingAge), replacing the single
## flat cutoff. rhesusPedigree carries no species column, so its goldens above
## stay at the legacy flat-2 floor; the fixtures below add a species column to
## prove the sex- and species-specific behavior. Rhesus floors: male 4, female
## 2.5 (from the bundled speciesGestation table).

test_that("getPotentialParents NULL floors reproduce flat-2 on species-less ped", {
  ## Both overrides omitted -> resolveBreedingAge falls back to 2 for the
  ## species-less rhesusPedigree, so the result must equal the explicit flat-2
  ## golden built at the top of this file.
  defaulted <- getPotentialParents(ped = pedOne, maxGestationalPeriod = 210L)
  expect_identical(defaulted, potentialParents)
})

## One from-center focal animal (FOCAL, both parents unknown) plus rhesus
## candidates of known age. SIRE_YOUNG is 3 yrs old at the focal birth
## (2010-01-01) -> below the rhesus male floor of 4; SIRE_OLD is 10 -> above it.
sireFixture <- data.frame(
  id = c("FOCAL", "SIRE_YOUNG", "SIRE_OLD", "DAM_OLD"),
  sire = c(NA, NA, NA, NA),
  dam = c(NA, NA, NA, NA),
  sex = c("F", "M", "M", "F"),
  species = rep("RHESUS", 4L),
  birth = as.Date(c(
    "2010-01-01", "2007-01-01", "2000-01-01", "2000-01-01"
  )),
  exit = as.Date(NA),
  fromCenter = c(TRUE, FALSE, FALSE, FALSE),
  stringsAsFactors = FALSE
)

test_that("getPotentialParents excludes a sire below the species male floor", {
  pp <- getPotentialParents(ped = sireFixture, maxGestationalPeriod = 210L)
  expect_identical(pp[[1L]]$id, "FOCAL")
  sires <- pp[[1L]]$sires
  expect_false("SIRE_YOUNG" %in% sires) # 3 yr < rhesus male floor 4
  expect_true("SIRE_OLD" %in% sires) # 10 yr >= 4
})

test_that("getPotentialParents minSireAge override readmits a young sire", {
  pp <- getPotentialParents(
    ped = sireFixture, minSireAge = 2, maxGestationalPeriod = 210L
  )
  expect_true("SIRE_YOUNG" %in% pp[[1L]]$sires) # floor lowered to 2
})

## DAM_YOUNG is ~2.25 yrs old at the focal birth -> below the rhesus female
## floor of 2.5. She has no offspring, so she reaches the candidate set only
## through the all-old-enough-females fallback, which the per-candidate floor
## still gates.
damFixture <- data.frame(
  id = c("FOCAL", "DAM_YOUNG", "SIRE"),
  sire = c(NA, NA, NA),
  dam = c(NA, NA, NA),
  sex = c("F", "F", "M"),
  species = rep("RHESUS", 3L),
  birth = as.Date(c("2010-01-01", "2007-10-01", "2000-01-01")),
  exit = as.Date(NA),
  fromCenter = c(TRUE, FALSE, FALSE),
  stringsAsFactors = FALSE
)

test_that("getPotentialParents excludes a dam below the species female floor", {
  pp <- getPotentialParents(ped = damFixture, maxGestationalPeriod = 210L)
  expect_identical(pp[[1L]]$id, "FOCAL")
  expect_false("DAM_YOUNG" %in% pp[[1L]]$dams) # ~2.25 yr < rhesus female 2.5
})

test_that("getPotentialParents minDamAge override readmits a young dam", {
  pp <- getPotentialParents(
    ped = damFixture, minDamAge = 2, maxGestationalPeriod = 210L
  )
  expect_true("DAM_YOUNG" %in% pp[[1L]]$dams) # floor lowered to 2
})

test_that("getPotentialParents minParentAge alias reproduces flat-2 and warns", {
  ## Back-compat: the deprecated scalar sets both sex floors and still warns.
  lifecycle::expect_deprecated(
    aliased <- getPotentialParents(
      ped = pedOne, minParentAge = 2.0, maxGestationalPeriod = 210L
    )
  )
  expect_identical(aliased, potentialParents)
})
