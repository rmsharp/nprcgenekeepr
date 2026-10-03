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

## PED_GV F3 (NEW-35) --------------------------------------------------------
## The all-old-enough-females fallback must not re-admit a female the
## gestation window already ruled out: she delivered another offspring within
## maxGestationalPeriod days of the focal birth, so she cannot have gestated
## the focal animal too. In each fixture below no female is a proven breeder
## (no offspring in the +/- 0.5-1.5 y band), so the fallback always runs.
fallbackPed <- function(otherBirths) {
  ## otherBirths: named integer vector, female id -> day offset (from the
  ## focal birth) of that female's other offspring; NA means she has none.
  D0 <- as.Date("2010-01-01")
  females <- names(otherBirths)
  kids <- females[!is.na(otherBirths)]
  data.frame(
    id = c("FOCAL", "M1", females, paste0("KID_", kids)),
    sire = NA_character_,
    dam = c(NA, NA, rep(NA, length(females)), kids),
    sex = c("F", "M", rep("F", length(females)), rep("M", length(kids))),
    birth = c(
      D0, as.Date("2000-01-01"), rep(as.Date("2000-01-01"), length(females)),
      D0 + otherBirths[kids]
    ),
    exit = as.Date(NA),
    fromCenter = c(TRUE, rep(FALSE, 1L + length(females) + length(kids))),
    stringsAsFactors = FALSE
  )
}

test_that("the dam fallback never re-admits a female ruled out by gestation (NEW-35, probe P5)", {
  ## Audit probe P5: F1 delivered another offspring 59 days after the focal
  ## birth and is the only adult female, so no candidate dam remains. The
  ## entry is still emitted with its sires.
  pp <- getPotentialParents(
    ped = fallbackPed(c(F1 = 59L)), minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  )
  expect_identical(pp[[1L]]$id, "FOCAL")
  expect_identical(pp[[1L]]$sires, "M1")
  expect_identical(pp[[1L]]$dams, character(0L))
})

test_that("the dam fallback keeps the females the gestation window did not rule out (NEW-35)", {
  ## F_AFTER delivered 59 d after the focal birth and F_BEFORE 100 d before
  ## it: both inside the +/- 210 d window, so both are ruled out. F_OPEN has
  ## no offspring at all, so the fallback still offers her.
  pp <- getPotentialParents(
    ped = fallbackPed(c(F_AFTER = 59L, F_BEFORE = -100L, F_OPEN = NA)),
    minSireAge = 2, minDamAge = 2, maxGestationalPeriod = 210L
  )
  expect_identical(pp[[1L]]$id, "FOCAL")
  expect_identical(pp[[1L]]$dams, "F_OPEN")
})

