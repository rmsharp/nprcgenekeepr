## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# Issue #168 Slice 4a + 4b: ancestry-guardrails wiring in modBreedingGroups
# (plan sec 5 Slice 4, D4/D6/D7/D8; owner-ratified 4a/4b split). The 4a
# blocks (config + enforcement) start below; the 4b blocks (override gate,
# "Ancestry" results tab, manifest download) start at the "Slice 4b" banner
# further down, with their own design pins. The e2e drive lives in
# test-e2e-breeding-groups-ancestry.R. Design pinned at the 4a RED
# (owner-ratified pre-RED round):
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

# =============================================================================
# =============================================================================
# Slice 4b (RED): override gate + "Ancestry" results tab + manifest download
# =============================================================================
# =============================================================================
# Design pinned at this RED (owner-ratified pre-RED round, S769):
# - Override controls (D4/D8) live inside the guardrails conditionalPanel:
#   selectInput ns("overrideRule") over the not-yet-overridden BLOCK rules
#   (values = sorted "LO-HI" pair keys), actionButton ns("overrideOpen")
#   opening the #150-mold modalDialog (verbatim .ancestryOverrideWarningText,
#   required textAreaInput ns("overrideReason"), actionButton
#   ns("overrideConfirm")), uiOutput ns("overrideStatus"), and actionButton
#   ns("clearOverrides").
# - Overrides persist until cleared or a new rules file is uploaded
#   (owner-ratified "until cleared"); each formation run SNAPSHOTS the rules,
#   overrides, and the pedigree's id/ancestry columns (the #150
#   params-snapshot mold), so the Ancestry tab and manifest always describe
#   the displayed run, never live input state.
# - Wiring is Learning 780's two-call contract: formation receives
#   .effectiveAncestryRules(rules, overrides); reportAncestryViolations()
#   and .buildAncestryOverrideManifest() receive the ORIGINAL rules plus
#   the overrides.
# - The report universe is the selected candidate's FORMED groups only --
#   the unused-animals bucket is dropped via hasUnused (Learning 781).
# - "Ancestry" results tab (D8): uiOutput ns("ancestryGuidance"), violations
#   DT ns("ancestryViolationsTable"), coverage table
#   ns("ancestryCoverageTable"), and downloadButton
#   ns("downloadAncestryManifest") (filename via getDatedFilename()).
# - Internal reactives pinned here: ancestryOverridesRV (reactiveVal,
#   0-row data.frame ancestry1/ancestry2/reason), overridableRules(),
#   overrideStatusText(), ancestryTabGuidanceText(), ancestryReport(),
#   ancestryManifest().

arKey <- function(a, b) paste(pmin(a, b), pmax(a, b), sep = "-")

arReason <- "Founder import approved by the colony veterinarian"

## Pinned display strings (4b).
arOverrideStatusOne <-
  "1 block rule(s) overridden this session: CHINESE-INDIAN."
arTabNoRules <- paste(
  "No ancestry rules loaded -- upload a rules file in the Ancestry",
  "Guardrails section."
)
arTabNoRun <-
  "Form groups with ancestry rules loaded to see rule violations here."

test_that(paste(
  "modBreedingGroupsUI includes the Ancestry results tab and",
  "override controls (4b)"
), {
  ui <- modBreedingGroupsUI("test")
  ui_html <- as.character(ui)

  expect_true(grepl('data-value="Ancestry"', ui_html, fixed = TRUE))
  for (id in c(
    "test-ancestryGuidance", "test-ancestryViolationsTable",
    "test-ancestryCoverageTable", "test-downloadAncestryManifest",
    "test-overrideRule", "test-overrideOpen",
    "test-overrideStatus", "test-clearOverrides"
  )) {
    expect_true(grepl(id, ui_html, fixed = TRUE), info = id)
  }
})

test_that(paste(
  "the override controls live inside the guardrails",
  "conditionalPanel (D8)"
), {
  ui_html <- as.character(modBreedingGroupsUI("test"))

  start <- regexpr('data-display-if="input.showAncestryGuardrails"',
    ui_html,
    fixed = TRUE
  )
  end <- regexpr("test-sexRatio", ui_html, fixed = TRUE)
  expect_true(start > 0L)
  expect_true(end > start)
  panel <- substr(ui_html, start, end)
  for (id in c(
    "test-overrideRule", "test-overrideOpen",
    "test-overrideStatus", "test-clearOverrides"
  )) {
    expect_true(grepl(id, panel, fixed = TRUE), info = id)
  }
})

