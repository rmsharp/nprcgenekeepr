## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #169 Slice 2 RED: modMatePairServer(ancestryRules = NULL) applies the
## shipped issue #168 ancestry rules to the Mate Pair Analysis tab by calling
## the Slice 1 kernel reportMatePairs(ancestryRules =). Contract:
## docs/planning/mate-pair-ancestry-guardrails-plan.md, decisions D1, D4, D7,
## D8c, D9 and section 5 Slice 2 (done-when). The Breeding Groups side of the
## delivery (its new `ancestryRules` return element) and the appServer wiring
## are pinned in test_modBreedingGroups_ancestryRules.R and
## test_appServer_server.R; the two contract rows in test_moduleContract.R.
##
## Shape pinned at this RED (owner-ratified S775 gates):
##  * UI: a collapsed-by-default "Ancestry Guardrails" toggle
##    (ns("showAncestryGuardrails")), an always-visible one-line status output
##    (ns("ancestryStatus")) right after it, and an explainer paragraph inside
##    the toggle's unprefixed conditionalPanel (Learning 324) -- the toggle
##    layout of modBreedingGroupsUI. Slice 3 adds the override control there.
##  * Status states (verbatim below): none / active / inactive. "active" and
##    "inactive" are Breeding Groups' own texts; "none" additionally says
##    where the rules are loaded (they come from the Breeding Groups tab, D7).
##  * The module checks for the `ancestry` column BEFORE passing rules
##    (reportMatePairs() now stop()s without it): a rules-loaded run on a
##    pedigree with no ancestry column runs exactly as today (D1, app surface).
##  * Each run SNAPSHOTS the rules at the "Find Eligible Pairs" click (D8c):
##    a later rules change never rewrites an earlier run's tables.
##  * Zero eligible pairs: the existing alert is kept byte-identical and, only
##    when at least one pair was excluded by an ancestry rule, gains the
##    sentence "N pair(s) were excluded by ancestry rules -- see the Excluded
##    tab."
##  * The run-time re-validation warning (UNKNOWN without OTHER) is NOT
##    muffled -- the same posture as modBreedingGroupsServer, whose upload
##    notification is the only user-facing surface (plan dragon 10).
##
## Fixture: the shipped inst/extdata/examples/example_ancestry_{pedigree,
## rules}.csv, the same ten animals as test_reportMatePairsAncestry.R. Hand-
## derived there and re-measured at S775 Orient: 25 male x female pairs; 5
## block (C1xI2, I1xC2, A1xC2, I1xH1, A1xH1), 3 flag (I1xU1, A1xU1, O1xI2),
## 17 unmatched; every animal is age >= 21 and alive, so "allAlive" with
## minAge = 1 yields all 25.
##
## Slow shiny-module tests (shiny::testServer()); skip on CRAN, as
## test_modMatePair.R does.
testthat::skip_on_cran()

baseCols <- c(
  "sireId", "damId", "kinship", "markerKinship", "sireIndivMeanKin",
  "sireGu", "damIndivMeanKin", "damGu"
)
ancCols <- c("ancestryRule", "ancestrySeverity", "ancestryStatus")
blockKeys <- c("C1|I2", "I1|C2", "A1|C2", "I1|H1", "A1|H1")
flagKeys <- c("I1|U1", "A1|U1", "O1|I2")

mpmNoRulesStatus <- paste(
  "No ancestry rules loaded. Load a rules file on the Breeding Groups tab",
  "to apply it here."
)
mpmActiveStatus <- "2 block, 2 flag rule(s); 2 animal(s) uncovered."
mpmInactiveStatus <-
  "Pedigree has no ancestry column -- ancestry guardrails inactive."
mpmZeroPairsAlert <- paste(
  "No eligible pairs found under the current population scope and age",
  "settings. Try including more animals or lowering the minimum age."
)

