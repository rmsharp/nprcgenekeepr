## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #168 Slice 4a (RED): ancestry-guardrails config + enforcement wiring
# in modBreedingGroups (plan sec 5 Slice 4, D6/D7/D8; owner-ratified 4a/4b
# split -- override gate, "Ancestry" results tab, manifest download, and e2e
# land at 4b). Design pinned at this RED (owner-ratified pre-RED round):
# - UI: a collapsed-by-default "Ancestry Guardrails" sub-section beside the
#   kinship threshold -- checkboxInput ns("showAncestryGuardrails") (FALSE),
#   an always-visible one-line status ns("ancestryStatus"), and a
#   conditionalPanel (unprefixed condition, Learning 324) holding
#   fileInput ns("ancestryRulesFile").
# - ancestryRulesData(): validate-notify reactive (kinshipOverrideData()
#   mold, R/modGeneticValue.R:243) -- NULL with no upload; error notifies
#   and returns NULL; the D6 UNKNOWN/OTHER warning notifies and is muffled,
#   rules kept.
# - ancestryRulesForRun(): the rules formation actually receives -- NULL
#   unless rules are loaded AND the pedigree has an ancestry column (the
#   app's loud-but-not-fatal reading of D6; groupAddAssign() never stop()s
#   from the module for a rule-less or ancestry-less run).
# - ancestryStatusText(): D8's one-line status, verbatim states pinned in
#   the blocks below.
# - Formation: the groupAddAssign() call gains
#   ancestryRules = ancestryRulesForRun(); with the example block rules no
#   formed group ever co-places INDIAN with CHINESE or HYBRID.

# Slow shiny-module integration tests (shiny::testServer() calls); skip on
# CRAN to keep check elapsed time within limits. They still run on CI and
# locally, mirroring test_modBreedingGroups.R.
testthat::skip_on_cran()

# The data.frame shiny's fileInput hands the server for an uploaded file
# (test_modGeneticValue_coverage.R mold).
arFileInfo <- function(path) {
  data.frame(
    name = basename(path), size = 1L, type = "text/csv",
    datapath = path, stringsAsFactors = FALSE
  )
}

# QC'd example ancestry pedigree (test_ancestryOverrides.R aoPed() mold):
# 10 animals, all 6 post-QC levels -- INDIAN x3 (I1, I2, A1), CHINESE x2
# (C1, C2), JAPANESE x2 (J1, J2), HYBRID x1 (H1), OTHER x1 (O1),
# UNKNOWN x1 (U1).
arPed <- function() {
  raw <- read.csv(
    system.file("extdata", "examples", "example_ancestry_pedigree.csv",
      package = "nprcgenekeepr"
    ),
    stringsAsFactors = FALSE, na.strings = c("", "NA")
  )
  qcStudbook(raw,
    minSireAge = 2, minDamAge = 2, reportChanges = FALSE,
    reportErrors = FALSE
  )
}

# The same pedigree with no ancestry column at all (the qcPed case): the
# guardrail section must go inactive and formation must run exactly as
# today (D6's app-side reading -- loud, never fatal).
arNoAncestryPed <- function() {
  ped <- arPed()
  ped$ancestry <- NULL
  ped
}

arRulesPath <- function() {
  system.file("extdata", "examples", "example_ancestry_rules.csv",
    package = "nprcgenekeepr"
  )
}

## Hand-derived on the shipped fixtures: the example rules file holds 2
## block rules (INDIAN x CHINESE, INDIAN x HYBRID) and 2 flag rules
## (INDIAN x UNKNOWN, INDIAN x OTHER); they name INDIAN, CHINESE, HYBRID,
## UNKNOWN, OTHER -- JAPANESE is named by no rule, so J1 and J2 are the 2
## uncovered animals on the 10-animal QC'd pedigree.
arActiveStatus <- "2 block, 2 flag rule(s); 2 animal(s) uncovered."
arNoRulesStatus <- "No ancestry rules loaded."
arInactiveStatus <-
  "Pedigree has no ancestry column -- ancestry guardrails inactive."

# =============================================================================
# UI
# =============================================================================

test_that("modBreedingGroupsUI includes the ancestry-guardrails elements", {
  ui <- modBreedingGroupsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl("showAncestryGuardrails", ui_html, fixed = TRUE))
  expect_true(grepl("ancestryRulesFile", ui_html, fixed = TRUE))
  expect_true(grepl("ancestryStatus", ui_html, fixed = TRUE))
  expect_true(grepl("Ancestry Guardrails", ui_html, fixed = TRUE))
})

test_that(paste(
  "modBreedingGroupsUI's ancestry-guardrails conditionalPanel",
  "condition is unprefixed (Learning 324)"
), {
  ui <- modBreedingGroupsUI("test")
  ui_html <- as.character(ui)

  # ns = ns already narrows the client-side scope, so the condition must be
  # the bare input name -- a ns()-built condition double-prefixes and never
  # matches, leaving the panel permanently hidden (the nTopAnimals /
  # customSexRatio precedent in this module).
  expect_true(grepl('data-display-if="input.showAncestryGuardrails"',
    ui_html,
    fixed = TRUE
  ))
})

test_that(paste(
  "modBreedingGroupsUI's ancestry-guardrails section is",
  "collapsed by default (toggle unchecked)"
), {
  ui <- modBreedingGroupsUI("test")
  ui_html <- as.character(ui)

  toggleTag <- regmatches(
    ui_html,
    regexpr('<input[^>]*id="test-showAncestryGuardrails"[^>]*>', ui_html)
  )
  expect_length(toggleTag, 1L)
  expect_false(grepl("checked", toggleTag, fixed = TRUE))
})