test_that(paste(
  "overridableRules() lists the not-yet-overridden block rules",
  "only (D4)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      # No rules loaded: nothing to override.
      expect_null(overridableRules())

      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      ovr <- overridableRules()
      expect_s3_class(ovr, "data.frame")
      expect_identical(nrow(ovr), 2L)
      expect_true(all(ovr$severity == "block"))
      expect_setequal(
        arKey(ovr$ancestry1, ovr$ancestry2),
        c("CHINESE-INDIAN", "HYBRID-INDIAN")
      )

      # Overriding one drops it from the overridable set.
      session$setInputs(
        overrideRule = "CHINESE-INDIAN",
        overrideReason = arReason
      )
      session$setInputs(overrideConfirm = 1)
      ovr <- overridableRules()
      expect_identical(nrow(ovr), 1L)
      expect_identical(arKey(ovr$ancestry1, ovr$ancestry2), "HYBRID-INDIAN")
    }
  )
})

test_that(paste(
  "an override confirm with a blank reason is rejected -- no",
  "override recorded (D4)"
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
      session$setInputs(
        overrideRule = "CHINESE-INDIAN",
        overrideReason = "   "
      )
      session$setInputs(overrideConfirm = 1)
      expect_identical(nrow(ancestryOverridesRV()), 0L)
      expect_null(overrideStatusText())
    }
  )
})

test_that(paste(
  "a confirmed override is recorded with its reason and shown in",
  "the status line (D4)"
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
      session$setInputs(
        overrideRule = "CHINESE-INDIAN",
        overrideReason = arReason
      )
      session$setInputs(overrideConfirm = 1)
      ov <- ancestryOverridesRV()
      expect_identical(nrow(ov), 1L)
      expect_setequal(c(ov$ancestry1, ov$ancestry2), c("INDIAN", "CHINESE"))
      expect_identical(ov$reason, arReason)
      expect_identical(overrideStatusText(), arOverrideStatusOne)

      # Clearing removes every override.
      session$setInputs(clearOverrides = 1)
      expect_identical(nrow(ancestryOverridesRV()), 0L)
      expect_null(overrideStatusText())
    }
  )
})

test_that("uploading a new rules file resets the overrides (D4)", {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  warnCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(warnCsv), add = TRUE)
  writeLines(
    c("ancestry1,ancestry2,severity", "INDIAN,CHINESE,block"),
    warnCsv
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      session$setInputs(
        overrideRule = "CHINESE-INDIAN",
        overrideReason = arReason
      )
      session$setInputs(overrideConfirm = 1)
      expect_identical(nrow(ancestryOverridesRV()), 1L)

      # A new rules file may not contain the overridden rule at all --
      # stale overrides must never survive a rules change.
      session$setInputs(ancestryRulesFile = arFileInfo(warnCsv))
      expect_identical(nrow(ancestryOverridesRV()), 0L)
    }
  )
})