mpmPed <- local({
  raw <- read.csv(
    system.file("extdata", "examples", "example_ancestry_pedigree.csv",
      package = "nprcgenekeepr"
    ),
    stringsAsFactors = FALSE, na.strings = c("", "NA")
  )
  p <- qcStudbook(raw,
    minSireAge = 2, minDamAge = 2, reportChanges = FALSE,
    reportErrors = FALSE
  )
  p$gen <- findGeneration(p$id, p$sire, p$dam)
  p
})
mpmKmat <- kinship(mpmPed$id, mpmPed$sire, mpmPed$dam, mpmPed$gen)
mpmRules <- checkAncestryRules(readAncestryRules(system.file(
  "extdata", "examples", "example_ancestry_rules.csv",
  package = "nprcgenekeepr"
)))
mpmNoAncPed <- mpmPed[, setdiff(names(mpmPed), "ancestry")]

mpmKey <- function(d) paste(d$sireId, d$damId, sep = "|")

## Server args; `rules` is a reactive (or reactiveVal) handed to the new
## ancestryRules parameter, or NULL to leave the argument OMITTED.
mpmArgs <- function(ped = mpmPed, rules = NULL) {
  args <- list(
    pedigree = shiny::reactive(ped),
    kinshipMatrix = shiny::reactive(mpmKmat),
    markerKinshipMatrix = shiny::reactive(NULL),
    geneticValues = shiny::reactive(NULL)
  )
  args$ancestryRules <- rules
  args
}

## What the module's "allAlive" click hands the kernel, called directly --
## the D4-1 oracle for every rules-off / inactive comparison.
mpmDirect <- function(ped = mpmPed, ...) {
  reportMatePairs(
    ped, mpmKmat,
    markerKmat = NULL, geneticValues = NULL, minAge = 1,
    populationIds = ped$id[is.na(ped$exit)], exclude = character(0L), ...
  )
}

mpmText <- function(rendered) paste(as.character(rendered), collapse = "")

# =============================================================================
# UI (D9): toggle, status output, explainer, placement
# =============================================================================

test_that(paste(
  "modMatePairUI has a collapsed Ancestry Guardrails toggle, an always-visible",
  "status output and the explainer, in that order before the run button"
), {
  ui_html <- as.character(modMatePairUI("mp"))

  expect_true(grepl("Ancestry Guardrails", ui_html, fixed = TRUE))
  toggleTag <- regmatches(
    ui_html,
    regexpr('<input[^>]*id="mp-showAncestryGuardrails"[^>]*>', ui_html)
  )
  expect_length(toggleTag, 1L)
  expect_false(grepl("checked", toggleTag, fixed = TRUE))
  ## ns = ns already scopes the client-side lookup: the condition is the bare
  ## input name (a ns()-built condition never matches; Learning 324).
  expect_true(grepl('data-display-if="input.showAncestryGuardrails"',
    ui_html,
    fixed = TRUE
  ))
  expect_true(grepl('id="mp-ancestryStatus"', ui_html, fixed = TRUE))

  ## the explainer says where rules come from and what block/flag mean here
  expect_true(grepl("Breeding Groups tab", ui_html, fixed = TRUE))
  expect_true(grepl("Excluded tab", ui_html, fixed = TRUE))
  expect_true(grepl("ancestry rule", ui_html, fixed = TRUE))

  ## placement: toggle, then status, then explainer, then the run button (a
  ## missing element is position -1, so require every position to be found)
  positions <- vapply(
    c('id="mp-showAncestryGuardrails"', 'id="mp-ancestryStatus"',
      "Breeding Groups tab", 'id="mp-analyze"'),
    function(s) regexpr(s, ui_html, fixed = TRUE)[[1L]],
    numeric(1L)
  )
  expect_true(all(positions > 0L))
  expect_true(all(diff(positions) > 0L))
})

# =============================================================================
# Status line: three states, verbatim (D9)
# =============================================================================

test_that(paste(
  "the status says no rules are loaded (and where to load them) when the",
  "argument is omitted or its reactive is NULL"
), {
  skip_if_not_installed("shiny")

  for (rules in list(NULL, shiny::reactive(NULL))) {
    shiny::testServer(modMatePairServer, args = mpmArgs(rules = rules), {
      expect_match(mpmText(output$ancestryStatus), mpmNoRulesStatus,
        fixed = TRUE
      )
    })
  }
})

