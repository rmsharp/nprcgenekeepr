## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

## Issue #169 Slice 3a RED: the Mate Pair override gate, the "Ancestry" tab and
## the audit-manifest download in modMatePairServer. Contract:
## docs/planning/mate-pair-ancestry-guardrails-plan.md decisions D4, D8, D9 and
## section 5 Slice 3. The pure pieces (the gate wording constant and the
## manifest `report` adapter) are pinned in test_matePairAncestryManifest.R;
## the committed live e2e and the article are Slice 3b.
##
## Shape pinned at this RED (owner-ratified S776 gates: 3a scope, gate wording):
##  * UI: a new "Ancestry" tab AFTER "Excluded" holding uiOutput
##    ns("ancestryGuidance"), tableOutput ns("ancestryCoverageTable") and
##    downloadButton ns("downloadAncestryManifest"); the override controls --
##    selectInput ns("overrideRule"), actionButton ns("overrideOpen"),
##    uiOutput ns("overrideStatus"), actionButton ns("clearOverrides") -- sit
##    INSIDE the collapsed Ancestry Guardrails panel, before the run button
##    (the Breeding Groups layout; nothing that Slice 2 shipped moves). No
##    violations table: the inline columns are the list (D9).
##  * Override state: ancestryOverridesRV (reactiveVal, 0-row data.frame
##    ancestry1/ancestry2/reason, session-scoped, per surface), reset whenever
##    the rules reaching the module change (a new table or NULL).
##    overridableRules(): NULL unless the guardrails are ACTIVE (rules loaded
##    and the pedigree has an ancestry column); otherwise the not-yet-
##    overridden BLOCK rules, keyed by sorted "LO-HI" pair keys.
##  * The confirm gate is the #150/#168 mold: "Override rule..." opens a modal
##    with the verbatim .matePairAncestryOverrideWarningText, a required reason
##    box and Cancel/Confirm -- only on that click, never on a routine run. A
##    blank reason (trimmed) is an error notification and records nothing; a
##    good one is stored trimmed and closes the modal.
##  * The click SNAPSHOTS the run's rules and overrides next to the kernel
##    result (D8c): the displayed run's tables, coverage and manifest never
##    change when overrides or rules change afterwards. The kernel receives the
##    ORIGINAL rules plus the overrides (Learning 780 -- an overridden pair
##    keeps severity "block", status "overridden"), and overrides only when the
##    rules are active (the kernel stop()s on overrides without rules).
##  * ancestryManifest(): NULL unless the DISPLAYED run had rules in effect;
##    otherwise .buildAncestryOverrideManifest(<run rules>, <run overrides>,
##    .matePairAncestryReport(<run result>), .matePairAncestryOverrideWarning-
##    Text). The download is dated MatePairAncestryAuditManifest.csv.
##  * ancestryTabGuidanceText(): NULL once a rules-run is displayed; otherwise
##    the reason there is nothing to show (three verbatim texts below).
##
## Fixture: the shipped example_ancestry_{pedigree,rules}.csv; see
## test_matePairAncestryManifest.R and test_modMatePair_ancestry.R for the
## hand-derivation. Measured at S776 through the kernel: no override => 20
## pairs / 5 excluded; overriding CHINESE-INDIAN => 23 / 2 (3 rows overridden,
## severity block).
##
## Slow shiny-module tests (shiny::testServer()); skip on CRAN, as
## test_modMatePair.R does.
testthat::skip_on_cran()