test_that("the dam fallback's exclusion follows the gestation window (NEW-35)", {
  ## F1's other offspring is 100 d after the focal birth: inside a 210 d
  ## window (ruled out) but outside a 90 d one (still offered). 100 d is also
  ## short of the 0.5 y proven-breeder band, so the fallback runs either way.
  damsAt <- function(g) {
    getPotentialParents(
      ped = fallbackPed(c(F1 = 100L)), minSireAge = 2, minDamAge = 2,
      maxGestationalPeriod = g
    )[[1L]]$dams
  }
  expect_identical(damsAt(210L), character(0L))
  expect_identical(damsAt(90L), "F1")
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

test_that("getPotentialParents finds a populated result using the shipped examplePedigree", {
  ## Regression coverage for the fix to "Shipped example pedigree cannot
  ## demonstrate the Potential Parents feature" (BACKLOG.md, S348): the
  ## SAME example pedigree threaded through Document 2's walkthrough can
  ## now show a populated result, not only the graceful-degradation state.
  qcPed <- qcStudbook(nprcgenekeepr::examplePedigree,
                      minSireAge = 2, minDamAge = 2)
  pp <- getPotentialParents(
    ped = qcPed, minSireAge = 2, minDamAge = 2, maxGestationalPeriod = 210L
  )
  expect_identical(length(pp), 1587L)
})

## Placeholder-marking plan Slice 2 (S808): Potential Parents trusts the
## placeholder mark. U1234 is a real sire (marked FALSE), U0001 a stand-in
## (marked TRUE, no birth date, as addParents() adds it).
markedPed <- function(u1234Birth) {
  data.frame(
    id = c("S1", "U1234", "U0001", "D1", "D2", "K1", "K2"),
    sire = c(NA, NA, NA, NA, NA, "U1234", "U0001"),
    dam = c(NA, NA, NA, NA, NA, "D1", "D2"),
    sex = c("M", "M", "M", "F", "F", "F", "M"),
    birth = as.Date(c("2000-01-01", u1234Birth, NA, "2000-01-01",
                      "2000-01-01", "2008-01-01", "2010-01-01")),
    exit = as.Date(NA),
    fromCenter = TRUE,
    placeholder = c(FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
}
focalIds <- function(pp) vapply(pp, function(x) x$id, character(1L))

test_that("getPotentialParents() keeps a real U1234 marked FALSE as a recorded sire and a candidate", {
  pp <- getPotentialParents(
    ped = markedPed("2000-01-01"), minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  )
  expect_false("K1" %in% focalIds(pp)) # both parents on record
  expect_true("K2" %in% focalIds(pp)) # its sire is a stand-in
  expect_true("U1234" %in% pp[[which(focalIds(pp) == "K2")]]$sires)
})

## D12: the mark is read before animals with no birth date are set aside, so a
## real sire with no birth date is still a recorded sire.
test_that("getPotentialParents() keeps a real U1234 with no birth date as a recorded sire", {
  pp <- getPotentialParents(
    ped = markedPed(NA), minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  )
  expect_false("K1" %in% focalIds(pp))
  expect_true("K2" %in% focalIds(pp))
})

## Own-parent rule (S817, owner-chosen): candidates are listed only for the
## parent that is missing. A recorded parent is never re-listed, so the
## candidate list is empty for that side. (Before, a recorded dam was always
## ruled out by the gestation window because the focal animal's own birth
## counts, so every dam list for such an animal was wrong by construction.)
recordedParentPed <- function() {
  adults <- c("M1", "F1", "F2", "U1234", "U0001")
  data.frame(
    id = c(adults, "K_DAMREC", "K_SIREREC", "K_BOTH", "K_REALU", "K_STAND"),
    sire = NA_character_,
    dam = c(rep(NA, length(adults)), "F1", NA, NA, "U1234", "U0001"),
    sex = c("M", "F", "F", "F", "F", "M", "M", "F", "M", "F"),
    birth = as.Date(c(
      rep("2000-01-01", 4L), NA, "2010-01-01", "2012-01-01", "2014-01-01",
      "2016-01-01", "2018-01-01"
    )),
    exit = as.Date(NA),
    fromCenter = c(rep(FALSE, length(adults)), rep(TRUE, 5L)),
    placeholder = c(rep(FALSE, 4L), TRUE, rep(FALSE, 5L)),
    stringsAsFactors = FALSE
  )
}
recordedParentPp <- function() {
  ped <- recordedParentPed()
  ped$sire[ped$id == "K_SIREREC"] <- "M1"
  getPotentialParents(
    ped = ped, minSireAge = 2, minDamAge = 2, maxGestationalPeriod = 210L
  )
}
entryFor <- function(pp, id) pp[[which(focalIds(pp) == id)]]

test_that("a recorded dam is not re-listed: dams is empty, sires still listed", {
  e <- entryFor(recordedParentPp(), "K_DAMREC")
  expect_identical(e$dams, character(0L))
  expect_true("M1" %in% e$sires)
})

test_that("a recorded sire is not re-listed: sires is empty, dams still listed", {
  e <- entryFor(recordedParentPp(), "K_SIREREC")
  expect_identical(e$sires, character(0L))
  expect_true(all(c("F1", "F2") %in% e$dams))
})

test_that("an animal with neither parent recorded keeps both candidate lists", {
  e <- entryFor(recordedParentPp(), "K_BOTH")
  expect_true("M1" %in% e$sires)
  expect_true(all(c("F1", "F2") %in% e$dams))
})

test_that("a real U1234 marked FALSE counts as a recorded dam (no dam list)", {
  e <- entryFor(recordedParentPp(), "K_REALU")
  expect_identical(e$dams, character(0L))
  expect_true("M1" %in% e$sires)
})

test_that("a stand-in dam (placeholder TRUE) is not a recorded dam, so dams is listed", {
  e <- entryFor(recordedParentPp(), "K_STAND")
  expect_true(all(c("F1", "F2") %in% e$dams))
})

## PED_GV NEW-55 (owner decision S880) ---------------------------------------
## Each entry says which tier its dam list came from: "provenBreeder" (a
## female with an offspring 0.5-1.5 y from the focal birth), "eligibleFemale"
## (the fallback: every female old enough, present, and not ruled out by
## gestation), or NA when no dam is listed (recorded dam, or no candidate).
## id, sires and dams are unchanged.
test_that("damBasis is 'provenBreeder' when a proven breeder supplies the dams (NEW-55)", {
  ## PROVEN's other offspring is 400 d after the focal birth: outside the
  ## 210 d gestation window, inside the 0.5-1.5 y band.
  pp <- getPotentialParents(
    ped = fallbackPed(c(PROVEN = 400L)), minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  )
  expect_identical(pp[[1L]]$dams, "PROVEN")
  expect_identical(pp[[1L]]$damBasis, "provenBreeder")
})

test_that("damBasis is 'eligibleFemale' when the fallback supplies the dams (NEW-55)", {
  ## F_AFTER is ruled out by gestation; F_OPEN has no offspring, so only the
  ## fallback offers her. (fallbackPed needs one female with an offspring.)
  pp <- getPotentialParents(
    ped = fallbackPed(c(F_OPEN = NA, F_AFTER = 59L)), minSireAge = 2,
    minDamAge = 2, maxGestationalPeriod = 210L
  )
  expect_identical(pp[[1L]]$dams, "F_OPEN")
  expect_identical(pp[[1L]]$damBasis, "eligibleFemale")
})

test_that("damBasis is NA when the dam is already recorded (NEW-55)", {
  e <- entryFor(recordedParentPp(), "K_DAMREC")
  expect_identical(e$dams, character(0L))
  expect_identical(e$damBasis, NA_character_)
})

test_that("damBasis is NA when no candidate dam remains (NEW-55)", {
  ## F1 delivered 59 d after the focal birth, so gestation rules her out and
  ## the entry is still emitted, with sires and no dams.
  pp <- getPotentialParents(
    ped = fallbackPed(c(F1 = 59L)), minSireAge = 2, minDamAge = 2,
    maxGestationalPeriod = 210L
  )
  expect_identical(pp[[1L]]$dams, character(0L))
  expect_identical(pp[[1L]]$damBasis, NA_character_)
})

test_that("every entry carries exactly id, sires, dams, damBasis with a length-1 damBasis (NEW-55)", {
  pp <- recordedParentPp()
  for (e in pp) {
    expect_identical(names(e), c("id", "sires", "dams", "damBasis"))
    expect_length(e$damBasis, 1L)
    expect_true(is.character(e$damBasis))
    expect_true(is.na(e$damBasis) ||
      e$damBasis %in% c("provenBreeder", "eligibleFemale"))
    ## the label is NA exactly when no dam is listed
    expect_identical(is.na(e$damBasis), length(e$dams) == 0L)
  }
})