test_that(paste(
  "the status reports the rule and uncovered-animal counts when rules are",
  "loaded and the pedigree carries an ancestry column"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(rules = shiny::reactive(mpmRules)),
    {
      ## 2 block + 2 flag rules; JAPANESE is named by no rule, so J1 and J2
      ## are the 2 uncovered animals (Breeding Groups' own status text)
      expect_match(mpmText(output$ancestryStatus), mpmActiveStatus,
        fixed = TRUE
      )
    }
  )
})

test_that(paste(
  "the status says the guardrails are inactive when rules are loaded but",
  "the pedigree has no ancestry column, or no pedigree is loaded yet"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(ped = mpmNoAncPed, rules = shiny::reactive(mpmRules)),
    {
      expect_match(mpmText(output$ancestryStatus), mpmInactiveStatus,
        fixed = TRUE
      )
    }
  )

  ## Breeding Groups' reading: a NULL pedigree is "no ancestry column".
  args <- mpmArgs(rules = shiny::reactive(mpmRules))
  args$pedigree <- shiny::reactive(NULL)
  shiny::testServer(modMatePairServer, args = args, {
    expect_match(mpmText(output$ancestryStatus), mpmInactiveStatus,
      fixed = TRUE
    )
  })
})

# =============================================================================
# Rules applied (D2, D4-5, D6c): blocked pairs on Excluded, flags as columns
# =============================================================================

test_that(paste(
  "with rules loaded, a run moves the 5 blocked pairs to Excluded (rule",
  "visible) and annotates the 3 flagged pairs in Eligible Pairs"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(rules = shiny::reactive(mpmRules)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      expect_true(result$isReady())
      pairs <- result$pairs()
      excluded <- result$excluded()

      ## columns appended AFTER damGu (column 8 stays damGu, D6c)
      expect_identical(names(pairs), c(baseCols, ancCols))
      expect_identical(names(pairs)[[8L]], "damGu")
      expect_identical(
        names(excluded), c("sireId", "damId", "reason", "ancestryRule")
      )

      expect_identical(nrow(pairs), 20L)
      expect_identical(nrow(excluded), 5L)
      expect_setequal(mpmKey(excluded), blockKeys)
      expect_true(all(excluded$reason == "ancestry rule"))
      expect_identical(
        excluded$ancestryRule[match(
          c("C1|I2", "I1|C2", "A1|C2", "I1|H1", "A1|H1"), mpmKey(excluded)
        )],
        c(rep("CHINESE-INDIAN", 3L), rep("HYBRID-INDIAN", 2L))
      )

      flagged <- pairs[!is.na(pairs$ancestryRule), ]
      expect_setequal(mpmKey(flagged), flagKeys)
      expect_true(all(flagged$ancestrySeverity == "flag"))
      expect_true(all(flagged$ancestryStatus == "violation"))
      unmatched <- pairs[is.na(pairs$ancestryRule), ]
      expect_identical(nrow(unmatched), 17L)
      expect_true(all(is.na(unmatched$ancestrySeverity)))
      expect_true(all(is.na(unmatched$ancestryStatus)))

      ## no blocked pair is left in Eligible Pairs
      expect_false(any(blockKeys %in% mpmKey(pairs)))
    }
  )
})

test_that(paste(
  "D4-3 at module level: pairs and excluded together hold the same 25 pairs",
  "with and without rules -- rules move and label pairs, never drop them"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(rules = shiny::reactive(mpmRules)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      expect_setequal(
        c(mpmKey(result$pairs()), mpmKey(result$excluded())),
        mpmKey(mpmDirect()$pairs)
      )
    }
  )
})

# =============================================================================
# Rules off: byte-unchanged (D4-1 at module level)
# =============================================================================

test_that(paste(
  "D4-1: with the ancestryRules argument omitted, pairs() and excluded() are",
  "identical() to the kernel's rules-free result (8 and 3 columns)"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(modMatePairServer, args = mpmArgs(), {
    session$setInputs(populationSource = "allAlive", minAge = 1)
    session$setInputs(analyze = 1)

    result <- session$getReturned()
    base <- mpmDirect()
    expect_identical(result$pairs(), base$pairs)
    expect_identical(result$excluded(), base$excluded)
    expect_identical(names(result$pairs()), baseCols)
    expect_identical(names(result$excluded()), c("sireId", "damId", "reason"))
  })
})