moPed <- local({
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
moKmat <- kinship(moPed$id, moPed$sire, moPed$dam, moPed$gen)
moRules <- checkAncestryRules(readAncestryRules(system.file(
  "extdata", "examples", "example_ancestry_rules.csv",
  package = "nprcgenekeepr"
)))
## A different valid rules table that does not contain CHINESE-INDIAN.
moRulesAlt <- checkAncestryRules(data.frame(
  ancestry1 = "INDIAN", ancestry2 = "HYBRID", severity = "block",
  stringsAsFactors = FALSE
))
moNoAncPed <- moPed[, setdiff(names(moPed), "ancestry")]

moKey <- function(d) paste(d$sireId, d$damId, sep = "|")
moRuleKey <- function(a, b) paste(pmin(a, b), pmax(a, b), sep = "-")
moText <- function(rendered) paste(as.character(rendered), collapse = "")

moReason <- "Founder import approved by the colony veterinarian"
moGateText <- paste(
  "Overriding this ancestry rule lets the Mate Pair Analysis list pairs the",
  "rule would otherwise exclude, for this run only. The rule stays in your",
  "rules file, and every pair it matches is still reported, marked",
  "\"overridden\". Your stated reason is saved in the downloadable audit",
  "manifest. Confirming that this override fits your colony's",
  "genetic-management and research commitments is your responsibility, not",
  "this tool's."
)

## Pinned display strings.
moOverrideStatusOne <-
  "1 block rule(s) overridden on this tab this session: CHINESE-INDIAN."
moOverrideStatusTwo <- paste(
  "2 block rule(s) overridden on this tab this session:",
  "CHINESE-INDIAN, HYBRID-INDIAN."
)
moBlankReasonText <- "An override needs a non-empty reason."
moNoRulesText <- paste(
  "No ancestry rules loaded. Load a rules file on the Breeding Groups tab",
  "to apply it here."
)
moInactiveText <-
  "Pedigree has no ancestry column -- ancestry guardrails inactive."
moNoRunText <- paste(
  "Find eligible pairs with ancestry rules loaded to see the coverage",
  "summary and audit manifest here."
)

## Server args; `rules` is a reactive/reactiveVal handed to ancestryRules, or
## NULL to leave the argument OMITTED; `ped` may be a reactive/reactiveVal.
moArgs <- function(ped = NULL, rules = NULL) {
  args <- list(
    pedigree = if (is.null(ped)) shiny::reactive(moPed) else ped,
    kinshipMatrix = shiny::reactive(moKmat),
    markerKinshipMatrix = shiny::reactive(NULL),
    geneticValues = shiny::reactive(NULL)
  )
  args$ancestryRules <- rules
  args
}

## What the module's "allAlive" click hands the kernel, called directly -- the
## oracle for every comparison below.
moDirect <- function(ped = moPed, ...) {
  reportMatePairs(
    ped, moKmat,
    markerKmat = NULL, geneticValues = NULL, minAge = 1,
    populationIds = ped$id[is.na(ped$exit)], exclude = character(0L), ...
  )
}
moOverrideDf <- data.frame(
  ancestry1 = "INDIAN", ancestry2 = "CHINESE", reason = moReason,
  stringsAsFactors = FALSE
)

## Recorder for the modal / notification / removeModal calls the gate makes
## (the test_appServer_server.R showNotification mold: mock the package's
## imported bindings; the session proxy under testServer cannot be patched).
moRec <- function() {
  rec <- new.env()
  rec$modals <- character(0L)
  rec$notes <- list()
  rec$removed <- 0L
  rec
}
moMock <- function(rec, env = parent.frame()) {
  testthat::local_mocked_bindings(
    showModal = function(ui, ...) {
      rec$modals <- c(rec$modals, as.character(ui))
      invisible(NULL)
    },
    showNotification = function(ui, ..., type = "default") {
      rec$notes[[length(rec$notes) + 1L]] <- list(
        text = as.character(ui), type = type
      )
      invisible("note-id")
    },
    removeModal = function(...) {
      rec$removed <- rec$removed + 1L
      invisible(NULL)
    },
    .package = "nprcgenekeepr", .env = env
  )
  invisible(rec)
}

# =============================================================================
# UI (D9): the Ancestry tab and the override controls
# =============================================================================

test_that(paste(
  "modMatePairUI has the Ancestry results tab after Excluded, with the",
  "guidance, coverage table and manifest download"
), {
  ui_html <- as.character(modMatePairUI("mp"))

  tabs <- vapply(
    c('data-value="Eligible Pairs"', 'data-value="Excluded"',
      'data-value="Ancestry"'),
    function(s) regexpr(s, ui_html, fixed = TRUE)[[1L]],
    numeric(1L)
  )
  expect_true(all(tabs > 0L))
  expect_true(all(diff(tabs) > 0L))
  for (id in c(
    "mp-ancestryGuidance", "mp-ancestryCoverageTable",
    "mp-downloadAncestryManifest"
  )) {
    expect_true(grepl(sprintf('id="%s"', id), ui_html, fixed = TRUE),
      info = id
    )
  }
})

test_that(paste(
  "the override controls sit inside the collapsed guardrails panel, before",
  "the run button (D9)"
), {
  ui_html <- as.character(modMatePairUI("mp"))

  start <- regexpr('data-display-if="input.showAncestryGuardrails"', ui_html,
    fixed = TRUE
  )[[1L]]
  end <- regexpr('id="mp-analyze"', ui_html, fixed = TRUE)[[1L]]
  expect_true(start > 0L)
  expect_true(end > start)
  panel <- substr(ui_html, start, end)
  for (id in c(
    "mp-overrideRule", "mp-overrideOpen", "mp-overrideStatus",
    "mp-clearOverrides"
  )) {
    expect_true(grepl(sprintf('id="%s"', id), panel, fixed = TRUE), info = id)
  }
})

# =============================================================================
# overridableRules(): what a curator can still override
# =============================================================================

test_that(paste(
  "overridableRules() is NULL while the guardrails are inactive, else the",
  "not-yet-overridden block rules only"
), {
  skip_if_not_installed("shiny")

  ## no rules loaded
  shiny::testServer(modMatePairServer, args = moArgs(), {
    expect_null(overridableRules())
  })
  ## rules loaded but the pedigree has no ancestry column
  shiny::testServer(
    modMatePairServer,
    args = moArgs(ped = shiny::reactive(moNoAncPed),
                  rules = shiny::reactive(moRules)),
    {
      expect_null(overridableRules())
    }
  )
  ## active
  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      ovr <- overridableRules()
      expect_s3_class(ovr, "data.frame")
      expect_identical(nrow(ovr), 2L)
      expect_true(all(ovr$severity == "block"))
      expect_setequal(
        moRuleKey(ovr$ancestry1, ovr$ancestry2),
        c("CHINESE-INDIAN", "HYBRID-INDIAN")
      )

      session$setInputs(overrideRule = "CHINESE-INDIAN",
        overrideReason = moReason
      )
      session$setInputs(overrideConfirm = 1)
      ovr <- overridableRules()
      expect_identical(nrow(ovr), 1L)
      expect_identical(
        moRuleKey(ovr$ancestry1, ovr$ancestry2), "HYBRID-INDIAN"
      )
    }
  )
})

