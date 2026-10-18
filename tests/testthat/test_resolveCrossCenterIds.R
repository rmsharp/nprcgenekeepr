## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (issue #130 Slice 4): resolveCrossCenterIds() collapses a curator-
## confirmed cross-center identity link so a transferred animal becomes ONE
## node with its real parents intact, instead of an artificial founder at the
## receiving center (the issue's literally-named failure mode, plan section
## 4 Slice 4). D5 (deterministic cross-reference table, plan section 3):
## identity is established ONLY by an explicit `mapping` table, never by
## coincidental same-string ids across the two centers' independent id
## namespaces.
##
## Fixture: Center A has founders P1/P2, their child T1 (later transferred),
## and T1's full sibling S1 (stays at Center A). Center B has X9 -- the SAME
## physical animal as T1, but recorded as an artificial founder (sire/dam
## NA) because Center B never knew its real parents -- plus an unrelated
## Center-B founder Q1 and X9's Center-B child O1. `mapping` links
## idA = "T1" to idB = "X9".
##
## Expected values below were hand-verified against this package's own
## kinship()/findGeneration() on the expected merged pedigree BEFORE writing
## any assertion (Pre-RED scratch verification, not derived from any planned
## implementation code): kinship(S1, O1) -- S1 stayed at Center A, O1 was
## born at Center B to the transferred T1 -- is 0.125 (the standard
## aunt/nephew coefficient) on the correctly merged pedigree, vs. 0 on a
## naive un-merged combination where X9 wrongly stands as its own founder.
## This is the concrete, hand-verifiable proof the "artificial founder" bug
## is fixed, not just that a merge function exists.

pedA <- data.frame(
  id   = c("P1", "P2", "T1", "S1"),
  sire = c(NA_character_, NA_character_, "P1", "P1"),
  dam  = c(NA_character_, NA_character_, "P2", "P2"),
  stringsAsFactors = FALSE
)

pedB <- data.frame(
  id   = c("X9", "Q1", "O1"),
  sire = c(NA_character_, NA_character_, "X9"),
  dam  = c(NA_character_, NA_character_, "Q1"),
  stringsAsFactors = FALSE
)

mapping <- data.frame(
  idA = "T1", idB = "X9",
  stringsAsFactors = FALSE
)

test_that("resolveCrossCenterIds collapses the transferred animal onto its real parents", {
  merged <- resolveCrossCenterIds(pedA, pedB, mapping)

  expect_s3_class(merged, "data.frame")
  expect_setequal(merged$id, c("P1", "P2", "T1", "S1", "Q1", "O1"))
  expect_false("X9" %in% merged$id)

  t1Row <- merged[merged$id == "T1", ]
  expect_identical(t1Row$sire, "P1")
  expect_identical(t1Row$dam, "P2")

  o1Row <- merged[merged$id == "O1", ]
  expect_identical(o1Row$sire, "T1")
  expect_identical(o1Row$dam, "Q1")
})

test_that("resolveCrossCenterIds produces correct, non-zero cross-center kinship", {
  merged <- resolveCrossCenterIds(pedA, pedB, mapping)
  merged$gen <- findGeneration(merged$id, merged$sire, merged$dam)
  kmat <- kinship(merged$id, merged$sire, merged$dam, merged$gen)

  ## The concrete "artificial founder" bug proof: S1 (Center A) and O1
  ## (Center B, child of the transferred T1) must show the true aunt/nephew
  ## relationship, not appear unrelated.
  expect_equal(kmat["S1", "O1"], 0.125)
  expect_equal(kmat["T1", "S1"], 0.25)
  expect_equal(kmat["T1", "O1"], 0.25)
})

test_that("resolveCrossCenterIds errors when mapping references an id absent from pedA or pedB", {
  badMappingA <- data.frame(idA = "NOPE", idB = "X9", stringsAsFactors = FALSE)
  expect_error(resolveCrossCenterIds(pedA, pedB, badMappingA), "idA")

  badMappingB <- data.frame(idA = "T1", idB = "NOPE", stringsAsFactors = FALSE)
  expect_error(resolveCrossCenterIds(pedA, pedB, badMappingB), "idB")
})

test_that("resolveCrossCenterIds errors on a non-1:1 mapping table", {
  dupMapping <- data.frame(
    idA = c("T1", "T1"), idB = c("X9", "Q1"),
    stringsAsFactors = FALSE
  )
  expect_error(resolveCrossCenterIds(pedA, pedB, dupMapping), "duplicate")
})