test_that(paste(
  "D4-1: an ancestryRules reactive that is NULL (no upload yet) behaves",
  "exactly like the omitted argument"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(rules = shiny::reactive(NULL)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      base <- mpmDirect()
      expect_identical(result$pairs(), base$pairs)
      expect_identical(result$excluded(), base$excluded)
    }
  )
})

test_that(paste(
  "rules loaded but the pedigree has no ancestry column: the run does not",
  "error or warn and matches the rules-free result exactly (D1, app surface)"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(ped = mpmNoAncPed, rules = shiny::reactive(mpmRules)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      ## the module checks for the column BEFORE passing rules: the kernel
      ## would stop() on rules with no ancestry column
      expect_no_error(expect_no_warning(session$setInputs(analyze = 1)))

      result <- session$getReturned()
      expect_true(result$isReady())
      base <- mpmDirect(mpmNoAncPed)
      expect_identical(result$pairs(), base$pairs)
      expect_identical(result$excluded(), base$excluded)
      expect_identical(names(result$pairs()), baseCols)
    }
  )
})

# =============================================================================
# Snapshot (D8c): a later rules change never rewrites an earlier run
# =============================================================================

test_that(paste(
  "a run snapshots the rules at the click: clearing the rules afterwards",
  "leaves that run's tables alone; the next click uses the new state"
), {
  skip_if_not_installed("shiny")

  rulesRV <- shiny::reactiveVal(mpmRules)
  shiny::testServer(modMatePairServer, args = mpmArgs(rules = rulesRV), {
    session$setInputs(populationSource = "allAlive", minAge = 1)
    session$setInputs(analyze = 1)

    result <- session$getReturned()
    firstPairs <- result$pairs()
    firstExcluded <- result$excluded()
    expect_identical(nrow(firstPairs), 20L)
    expect_identical(nrow(firstExcluded), 5L)

    rulesRV(NULL)
    session$flushReact()
    ## the status is live ...
    expect_match(mpmText(output$ancestryStatus), mpmNoRulesStatus,
      fixed = TRUE
    )
    ## ... the finished run's tables are not
    expect_identical(result$pairs(), firstPairs)
    expect_identical(result$excluded(), firstExcluded)

    session$setInputs(analyze = 2)
    base <- mpmDirect()
    expect_identical(result$pairs(), base$pairs)
    expect_identical(result$excluded(), base$excluded)
  })
})

test_that(paste(
  "rules loaded AFTER a rules-free run do not rewrite its tables either;",
  "the next click applies them"
), {
  skip_if_not_installed("shiny")

  rulesRV <- shiny::reactiveVal(NULL)
  shiny::testServer(modMatePairServer, args = mpmArgs(rules = rulesRV), {
    session$setInputs(populationSource = "allAlive", minAge = 1)
    session$setInputs(analyze = 1)

    result <- session$getReturned()
    firstPairs <- result$pairs()
    expect_identical(nrow(firstPairs), 25L)
    expect_identical(names(firstPairs), baseCols)

    rulesRV(mpmRules)
    session$flushReact()
    expect_match(mpmText(output$ancestryStatus), mpmActiveStatus, fixed = TRUE)
    expect_identical(result$pairs(), firstPairs)
    expect_identical(nrow(result$excluded()), 0L)

    session$setInputs(analyze = 2)
    expect_identical(nrow(result$pairs()), 20L)
    expect_identical(nrow(result$excluded()), 5L)
  })
})

# =============================================================================
# Export: the ancestry columns flow into the existing CSV (D9)
# =============================================================================

test_that(paste(
  "the Eligible Pairs CSV carries the ancestry columns with rules active and",
  "is column-for-column unchanged without them"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(rules = shiny::reactive(mpmRules)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      df <- utils::read.csv(output$downloadPairs, stringsAsFactors = FALSE)
      expect_identical(names(df), c(baseCols, ancCols))
      expect_identical(nrow(df), 20L)
    }
  )

  shiny::testServer(modMatePairServer, args = mpmArgs(), {
    session$setInputs(populationSource = "allAlive", minAge = 1)
    session$setInputs(analyze = 1)

    df <- utils::read.csv(output$downloadPairs, stringsAsFactors = FALSE)
    expect_identical(names(df), baseCols)
    expect_identical(nrow(df), 25L)
  })
})