# =============================================================================
# The confirm gate (D8a)
# =============================================================================

test_that(paste(
  "Override rule... opens the gate with the verbatim Mate Pair warning, a",
  "required reason box and Confirm/Cancel -- never on a routine run"
), {
  skip_if_not_installed("shiny")
  rec <- moRec()
  moMock(rec)

  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)
      expect_length(rec$modals, 0L)

      session$setInputs(overrideRule = "CHINESE-INDIAN")
      session$setInputs(overrideOpen = 1)
      expect_length(rec$modals, 1L)
      html <- rec$modals[[1L]]
      expect_true(grepl(moGateText, html, fixed = TRUE))
      expect_true(grepl("overrideReason", html, fixed = TRUE))
      expect_true(grepl("overrideConfirm", html, fixed = TRUE))
      expect_true(grepl("Confirm Override", html, fixed = TRUE))
      expect_true(grepl("Cancel", html, fixed = TRUE))
      ## opening the gate records nothing
      expect_identical(nrow(ancestryOverridesRV()), 0L)
    }
  )
})

test_that(paste(
  "the gate does not open when nothing is overridable: no rules, an inactive",
  "pedigree, a flag rule, or no selection"
), {
  skip_if_not_installed("shiny")
  rec <- moRec()
  moMock(rec)

  ## no rules loaded
  shiny::testServer(modMatePairServer, args = moArgs(), {
    session$setInputs(overrideRule = "CHINESE-INDIAN")
    session$setInputs(overrideOpen = 1)
  })
  ## rules loaded, pedigree without an ancestry column
  shiny::testServer(
    modMatePairServer,
    args = moArgs(ped = shiny::reactive(moNoAncPed),
                  rules = shiny::reactive(moRules)),
    {
      session$setInputs(overrideRule = "CHINESE-INDIAN")
      session$setInputs(overrideOpen = 1)
    }
  )
  ## active, but the selection is a FLAG rule / not in the overridable set
  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      session$setInputs(overrideRule = "INDIAN-UNKNOWN")
      session$setInputs(overrideOpen = 1)
      expect_length(rec$modals, 0L)
    }
  )
  expect_length(rec$modals, 0L)

  ## positive control: the same server DOES open the gate for a block rule, so
  ## the zero counts above mean "refused", not "the mock never sees the call"
  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      session$setInputs(overrideRule = "HYBRID-INDIAN")
      session$setInputs(overrideOpen = 1)
    }
  )
  expect_length(rec$modals, 1L)
})