test_that(paste(
  "an override flows through formation, report, and manifest via",
  "the two-call contract (Learning 780; snapshot semantics, #150 mold)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()
  gv <- data.frame(
    id = c("I1", "C1"), value = c("High Value", "High Value"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({
        test_ped
      }),
      geneticValues = shiny::reactive({
        gv
      })
    ),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      session$setInputs(
        animalSource = "topRanked",
        inclusionCriterion = "topN",
        nTopAnimals = 2,
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none",
        nIterations = 5
      )

      # Run 1: the INDIAN x CHINESE block rule keeps I1 and C1 apart in
      # every retained candidate's formed groups.
      session$setInputs(formGroups = 1)
      res <- groupResults()
      for (cand in res$candidates) {
        formed <- cand$validGroups
        if (isTRUE(cand$hasUnused) && length(formed) > 0L) {
          formed <- formed[-length(formed)]
        }
        for (g in formed) {
          expect_false(all(c("I1", "C1") %in% g))
        }
      }
      rep1 <- ancestryReport()
      v1 <- rep1$violations
      expect_identical(
        nrow(v1[v1$severity == "block" & v1$status == "violation", ]), 0L
      )

      # Override INDIAN x CHINESE through the gate.
      session$setInputs(
        overrideRule = "CHINESE-INDIAN",
        overrideReason = arReason
      )
      session$setInputs(overrideConfirm = 1)

      # Snapshot semantics: the DISPLAYED run predates the override, so
      # its manifest still records no overrides (the #150 snapshot mold --
      # a late override must never rewrite an earlier run's audit record).
      m1 <- ancestryManifest()
      expect_false(any(m1$overridden))
      expect_identical(
        m1$overrideSummary[1L], "No rules were overridden for this run."
      )

      # Run 2: the overridden rule no longer blocks -- I1 and C1 co-place
      # (deterministic: the two are unrelated founders, so nothing else
      # excludes either).
      session$setInputs(formGroups = 2)
      cand <- groupResults()$candidates[[1L]]
      formed <- cand$validGroups
      if (isTRUE(cand$hasUnused) && length(formed) > 0L) {
        formed <- formed[-length(formed)]
      }
      expect_true(any(vapply(
        formed, function(g) all(c("I1", "C1") %in% g), logical(1L)
      )))

      # The report sees the ORIGINAL rules plus the overrides: the pair
      # reports with severity "block" and status "overridden" -- the one
      # observable a Learning-780 miswiring changes.
      rep2 <- ancestryReport()
      row <- rep2$violations[rep2$violations$rule == "CHINESE-INDIAN", ]
      expect_identical(nrow(row), 1L)
      expect_identical(row$severity, "block")
      expect_identical(row$status, "overridden")

      # Coverage census, hand-derived over the run's grouped animals:
      # exactly I1 (INDIAN) and C1 (CHINESE); JAPANESE is named by no rule.
      cov <- rep2$coverage
      expect_identical(cov$n[cov$ancestry == "INDIAN"], 1L)
      expect_identical(cov$n[cov$ancestry == "CHINESE"], 1L)
      expect_identical(sum(cov$n), 2L)
      expect_false(cov$covered[cov$ancestry == "JAPANESE"])

      # Manifest for run 2 (D4): the overridden rule row carries the
      # reason; the gate wording rides every row verbatim.
      m2 <- ancestryManifest()
      r <- m2[m2$ancestry1 == "INDIAN" & m2$ancestry2 == "CHINESE", ]
      expect_identical(nrow(r), 1L)
      expect_true(r$overridden)
      expect_identical(r$reason, arReason)
      expect_identical(r$nPairs, 1L)
      expect_identical(m2$warningText[1L], .ancestryOverrideWarningText)
      expect_identical(
        m2$overrideSummary[1L], "1 of 4 rules overridden for this run."
      )
    }
  )
})

test_that(paste(
  "the Ancestry report covers the formed groups only, never the",
  "unused bucket (Learning 781)"
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
      session$setInputs(
        animalSource = "all",
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none",
        nIterations = 5
      )
      session$setInputs(formGroups = 1)

      # With block rules over a single group, the blocked side of every
      # conflict lands in the unused bucket -- it must exist and must be
      # excluded from the report's universe.
      cand <- groupResults()$candidates[[1L]]
      expect_true(isTRUE(cand$hasUnused))
      formed <- cand$validGroups[-length(cand$validGroups)]

      rep <- ancestryReport()
      v <- rep$violations
      expect_identical(
        nrow(v[v$severity == "block" & v$status == "violation", ]), 0L
      )
      # The coverage census equals the formed-group universe -- feeding the
      # raw groups() return (unused bucket included) would count all 10.
      expect_identical(
        sum(rep$coverage$n),
        length(unique(unlist(formed)))
      )
      expect_lt(sum(rep$coverage$n), 10L)

      # With a rules-run displayed, the tab shows tables, not guidance.
      expect_null(ancestryTabGuidanceText())
    }
  )
})