# =============================================================================
# Zero eligible pairs: the alert names the ancestry cause (owner gate, S775)
# =============================================================================

test_that(paste(
  "zero eligible pairs with an ancestry exclusion: the existing alert is kept",
  "and gains the count sentence pointing at the Excluded tab"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(rules = shiny::reactive(mpmRules)),
    {
      ## I1 (INDIAN male) x C2 (CHINESE female) is the only candidate pair,
      ## and INDIAN x CHINESE is a block rule
      session$setInputs(
        populationSource = "custom", customPopulationIds = "I1, C2",
        minAge = 1
      )
      session$setInputs(analyze = 1)

      result <- session$getReturned()
      expect_identical(nrow(result$pairs()), 0L)
      expect_identical(nrow(result$excluded()), 1L)
      expect_identical(result$excluded()$reason, "ancestry rule")

      html <- mpmText(output$guidance)
      expect_match(html, mpmZeroPairsAlert, fixed = TRUE)
      expect_match(html,
        "1 pair(s) were excluded by ancestry rules -- see the Excluded tab.",
        fixed = TRUE
      )
    }
  )
})

test_that(paste(
  "zero eligible pairs with no ancestry exclusion (rules loaded or not):",
  "the alert is the existing text, byte-for-byte, with no ancestry sentence"
), {
  skip_if_not_installed("shiny")

  for (rules in list(NULL, shiny::reactive(mpmRules))) {
    shiny::testServer(modMatePairServer, args = mpmArgs(rules = rules), {
      session$setInputs(
        populationSource = "custom", customPopulationIds = "", minAge = 1
      )
      session$setInputs(analyze = 1)

      html <- mpmText(output$guidance)
      expect_identical(
        html,
        paste0(
          '<div class="alert alert-warning">', mpmZeroPairsAlert, "</div>",
          "list()"
        )
      )
    })
  }
})

# =============================================================================
# Non-happy paths that must surface, not be swallowed (module contract rule 5)
# =============================================================================

test_that(paste(
  "a malformed rules table reaching the module surfaces at the click instead",
  "of being swallowed (module contract rule 5)"
), {
  skip_if_not_installed("shiny")

  bad <- data.frame(
    ancestry1 = "INDIAN", ancestry2 = "CHINESE", severity = "banned",
    stringsAsFactors = FALSE
  )
  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(rules = shiny::reactive(bad)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      ## an observer error surfaces as a warning under testServer(); Shiny
      ## then destroys the module session, so nothing inside the module (the
      ## returned isReady(), the run store) is readable afterwards -- the
      ## surfaced error is the whole observable contract here
      expect_warning(
        session$setInputs(analyze = 1),
        "must be 'block' or 'flag'",
        fixed = TRUE
      )
    }
  )
})

test_that(paste(
  "rules whose validation warns (UNKNOWN without OTHER) still apply; the",
  "run-time warning is not muffled (Breeding Groups' posture, dragon 10)"
), {
  skip_if_not_installed("shiny")

  warnRules <- suppressWarnings(checkAncestryRules(data.frame(
    ancestry1 = "INDIAN", ancestry2 = "UNKNOWN", severity = "flag",
    stringsAsFactors = FALSE
  )))
  shiny::testServer(
    modMatePairServer,
    args = mpmArgs(rules = shiny::reactive(warnRules)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      expect_warning(
        session$setInputs(analyze = 1),
        "name UNKNOWN but not OTHER",
        fixed = TRUE
      )

      result <- session$getReturned()
      expect_true(result$isReady())
      expect_identical(nrow(result$pairs()), 25L)
      expect_identical(nrow(result$excluded()), 0L)
      expect_setequal(
        mpmKey(result$pairs()[!is.na(result$pairs()$ancestryRule), ]),
        c("I1|U1", "A1|U1")
      )
    }
  )
})