test_that(paste(
  "a confirm with a blank or missing reason is rejected: an error",
  "notification, no override recorded, the gate stays open"
), {
  skip_if_not_installed("shiny")
  rec <- moRec()
  moMock(rec)

  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      ## whitespace-only
      session$setInputs(overrideRule = "CHINESE-INDIAN",
        overrideReason = "   "
      )
      session$setInputs(overrideConfirm = 1)
      expect_identical(nrow(ancestryOverridesRV()), 0L)
      expect_null(overrideStatusText())
      expect_length(rec$notes, 1L)
      expect_identical(rec$notes[[1L]]$text, moBlankReasonText)
      expect_identical(rec$notes[[1L]]$type, "error")
      expect_identical(rec$removed, 0L)
    }
  )

  ## the reason input never set at all
  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      session$setInputs(overrideRule = "CHINESE-INDIAN")
      session$setInputs(overrideConfirm = 1)
      expect_identical(nrow(ancestryOverridesRV()), 0L)
      expect_length(rec$notes, 2L)
      expect_identical(rec$notes[[2L]]$text, moBlankReasonText)
    }
  )
})

test_that(paste(
  "a confirmed override is stored trimmed with its reason, closes the gate,",
  "shows in the status line, and Clear removes every override"
), {
  skip_if_not_installed("shiny")
  rec <- moRec()
  moMock(rec)

  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      expect_null(overrideStatusText())

      session$setInputs(overrideRule = "CHINESE-INDIAN",
        overrideReason = paste0("  ", moReason, "  ")
      )
      session$setInputs(overrideConfirm = 1)
      ov <- ancestryOverridesRV()
      expect_identical(nrow(ov), 1L)
      expect_setequal(c(ov$ancestry1, ov$ancestry2), c("INDIAN", "CHINESE"))
      expect_identical(ov$reason, moReason)
      expect_identical(rec$removed, 1L)
      expect_length(rec$notes, 0L)
      expect_identical(overrideStatusText(), moOverrideStatusOne)
      expect_match(moText(output$overrideStatus), moOverrideStatusOne,
        fixed = TRUE
      )

      ## a second override lists both rules, sorted
      session$setInputs(overrideRule = "HYBRID-INDIAN",
        overrideReason = "Second reason"
      )
      session$setInputs(overrideConfirm = 2)
      expect_identical(nrow(ancestryOverridesRV()), 2L)
      expect_identical(overrideStatusText(), moOverrideStatusTwo)

      session$setInputs(clearOverrides = 1)
      expect_identical(nrow(ancestryOverridesRV()), 0L)
      expect_null(overrideStatusText())
    }
  )
})