# =============================================================================
# ancestryRulesData() / ancestryRulesForRun(): the validate-notify reactive
# =============================================================================

test_that(paste(
  "modBreedingGroupsServer ancestry rules are NULL with no",
  "upload and the status line says so (D7)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      expect_null(ancestryRulesData())
      expect_null(ancestryRulesForRun())
      expect_identical(ancestryStatusText(), arNoRulesStatus)
    }
  )
})

test_that(paste(
  "modBreedingGroupsServer accepts the shipped example rules",
  "file (2 block + 2 flag, validated)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      rules <- ancestryRulesData()
      expect_s3_class(rules, "data.frame")
      expect_identical(nrow(rules), 4L)
      expect_identical(sum(rules$severity == "block"), 2L)
      expect_identical(sum(rules$severity == "flag"), 2L)
      expect_true(all(c("INDIAN", "CHINESE") %in%
        c(rules$ancestry1, rules$ancestry2)))
      # With rules loaded and an ancestry-bearing pedigree, formation
      # receives exactly the validated rules.
      expect_identical(ancestryRulesForRun(), rules)
    }
  )
})

test_that(paste(
  "modBreedingGroupsServer returns NULL for a malformed rules",
  "file (error notified, never thrown)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  badCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(badCsv), add = TRUE)
  writeLines(
    c("ancestry1,ancestry2,severity", "INDIAN,CHINESE,banned"),
    badCsv
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(badCsv))
      expect_no_error(rules <- ancestryRulesData())
      expect_null(rules)
      expect_null(ancestryRulesForRun())
    }
  )
})

test_that(paste(
  "modBreedingGroupsServer muffles the D6 UNKNOWN-without-OTHER",
  "warning and keeps the validated rules"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  warnCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(warnCsv), add = TRUE)
  writeLines(
    c("ancestry1,ancestry2,severity", "INDIAN,UNKNOWN,flag"),
    warnCsv
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(warnCsv))
      # The warning is surfaced as a notification and muffled inside the
      # module (kinshipOverrideData() mold), so none escapes here.
      expect_no_warning(rules <- ancestryRulesData())
      expect_s3_class(rules, "data.frame")
      expect_identical(nrow(rules), 1L)
    }
  )
})

# =============================================================================
# ancestryStatusText(): D8's one-line status, states pinned verbatim
# =============================================================================

test_that(paste(
  "modBreedingGroupsServer status line reports rule and",
  "coverage counts with rules loaded (D8)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      expect_identical(ancestryStatusText(), arActiveStatus)
    }
  )
})

test_that(paste(
  "modBreedingGroupsServer goes inactive on a pedigree with no",
  "ancestry column: notice shown, rules withheld from formation (D6)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arNoAncestryPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      # The upload itself still validates (the file is fine) ...
      expect_s3_class(ancestryRulesData(), "data.frame")
      # ... but formation never sees it, and the status line says why.
      expect_null(ancestryRulesForRun())
      expect_identical(ancestryStatusText(), arInactiveStatus)
    }
  )
})

# =============================================================================
# Formation wiring: groupAddAssign(ancestryRules = ancestryRulesForRun())
# =============================================================================

test_that(paste(
  "modBreedingGroupsServer never co-places a blocked ancestry",
  "pair once rules are uploaded"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({
        test_ped
      }),
      geneticValues = NULL
    ),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      # Guard against a false green: formation must actually have the 4
      # validated rules in play for this run.
      expect_identical(nrow(ancestryRulesForRun()), 4L)

      session$setInputs(
        animalSource = "all",
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none",
        nIterations = 5
      )
      session$setInputs(formGroups = 1)

      # The property holds for FORMED groups. The module's last group is
      # the unused-animals bucket when hasUnused (addGroupOfUnusedAnimals();
      # unplaced animals are not co-housed, so blocked animals legitimately
      # accumulate there together). Check every retained candidate, not
      # just the returned selection.
      res <- groupResults()
      anc <- setNames(
        toupper(as.character(test_ped$ancestry)),
        test_ped$id
      )
      expect_true(length(res$candidates) >= 1L)
      sawFormedAnimal <- FALSE
      for (cand in res$candidates) {
        formed <- cand$validGroups
        if (isTRUE(cand$hasUnused) && length(formed) > 0L) {
          formed <- formed[-length(formed)]
        }
        for (g in formed) {
          if (length(g) > 0L) sawFormedAnimal <- TRUE
          levelsInGroup <- unique(anc[g])
          expect_false(
            "INDIAN" %in% levelsInGroup &&
              any(c("CHINESE", "HYBRID") %in% levelsInGroup)
          )
        }
      }
      # Anti-vacuity guard: the property must not pass via empty groups.
      expect_true(sawFormedAnimal)
    }
  )
})

test_that(paste(
  "modBreedingGroupsServer forms groups exactly as today on a",
  "no-ancestry pedigree even with rules uploaded (D6, loud not fatal)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arNoAncestryPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({
        test_ped
      }),
      geneticValues = NULL
    ),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      # The load-bearing pin: rules are withheld, so groupAddAssign()
      # cannot stop() on the missing ancestry column.
      expect_null(ancestryRulesForRun())

      session$setInputs(
        animalSource = "all",
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none",
        nIterations = 5
      )
      session$setInputs(formGroups = 1)

      groups <- session$getReturned()$groups()
      expect_true(length(groups) >= 1L)
      expect_true(sum(lengths(groups)) > 0L)
    }
  )
})