test_that("resolveCrossCenterIds errors on conflicting recorded parents between centers", {
  conflictPedB <- pedB
  conflictPedB$sire[conflictPedB$id == "X9"] <- "OTHER_SIRE"

  expect_error(
    resolveCrossCenterIds(pedA, conflictPedB, mapping),
    "conflicting"
  )
})

test_that("resolveCrossCenterIds errors on an id shared by both pedigrees but undeclared in mapping", {
  collidingPedB <- pedB
  collidingPedB$id[collidingPedB$id == "Q1"] <- "S1" # collides with pedA's S1

  expect_error(
    resolveCrossCenterIds(pedA, collidingPedB, mapping),
    "not declared"
  )
})

test_that("resolveCrossCenterIds requires id/sire/dam columns on both pedigrees and idA/idB on mapping", {
  expect_error(
    resolveCrossCenterIds(pedA[, c("id", "sire")], pedB, mapping),
    "dam"
  )
  expect_error(
    resolveCrossCenterIds(pedA, pedB[, c("id", "sire")], mapping),
    "dam"
  )
  expect_error(
    resolveCrossCenterIds(pedA, pedB, data.frame(idA = "T1")),
    "idB"
  )
})

## Golden master (issue #149 Slice 1, D2): resolveCrossCenterIds()'s exact
## merge output on this file's own fixture, captured BEFORE the D2 validation
## -extraction refactor. Any drift here means the refactor changed observable
## behavior, not just internal structure -- this is a stronger, whole-object
## check than the two positive-assertion blocks above, which only inspect
## specific rows/columns.
test_that("resolveCrossCenterIds's merge output is unchanged by the D2 validation refactor (golden master)", {
  merged <- resolveCrossCenterIds(pedA, pedB, mapping)

  expected <- structure(
    list(
      id   = c("P1", "P2", "S1", "T1", "Q1", "O1"),
      sire = c(NA, NA, "P1", "P1", NA, "T1"),
      dam  = c(NA, NA, "P2", "P2", NA, "Q1")
    ),
    row.names = c(NA, -6L), class = "data.frame"
  )
  expect_identical(merged, expected)
})

## D10 (issue #149 Slice 1): resolveCrossCenterIds()'s merge step previously
## dropped every non-id/sire/dam column for merged individuals, even when
## both sides agreed on a value (plan section 2.12). These two tests use
## their own dedicated fixtures (not the shared pedA/pedB/mapping above) so
## they stay clearly separate from the D2 golden-master claim, per the
## plan's own instruction (section 3 D10).
test_that("resolveCrossCenterIds (D10) carries through an agreeing shared column for merged individuals", {
  pedA10 <- data.frame(
    id   = c("P1", "P2", "T1"),
    sire = c(NA_character_, NA_character_, "P1"),
    dam  = c(NA_character_, NA_character_, "P2"),
    sex  = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )
  pedB10 <- data.frame(
    id   = c("X9", "O1"),
    sire = c(NA_character_, "X9"),
    dam  = c(NA_character_, NA_character_),
    sex  = c("M", "F"),
    stringsAsFactors = FALSE
  )
  mapping10 <- data.frame(idA = "T1", idB = "X9", stringsAsFactors = FALSE)

  merged <- resolveCrossCenterIds(pedA10, pedB10, mapping10)

  expect_identical(merged$sex[merged$id == "T1"], "M")
})

test_that("resolveCrossCenterIds (D10) errors on a conflicting shared column beyond sire/dam", {
  pedA10c <- data.frame(
    id   = c("P1", "P2", "T1"),
    sire = c(NA_character_, NA_character_, "P1"),
    dam  = c(NA_character_, NA_character_, "P2"),
    sex  = c("M", "F", "M"),
    stringsAsFactors = FALSE
  )
  pedB10c <- data.frame(
    id   = c("X9", "O1"),
    sire = c(NA_character_, "X9"),
    dam  = c(NA_character_, NA_character_),
    sex  = c("F", "F"),
    stringsAsFactors = FALSE
  )
  mapping10c <- data.frame(idA = "T1", idB = "X9", stringsAsFactors = FALSE)

  expect_error(
    resolveCrossCenterIds(pedA10c, pedB10c, mapping10c),
    "conflicting sex"
  )
})