test_that(paste(
  "a change to the rules reaching the module resets the overrides (a new",
  "table lacking the rule, or NULL); the D4 stale-override rule"
), {
  skip_if_not_installed("shiny")

  rulesRV <- shiny::reactiveVal(moRules)
  shiny::testServer(modMatePairServer, args = moArgs(rules = rulesRV), {
    session$setInputs(overrideRule = "CHINESE-INDIAN",
      overrideReason = moReason
    )
    session$setInputs(overrideConfirm = 1)
    expect_identical(nrow(ancestryOverridesRV()), 1L)

    rulesRV(moRulesAlt)
    session$flushReact()
    expect_identical(nrow(ancestryOverridesRV()), 0L)

    ## record one against the new table, then clear the rules altogether
    session$setInputs(overrideRule = "HYBRID-INDIAN",
      overrideReason = moReason
    )
    session$setInputs(overrideConfirm = 2)
    expect_identical(nrow(ancestryOverridesRV()), 1L)
    rulesRV(NULL)
    session$flushReact()
    expect_identical(nrow(ancestryOverridesRV()), 0L)
  })
})

# =============================================================================
# The run: two-call contract + snapshot semantics (Learning 780, D8c)
# =============================================================================

test_that(paste(
  "an override flows through the run: the kernel sees the ORIGINAL rules plus",
  "the override (overridden pairs keep severity block); a finished run and",
  "its manifest are never rewritten by a later override or Clear"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)
      result <- session$getReturned()
      firstPairs <- result$pairs()
      firstExcluded <- result$excluded()
      expect_identical(nrow(firstPairs), 20L)
      expect_identical(nrow(firstExcluded), 5L)
      m1 <- ancestryManifest()
      expect_false(any(m1$overridden))
      expect_identical(
        m1$overrideSummary[1L], "No rules were overridden for this run."
      )

      ## override AFTER the run: the displayed run and its manifest stay put
      session$setInputs(overrideRule = "CHINESE-INDIAN",
        overrideReason = moReason
      )
      session$setInputs(overrideConfirm = 1)
      expect_identical(result$pairs(), firstPairs)
      expect_identical(result$excluded(), firstExcluded)
      expect_false(any(ancestryManifest()$overridden))

      ## the next click applies it -- and equals the kernel called directly
      session$setInputs(analyze = 2)
      direct <- moDirect(ancestryRules = moRules, overriddenRules = moOverrideDf)
      expect_identical(result$pairs(), direct$pairs)
      expect_identical(result$excluded(), direct$excluded)

      pairs <- result$pairs()
      excluded <- result$excluded()
      expect_identical(nrow(pairs), 23L)
      expect_identical(nrow(excluded), 2L)
      overridden <- pairs[!is.na(pairs$ancestryStatus) &
                            pairs$ancestryStatus == "overridden", ]
      expect_setequal(moKey(overridden), c("C1|I2", "I1|C2", "A1|C2"))
      expect_true(all(overridden$ancestryRule == "CHINESE-INDIAN"))
      ## the one observable a Learning-780 miswiring (passing the DOWNGRADED
      ## rules to the reporter) would change:
      expect_true(all(overridden$ancestrySeverity == "block"))
      expect_setequal(moKey(excluded), c("I1|H1", "A1|H1"))
      expect_true(all(excluded$ancestryRule == "HYBRID-INDIAN"))

      ## the manifest describes run 2: override, reason, counts, census
      m2 <- ancestryManifest()
      expect_identical(nrow(m2), 4L)
      key <- .ancestryPairKey(m2$ancestry1, m2$ancestry2)
      expect_identical(
        m2$nPairs[match(
          c("CHINESE-INDIAN", "HYBRID-INDIAN", "INDIAN-OTHER",
            "INDIAN-UNKNOWN"), key
        )],
        c(3L, 2L, 1L, 2L)
      )
      expect_identical(m2$overridden[key == "CHINESE-INDIAN"], TRUE)
      expect_identical(m2$reason[key == "CHINESE-INDIAN"], moReason)
      expect_false(any(m2$overridden[key != "CHINESE-INDIAN"]))
      expect_identical(
        unique(m2$overrideSummary), "1 of 4 rules overridden for this run."
      )
      expect_identical(unique(m2$warningText), moGateText)
      expect_identical(unique(m2$nChinese), 2L)
      expect_identical(unique(m2$nIndian), 3L)
      expect_identical(unique(m2$nUncovered), 2L)

      ## Clear AFTER run 2: run 2 (and its manifest) keep the override ...
      session$setInputs(clearOverrides = 1)
      expect_identical(nrow(ancestryOverridesRV()), 0L)
      expect_identical(result$pairs(), pairs)
      expect_identical(result$excluded(), excluded)
      expect_true(any(ancestryManifest()$overridden))
      ## ... and the next click is back to no override
      session$setInputs(analyze = 3)
      expect_identical(result$pairs(), firstPairs)
      expect_identical(result$excluded(), firstExcluded)
      expect_false(any(ancestryManifest()$overridden))
    }
  )
})