test_that("the Ancestry tab guidance states are pinned (D8)", {
  skip_if_not_installed("shiny")
  test_ped <- arPed()
  test_ped_no_ancestry <- arNoAncestryPed()

  # State 1: no rules loaded -- guidance says so; report and manifest are
  # NULL even after a rule-less formation run (zero-behavior-change, D7).
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({
        test_ped
      }),
      geneticValues = NULL
    ),
    {
      expect_identical(ancestryTabGuidanceText(), arTabNoRules)
      expect_null(ancestryReport())
      expect_null(ancestryManifest())

      session$setInputs(
        animalSource = "all",
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none",
        nIterations = 5
      )
      session$setInputs(formGroups = 1)
      expect_identical(ancestryTabGuidanceText(), arTabNoRules)
      expect_null(ancestryReport())
      expect_null(ancestryManifest())
    }
  )

  # State 2: rules loaded but the pedigree has no ancestry column -- the
  # tab reuses the 4a inactive notice; nothing is overridable.
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped_no_ancestry
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      expect_identical(ancestryTabGuidanceText(), arInactiveStatus)
      expect_null(overridableRules())
      expect_null(ancestryReport())
      expect_null(ancestryManifest())
    }
  )

  # State 3: rules active but no formation run with rules yet.
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      expect_identical(ancestryTabGuidanceText(), arTabNoRun)
      expect_null(ancestryReport())
      expect_null(ancestryManifest())
    }
  )
})

# =============================================================================
# Issue #169 Slice 2 (D7): the validated rules reach the Mate Pair tab
# =============================================================================
#
# modBreedingGroupsServer returns one new reactive, `ancestryRules` -- the
# value ancestryRulesData() already computes (the validated table, NULL when
# nothing usable is loaded). appServer hands it to modMatePairServer, which
# applies its own column-present check, so the element is deliberately NOT
# ancestryRulesForRun() (that one is NULL on a pedigree with no ancestry
# column). Wiring: test_appServer_server.R; the consuming module:
# test_modMatePair_ancestry.R; the returned-names row: test_moduleContract.R.

test_that(paste(
  "modBreedingGroupsServer returns the loaded rules as an ancestryRules",
  "reactive: NULL before an upload, the validated table after (#169 D7)"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      returned <- session$getReturned()
      expect_true(is.function(returned$ancestryRules))
      expect_null(returned$ancestryRules())

      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      rules <- returned$ancestryRules()
      expect_s3_class(rules, "data.frame")
      expect_identical(nrow(rules), 4L)
      expect_identical(sum(rules$severity == "block"), 2L)
      expect_identical(sum(rules$severity == "flag"), 2L)
      expect_identical(rules, ancestryRulesData())
    }
  )
})

test_that(paste(
  "the returned ancestryRules is the validated table even when the pedigree",
  "has no ancestry column -- each consumer applies its own column check (D7)"
), {
  skip_if_not_installed("shiny")
  test_ped_no_ancestry <- arNoAncestryPed()

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped_no_ancestry
    })),
    {
      session$setInputs(ancestryRulesFile = arFileInfo(arRulesPath()))
      # Formation's own reading is NULL here; the returned element is not.
      expect_null(ancestryRulesForRun())
      returned <- session$getReturned()
      expect_true(is.function(returned$ancestryRules))
      expect_identical(returned$ancestryRules(), ancestryRulesData())
      expect_identical(nrow(returned$ancestryRules()), 4L)
    }
  )
})

test_that(paste(
  "the returned ancestryRules is NULL for a malformed rules file",
  "(error notified, never thrown) and follows a replacement upload"
), {
  skip_if_not_installed("shiny")
  test_ped <- arPed()

  badCsv <- tempfile(fileext = ".csv")
  oneRuleCsv <- tempfile(fileext = ".csv")
  on.exit(unlink(c(badCsv, oneRuleCsv)), add = TRUE)
  writeLines(
    c("ancestry1,ancestry2,severity", "INDIAN,CHINESE,banned"),
    badCsv
  )
  writeLines(
    c("ancestry1,ancestry2,severity", "INDIAN,CHINESE,block"),
    oneRuleCsv
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(pedigree = shiny::reactive({
      test_ped
    })),
    {
      returned <- session$getReturned()
      expect_true(is.function(returned$ancestryRules))

      session$setInputs(ancestryRulesFile = arFileInfo(badCsv))
      expect_no_error(bad <- returned$ancestryRules())
      expect_null(bad)

      session$setInputs(ancestryRulesFile = arFileInfo(oneRuleCsv))
      replaced <- returned$ancestryRules()
      expect_s3_class(replaced, "data.frame")
      expect_identical(nrow(replaced), 1L)
      expect_identical(replaced$severity, "block")
    }
  )
})
