## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Tests for .findIsolatedIds() -- pedigree-diagram isolated-individual
## suppression (docs/planning/pedigree-diagram-isolated-individual-
## suppression-plan.md, Dragon 1, RATIFIED S643, Phase 1 implemented S644).
## Entangled with issue #164 (makePedigreeMatingLayout() crashes on an
## all-founder pedigree -- see test_makePedigreeMatingLayout.R for the
## crash-repro-level tests). A pure, internal predicate: an individual is
## isolated iff they have no known parent AND are never named as anyone
## else's parent AND are not twinRelations-connected -- i.e. literally zero
## edges in the pedigree data model (a mating union is recognized only via
## a shared child, so a parent with no children is NOT, on its own,
## "mated"). Not validated here (matches .buildTwinConnectorEdges()'s own
## "not validated here" convention) -- callable only from within
## makePedigreeMatingLayout(), downstream of that function's own
## is.data.frame()/required-columns validation.

## ---- isolated: no parent, never a parent, no twin connection -----------

test_that(".findIsolatedIds flags an individual with no sire, no dam, and
           who is never named as anyone's sire or dam (P5's exact
           profile), while NOT flagging P1/P2 -- founders, but each a
           known parent of C1", {
  ped <- data.frame(
    id = c("P1", "P2", "C1", "P5"),
    sire = c(NA_character_, NA_character_, "P1", NA_character_),
    dam = c(NA_character_, NA_character_, "P2", NA_character_),
    stringsAsFactors = FALSE
  )
  expect_equal(.findIsolatedIds(ped), "P5")
})

## ---- not isolated: has a known parent -----------------------------------

test_that(".findIsolatedIds does not flag an individual with a known sire
           but no known dam", {
  ped <- data.frame(
    id = c("F1", "C1"),
    sire = c(NA_character_, "F1"),
    dam = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  expect_false("C1" %in% .findIsolatedIds(ped))
})

test_that(".findIsolatedIds does not flag an individual with a known dam
           but no known sire", {
  ped <- data.frame(
    id = c("M1", "C1"),
    sire = c(NA_character_, NA_character_),
    dam = c(NA_character_, "M1"),
    stringsAsFactors = FALSE
  )
  expect_false("C1" %in% .findIsolatedIds(ped))
})

test_that(".findIsolatedIds does not flag an individual whose parent
           reference is dangling (the named sire/dam has no own row in
           ped) -- a known-parent edge counts even when the parent itself
           was trimmed out of this ped", {
  ped <- data.frame(
    id = c("C1"),
    sire = c("OFFSCREEN_SIRE"),
    dam = c(NA_character_),
    stringsAsFactors = FALSE
  )
  expect_false("C1" %in% .findIsolatedIds(ped))
})

## ---- not isolated: is a parent, even with no parents of their own -------

test_that(".findIsolatedIds does not flag a founder who has no known
           parents but is themselves named as a child's sire or dam", {
  ped <- data.frame(
    id = c("F1", "C1"),
    sire = c(NA_character_, "F1"),
    dam = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  expect_false("F1" %in% .findIsolatedIds(ped))
})

## ---- not isolated: twinRelations-connected -------------------------------

test_that(".findIsolatedIds does not flag a twin who has no sire, no dam,
           and no children, but is connected via twinRelations (found
           empirically S643 -- .buildTwinConnectorEdges() still emits an
           edge referencing their id)", {
  ped <- data.frame(
    id = c("TW1", "TW2"),
    sire = c(NA_character_, NA_character_),
    dam = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  twinRelations <- data.frame(
    id1 = "TW1", id2 = "TW2", code = "MZ twin",
    stringsAsFactors = FALSE
  )
  expect_equal(.findIsolatedIds(ped, twinRelations), character(0))
})

test_that(".findIsolatedIds treats twinRelations = NULL (the default) as a
           no-op exclusion -- does not error, and a would-be-isolated
           individual with no twinRelations argument is still flagged", {
  ped <- data.frame(
    id = c("P5"),
    sire = c(NA_character_),
    dam = c(NA_character_),
    stringsAsFactors = FALSE
  )
  expect_equal(.findIsolatedIds(ped, twinRelations = NULL), "P5")
})

## ---- mixed pedigree: returns exactly the isolated subset -----------------

test_that(".findIsolatedIds returns exactly the isolated subset of a mixed
           pedigree, leaving connected individuals out", {
  ped <- data.frame(
    id = c("P1", "P2", "P5", "C1"),
    sire = c(NA_character_, NA_character_, NA_character_, "P1"),
    dam = c(NA_character_, NA_character_, NA_character_, "P2"),
    stringsAsFactors = FALSE
  )
  expect_setequal(.findIsolatedIds(ped), "P5")
})