test_that(paste(
  "overrides recorded, then the pedigree loses its ancestry column: the click",
  "passes no rules and no overrides (no error), the run equals the rules-free",
  "result, and there is no manifest"
), {
  skip_if_not_installed("shiny")

  pedRV <- shiny::reactiveVal(moPed)
  shiny::testServer(
    modMatePairServer,
    args = moArgs(ped = pedRV, rules = shiny::reactive(moRules)),
    {
      session$setInputs(overrideRule = "CHINESE-INDIAN",
        overrideReason = moReason
      )
      session$setInputs(overrideConfirm = 1)
      expect_identical(nrow(ancestryOverridesRV()), 1L)

      pedRV(moNoAncPed)
      session$flushReact()
      expect_null(overridableRules())

      session$setInputs(populationSource = "allAlive", minAge = 1)
      ## the kernel stop()s on overrides given without rules; the module must
      ## not hand them over when the guardrails are inactive
      expect_no_error(expect_no_warning(session$setInputs(analyze = 1)))
      result <- session$getReturned()
      base <- moDirect(moNoAncPed)
      expect_identical(result$pairs(), base$pairs)
      expect_identical(result$excluded(), base$excluded)
      expect_null(ancestryManifest())
      expect_identical(ancestryTabGuidanceText(), moInactiveText)
    }
  )
})

test_that(paste(
  "rules-off zero change: with no rules loaded the override controls stay",
  "dormant, a run equals the rules-free result and there is no manifest"
), {
  skip_if_not_installed("shiny")
  rec <- moRec()
  moMock(rec)

  shiny::testServer(modMatePairServer, args = moArgs(), {
    expect_null(overridableRules())
    expect_null(overrideStatusText())
    expect_null(ancestryManifest())
    session$setInputs(overrideRule = "CHINESE-INDIAN")
    session$setInputs(overrideOpen = 1)
    expect_length(rec$modals, 0L)

    session$setInputs(populationSource = "allAlive", minAge = 1)
    session$setInputs(analyze = 1)
    result <- session$getReturned()
    base <- moDirect()
    expect_identical(result$pairs(), base$pairs)
    expect_identical(result$excluded(), base$excluded)
    expect_null(ancestryManifest())
    expect_identical(ancestryTabGuidanceText(), moNoRulesText)
  })
})

# =============================================================================
# The Ancestry tab: guidance states, coverage table, manifest (D9)
# =============================================================================