## S1011 (docs-audit part 2, finding CE4; ruled "fix" S1004, scope ruled at the
## S1011 PRE-RED question): a pedB animal with no mapping row whose id equals
## an id the mapping gives a pedA animal made the merge hold two rows with the
## mapped animal's id. The merge now stops on it, as it already does for an
## id that is unmapped in both files. The mirror case, a swap mapping and an
## id mapped to the same string merge to one row per id today and must keep
## doing so.
test_that("resolveCrossCenterIds errors on a pedB animal that reuses an id the mapping gives a pedA animal", {
  clashPedB <- data.frame(
    id   = c("X9", "T1", "O1"),
    sire = c(NA_character_, NA_character_, "X9"),
    dam  = c(NA_character_, NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )

  expect_error(
    resolveCrossCenterIds(pedA, clashPedB, mapping),
    paste0("pedB holds its own animal with the id(s) T1, which 'mapping' ",
           "uses for a pedA animal it links to a different pedB animal"),
    fixed = TRUE
  )
})

test_that("resolveCrossCenterIds merges the mirror case to one row per id", {
  ## pedA holds its own, different X9; pedB's mapped X9 is pedA's T1.
  mirrorPedA <- data.frame(
    id   = c("P1", "P2", "T1", "X9"),
    sire = c(NA_character_, NA_character_, "P1", NA_character_),
    dam  = c(NA_character_, NA_character_, "P2", NA_character_),
    stringsAsFactors = FALSE
  )
  mirrorPedB <- data.frame(
    id   = c("X9", "O1"),
    sire = c(NA_character_, "X9"),
    dam  = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )

  merged <- resolveCrossCenterIds(mirrorPedA, mirrorPedB, mapping)

  expect_false(anyDuplicated(merged$id) > 0L)
  expect_setequal(merged$id, c("P1", "P2", "T1", "X9", "O1"))
  expect_identical(merged$sire[merged$id == "T1"], "P1")
  expect_identical(merged$sire[merged$id == "O1"], "T1")
})

test_that("resolveCrossCenterIds merges a swap mapping and an id mapped to the same string to one row per id", {
  swapPedA <- data.frame(
    id = c("T1", "X9"), sire = NA_character_, dam = NA_character_,
    stringsAsFactors = FALSE
  )
  swapPedB <- data.frame(
    id = c("X9", "T1"), sire = NA_character_, dam = NA_character_,
    stringsAsFactors = FALSE
  )
  swapMapping <- data.frame(
    idA = c("T1", "X9"), idB = c("X9", "T1"),
    stringsAsFactors = FALSE
  )
  swapped <- resolveCrossCenterIds(swapPedA, swapPedB, swapMapping)
  expect_false(anyDuplicated(swapped$id) > 0L)
  expect_setequal(swapped$id, c("T1", "X9"))

  samePedB <- data.frame(
    id   = c("T1", "O1"),
    sire = c(NA_character_, "T1"),
    dam  = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  sameMapping <- data.frame(idA = "T1", idB = "T1", stringsAsFactors = FALSE)
  same <- resolveCrossCenterIds(pedA, samePedB, sameMapping)
  expect_false(anyDuplicated(same$id) > 0L)
  expect_setequal(same$id, c("P1", "P2", "T1", "S1", "O1"))
  expect_identical(same$sire[same$id == "T1"], "P1")
  expect_identical(same$sire[same$id == "O1"], "T1")
})

## S1011 (docs-audit part 2, finding CE5; ruled "fix" S1004): the help says
## the merge covers "the union of pedA's and pedB's columns", but a column
## only one center recorded was lost for a mapped animal (NA-filled by
## bindPedigreeRows()), and lost altogether when every animal was mapped.
## The mapped animal now takes the non-NA side for every column, as the
## shared columns already do, and keeps any column either input has.
test_that("resolveCrossCenterIds gives a mapped animal the value of a column only pedA recorded", {
  pedASex <- pedA
  pedASex$sex <- c("M", "F", "M", "F")

  merged <- resolveCrossCenterIds(pedASex, pedB, mapping)

  expect_identical(merged$sex[merged$id == "T1"], "M")
  expect_identical(merged$sex[merged$id == "S1"], "F")
  expect_true(is.na(merged$sex[merged$id == "O1"]))
})

test_that("resolveCrossCenterIds gives a mapped animal the value of a column only pedB recorded", {
  pedBSex <- pedB
  pedBSex$sex <- c("F", "F", "M") # X9, Q1, O1

  merged <- resolveCrossCenterIds(pedA, pedBSex, mapping)

  expect_identical(merged$sex[merged$id == "T1"], "F")
  expect_identical(merged$sex[merged$id == "O1"], "M")
  expect_true(is.na(merged$sex[merged$id == "S1"]))
})

test_that("resolveCrossCenterIds keeps a column only one center recorded when every animal is mapped", {
  oneA <- data.frame(
    id = "T1", sire = NA_character_, dam = NA_character_, sex = "M",
    stringsAsFactors = FALSE
  )
  oneB <- data.frame(
    id = "X9", sire = NA_character_, dam = NA_character_,
    stringsAsFactors = FALSE
  )

  fromA <- resolveCrossCenterIds(oneA, oneB, mapping)
  expect_identical(names(fromA), c("id", "sire", "dam", "sex"))
  expect_identical(fromA$sex, "M")

  oneBSex <- oneB
  oneBSex$sex <- "F"
  fromB <- resolveCrossCenterIds(oneA[, c("id", "sire", "dam")], oneBSex,
                                 mapping)
  expect_identical(names(fromB), c("id", "sire", "dam", "sex"))
  expect_identical(fromB$sex, "F")
})

test_that("resolveCrossCenterIds keeps a one-sided column whose value for the mapped animal is NA", {
  oneA <- data.frame(
    id = "T1", sire = NA_character_, dam = NA_character_,
    sex = NA_character_, stringsAsFactors = FALSE
  )
  oneB <- data.frame(
    id = "X9", sire = NA_character_, dam = NA_character_,
    stringsAsFactors = FALSE
  )

  merged <- resolveCrossCenterIds(oneA, oneB, mapping)

  expect_true("sex" %in% names(merged))
  expect_true(is.na(merged$sex))
})

test_that("resolveCrossCenterIds keeps the class of a one-sided Date column", {
  pedABirth <- pedA
  pedABirth$birth <- as.Date(c("2000-01-01", "2000-01-02", "2010-05-06",
                               "2010-05-07"))
  fromA <- resolveCrossCenterIds(pedABirth, pedB, mapping)
  expect_s3_class(fromA$birth, "Date")
  expect_identical(fromA$birth[fromA$id == "T1"], as.Date("2010-05-06"))

  pedBBirth <- pedB
  pedBBirth$birth <- as.Date(c("2010-05-06", "2001-02-03", "2012-12-12"))
  fromB <- resolveCrossCenterIds(pedA, pedBBirth, mapping)
  expect_s3_class(fromB$birth, "Date")
  expect_identical(fromB$birth[fromB$id == "T1"], as.Date("2010-05-06"))
  expect_identical(fromB$birth[fromB$id == "O1"], as.Date("2012-12-12"))
})

## Found by a mutation run of the S1011 GREEN code (padding the missing side
## with a plain NA survived every test): the mapped rows are bound together
## first, so an NA of the wrong class on the FIRST mapped animal turns the
## column into day numbers when the second mapped animal's date is bound in.
## Needs two mapped animals, the first with an NA, and no unmapped animal at
## Center A -- an unmapped animal's Date would come first in the final bind
## and hand its class to the column, hiding the loss.
test_that("resolveCrossCenterIds keeps a one-sided Date column's class when the first mapped animal's date is NA", {
  pedATwo <- data.frame(
    id    = c("T1", "T2"),
    sire  = NA_character_,
    dam   = NA_character_,
    birth = as.Date(c(NA, "2010-05-07")),
    stringsAsFactors = FALSE
  )
  pedBTwo <- data.frame(
    id = c("X9", "X8"), sire = NA_character_, dam = NA_character_,
    stringsAsFactors = FALSE
  )
  mappingTwo <- data.frame(
    idA = c("T1", "T2"), idB = c("X9", "X8"), stringsAsFactors = FALSE
  )

  merged <- resolveCrossCenterIds(pedATwo, pedBTwo, mappingTwo)

  expect_s3_class(merged$birth, "Date")
  expect_true(is.na(merged$birth[merged$id == "T1"]))
  expect_identical(merged$birth[merged$id == "T2"], as.Date("2010-05-07"))
})