test_that(paste(
  "the Ancestry tab guidance states are pinned, and the manifest exists only",
  "for a displayed run that had rules in effect"
), {
  skip_if_not_installed("shiny")

  ## no rules loaded (before and after a rules-free run)
  shiny::testServer(modMatePairServer, args = moArgs(), {
    expect_identical(ancestryTabGuidanceText(), moNoRulesText)
    expect_null(ancestryManifest())
    session$setInputs(populationSource = "allAlive", minAge = 1)
    session$setInputs(analyze = 1)
    expect_identical(ancestryTabGuidanceText(), moNoRulesText)
    expect_null(ancestryManifest())
  })

  ## rules loaded, pedigree without an ancestry column: the inactive notice
  shiny::testServer(
    modMatePairServer,
    args = moArgs(ped = shiny::reactive(moNoAncPed),
                  rules = shiny::reactive(moRules)),
    {
      expect_identical(ancestryTabGuidanceText(), moInactiveText)
      expect_null(ancestryManifest())
    }
  )

  ## rules active, no run yet
  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      expect_identical(ancestryTabGuidanceText(), moNoRunText)
      expect_null(ancestryManifest())
    }
  )

  ## a run made BEFORE the rules were loaded describes no rules: still "no run
  ## with rules yet", no manifest (the displayed run is the snapshot)
  rulesRV <- shiny::reactiveVal(NULL)
  shiny::testServer(modMatePairServer, args = moArgs(rules = rulesRV), {
    session$setInputs(populationSource = "allAlive", minAge = 1)
    session$setInputs(analyze = 1)
    rulesRV(moRules)
    session$flushReact()
    expect_identical(ancestryTabGuidanceText(), moNoRunText)
    expect_null(ancestryManifest())
  })

  ## a run WITH rules: the tab shows tables, not guidance; the manifest is the
  ## run's, and stays so when the rules are cleared afterwards
  rulesRV2 <- shiny::reactiveVal(moRules)
  shiny::testServer(modMatePairServer, args = moArgs(rules = rulesRV2), {
    session$setInputs(populationSource = "allAlive", minAge = 1)
    session$setInputs(analyze = 1)
    expect_null(ancestryTabGuidanceText())
    expect_identical(nrow(ancestryManifest()), 4L)

    rulesRV2(NULL)
    session$flushReact()
    expect_null(ancestryTabGuidanceText())
    expect_identical(nrow(ancestryManifest()), 4L)
  })
})

test_that(paste(
  "the Ancestry tab's coverage table shows the run's six ancestry levels",
  "from the kernel's ancestryCoverage"
), {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)
      html <- moText(output$ancestryCoverageTable)
      for (lvl in c("CHINESE", "INDIAN", "HYBRID", "JAPANESE", "OTHER",
                    "UNKNOWN")) {
        expect_true(grepl(lvl, html, fixed = TRUE), info = lvl)
      }
    }
  )
})

test_that(paste(
  "Download Audit Manifest writes the run's manifest as a dated",
  "MatePairAncestryAuditManifest.csv; with no rules-run it declines quietly"
), {
  skip_if_not_installed("shiny")

  ## no run yet: the handler stops with a silent (req) error, not a failure
  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      expect_error(
        output$downloadAncestryManifest,
        class = "shiny.silent.error"
      )
    }
  )

  shiny::testServer(
    modMatePairServer,
    args = moArgs(rules = shiny::reactive(moRules)),
    {
      session$setInputs(overrideRule = "CHINESE-INDIAN",
        overrideReason = moReason
      )
      session$setInputs(overrideConfirm = 1)
      session$setInputs(populationSource = "allAlive", minAge = 1)
      session$setInputs(analyze = 1)

      path <- output$downloadAncestryManifest
      expect_match(basename(path), "_MatePairAncestryAuditManifest\\.csv$")
      csv <- read.csv(path, stringsAsFactors = FALSE)
      expect_identical(names(csv), names(ancestryManifest()))
      expect_identical(nrow(csv), 4L)
      key <- .ancestryPairKey(csv$ancestry1, csv$ancestry2)
      expect_identical(csv$overridden[key == "CHINESE-INDIAN"], TRUE)
      expect_identical(csv$reason[key == "CHINESE-INDIAN"], moReason)
      expect_identical(unique(csv$warningText), moGateText)
      expect_identical(
        unique(csv$overrideSummary), "1 of 4 rules overridden for this run."
      )
    }
  )
})
