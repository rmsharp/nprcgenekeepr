## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Test for issue #169 Slice 3b (mate-pair ancestry-guardrails plan sec 5
#' Slice 3 done-when): drive the Mate Pair Analysis ancestry guardrails live --
#' load the example ancestry pedigree, upload the example rules on the
#' Breeding Groups tab, read the Mate Pair status counts, run, read the
#' Eligible / Excluded counts and the Ancestry-tab coverage table and audit
#' manifest, override one block rule through the confirm gate (a blank reason
#' is refused), verify the displayed run's manifest is NOT rewritten by the
#' late override, re-run, and verify the override on the Eligible Pairs table,
#' its CSV export and the second manifest -- with zero console errors. A
#' shiny::testServer() unit test cannot pin the modal round-trip, the real
#' downloadHandler content or the DT render the way a live AppDriver run can.
#'
#' The numbers pinned here are the LIVE-path ones (S776, Learning 787): a blank
#' ancestry cell in the uploaded file reaches the app as OTHER, not UNKNOWN,
#' because the Input module reads uploads without na.strings, so the manifest
#' pair counts are INDIAN-UNKNOWN 0 / INDIAN-OTHER 3 and the census is
#' OTHER 2 / UNKNOWN 0. (The script path, getPedigree(), differs -- see the
#' blank-ancestry item in BACKLOG.md; if that read is ever aligned, these
#' numbers move on purpose.)
#'
#' Assertion groups, tagged A1-A13 in each `info`, so a failure names the
#' behavior it lost:
#'   A1 status line   A2 pre-run Ancestry-tab guidance   A3 override select
#'   A4 run-1 counts (b the 5 excluded pairs carry their rule, c the 3 flagged
#'   pairs are marked in the export)  A5 coverage table   A6 manifest 1 (a wording, b pair
#'   counts, c census)   A7 gate wording   A8 blank reason refused   A9 override
#'   recorded   A10 displayed run's manifest unchanged   A11 run-2 counts and
#'   `overridden` rows (a counts, b CSV, c visible)   A12 manifest 2   A13 no
#'   console errors.
#' Behavior failures FAIL; only upload/navigation infrastructure skips.
#'
#' File name deliberately matches the existing "^e2e-mate-pair-analysis-module"
#' CI group regex (.github/workflows/shinytest2.yaml), so this file is
#' registered with the per-module E2E partition by construction -- statically
#' verified by test_shinytest2_workflow_coverage.R.
library(testthat)

## The manifest's rule rows keyed the way the rules file writes them.
mpaRuleKeys <- function(m) paste(m$ancestry1, m$ancestry2, sep = "-")

## JS that serializes a rendered table's body rows as "cell|cell;cell|cell"
## (`dropFirstCell` drops DT's leading row-number column).
mpaTableRowsJs <- function(tableSelector, dropFirstCell = FALSE) {
  sprintf(
    paste0("Array.from(document.querySelectorAll('%s tbody tr')).map(",
           "r => Array.from(r.cells)%s.map(c => c.textContent.trim())",
           ".join('|')).join(';')"),
    tableSelector, if (dropFirstCell) ".slice(1)" else ""
  )
}

test_that(
  "E2E: Mate Pair ancestry rules, override gate, Ancestry tab and audit
   manifest work end to end (issue #169 Slice 3b)", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_mate_pair_ancestry",
                           height = 1100, width = 1500)
  on.exit(app$stop(), add = TRUE)

  ## Must stay nprcgenekeepr::-qualified: the nightly shinytest2 job runs this
  ## tier via testthat::test_dir(), which never attaches the package (see
  ## test_e2e_package_qualification.R, which guards this).
  fixture <- system.file("extdata", "examples",
                         "example_ancestry_pedigree.csv",
                         package = "nprcgenekeepr")
  rulesFixture <- system.file("extdata", "examples",
                              "example_ancestry_rules.csv",
                              package = "nprcgenekeepr")
  gateText <- squash_whitespace(nprcgenekeepr:::.matePairAncestryOverrideWarningText)
  reasonText <- "Founder import approved by the colony veterinarian"
  ## Tabs of the Mate Pair module only -- Breeding Groups has an "Ancestry"
  ## tab of its own.
  tabSel <- function(tab) {
    sprintf('#matePair-moduleContainer a[data-value="%s"]', tab)
  }

  if (!upload_and_wait(app, fixture)) skip("Upload/QC did not complete")

  ## The rules are loaded on the Breeding Groups tab and reach Mate Pair
  ## through appServer (plan D7).
  if (!navigate_to_tab(app, "Breeding Groups", "Groups")) {
    skip("Could not navigate to Breeding Groups tab")
  }
  app$set_inputs(`breedingGroups-showAncestryGuardrails` = TRUE)
  app$upload_file(`breedingGroups-ancestryRulesFile` = rulesFixture)
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  if (!navigate_to_tab(app, "Mate Pair Analysis")) {
    skip("Could not navigate to Mate Pair Analysis tab")
  }

  ## A1: the always-visible status line carries the loaded rule counts.
  status <- poll_js(
    app, text_content_js("#matePair-ancestryStatus"),
    done = function(v) nzchar(v) && !grepl("^No ancestry rules", v)
  )
  expect_identical(
    status, "2 block, 2 flag rule(s); 2 animal(s) uncovered.",
    info = "A1: status line shows the rule and coverage counts"
  )

  ## A2: before any run the Ancestry tab says what to do.
  if (!click_element_safe(app, tabSel("Ancestry"))) {
    skip("Could not switch to the Ancestry tab")
  }
  guidance <- poll_js(app, text_content_js("#matePair-ancestryGuidance"))
  expect_identical(
    guidance,
    paste("Find eligible pairs with ancestry rules loaded to see the",
          "coverage summary and audit manifest here."),
    info = "A2: pre-run Ancestry-tab guidance"
  )

  ## A3: the override select offers the two BLOCK rules only (the flag rules
  ## are not overridable). The controls sit in the collapsed panel; selectize
  ## keeps the choices as its options.
  app$set_inputs(`matePair-showAncestryGuardrails` = TRUE)
  optionsJs <- paste0(
    "(() => { const s = $('#matePair-overrideRule')[0]; ",
    "return (s && s.selectize) ? ",
    "Object.keys(s.selectize.options).sort().join(',') : ''; })()"
  )
  overridable <- poll_js(app, optionsJs)
  expect_identical(
    overridable, "CHINESE-INDIAN,HYBRID-INDIAN",
    info = "A3: only the block rules are offered for override"
  )

  ## Run 1 (no override). The Eligible Pairs tab must be the visible one when
  ## the run starts: DT renders lazily into a visible pane.
  if (!click_element_safe(app, tabSel("Eligible Pairs"))) {
    skip("Could not switch to the Eligible Pairs tab")
  }
  app$set_inputs(`matePair-populationSource` = "allAlive", wait_ = FALSE)
  app$set_inputs(`matePair-minAge` = 1, wait_ = FALSE)
  app$click("matePair-analyze")
  if (!wait_for_module_ready(app, "matePair", timeout = 60000)) {
    skip("Mate Pair Analysis did not signal data-ready within 60s")
  }

  ## A4: 20 eligible pairs, 5 pairs excluded by the block rules.
  expect_identical(
    poll_dt_info(app, "matePair-pairsTable", "Showing 1 to 10 of 20 entries"),
    "Showing 1 to 10 of 20 entries",
    info = "A4: run 1 shows 20 eligible pairs"
  )

  ## A4c: the 3 pairs matching a FLAG rule stay in Eligible Pairs, marked with
  ## the rule (the other 17 are unmarked) -- read from the export of the same
  ## table (the DT shows one page).
  runOneCsv <- download_csv_expect(app, "matePair-downloadPairs",
                                   "run 1 Eligible Pairs CSV")
  if (!is.null(runOneCsv)) {
    expect_identical(dim(runOneCsv), c(20L, 11L),
                     info = "A4c: run 1 export has 20 rows and 11 columns")
    hasRule <- !is.na(runOneCsv$ancestryRule) & runOneCsv$ancestryRule != ""
    marked <- runOneCsv[hasRule, c("sireId", "damId", "ancestryRule",
                                   "ancestrySeverity", "ancestryStatus")]
    marked <- marked[order(marked$sireId, marked$damId), ]
    rownames(marked) <- NULL
    expect_identical(
      marked,
      data.frame(
        sireId = c("A1", "I1", "O1"), damId = c("U1", "U1", "I2"),
        ancestryRule = "INDIAN-OTHER", ancestrySeverity = "flag",
        ancestryStatus = "violation", stringsAsFactors = FALSE
      ),
      info = "A4c: exactly the 3 flagged pairs carry their rule in Eligible Pairs"
    )
  }

  if (!click_element_safe(app, tabSel("Excluded"))) {
    skip("Could not switch to the Excluded tab")
  }
  expect_identical(
    poll_dt_info(app, "matePair-excludedTable", "Showing 1 to 5 of 5 entries"),
    "Showing 1 to 5 of 5 entries",
    info = "A4: run 1 shows 5 pairs excluded by ancestry rules"
  )

  ## A4b: each of the 5 excluded pairs carries the reason and the rule that
  ## blocked it (row number dropped; the table is client-side, so every row is
  ## in the DOM).
  excludedRows <- poll_js(
    app, mpaTableRowsJs("#matePair-excludedTable table", dropFirstCell = TRUE)
  )
  expect_identical(
    sort(strsplit(excludedRows, ";", fixed = TRUE)[[1L]]),
    sort(c("C1|I2|ancestry rule|CHINESE-INDIAN",
           "I1|C2|ancestry rule|CHINESE-INDIAN",
           "A1|C2|ancestry rule|CHINESE-INDIAN",
           "I1|H1|ancestry rule|HYBRID-INDIAN",
           "A1|H1|ancestry rule|HYBRID-INDIAN")),
    info = "A4b: each excluded pair carries the reason and the rule that blocked it"
  )

  ## A5: the coverage table -- the live census, JAPANESE reached by no rule.
  if (!click_element_safe(app, tabSel("Ancestry"))) {
    skip("Could not switch to the Ancestry tab")
  }
  coverage <- poll_js(
    app, mpaTableRowsJs("#matePair-ancestryCoverageTable table")
  )
  expect_identical(
    coverage,
    paste0("CHINESE|2|TRUE;INDIAN|3|TRUE;HYBRID|1|TRUE;",
           "JAPANESE|2|FALSE;OTHER|2|TRUE;UNKNOWN|0|TRUE"),
    info = "A5: coverage table (blank ancestry arrives as OTHER)"
  )

  ## A6: manifest 1 -- one row per rule, nothing overridden, the Mate Pair
  ## gate wording on the record, the pair counts and the animal census.
  m1 <- download_csv_expect(app, "matePair-downloadAncestryManifest", "manifest 1")
  if (!is.null(m1)) {
    expect_identical(nrow(m1), 4L, info = "A6: manifest 1 has one row per rule")
    expect_identical(m1$severity, c("block", "block", "flag", "flag"),
                     info = "A6: manifest 1 rule severities")
    expect_false(any(m1$overridden), info = "A6: manifest 1 overrides")
    expect_identical(m1$overrideSummary[1L],
                     "No rules were overridden for this run.",
                     info = "A6: manifest 1 override summary")
    expect_true(
      all(vapply(m1$warningText, squash_whitespace, character(1L)) == gateText),
      info = "A6a: manifest 1 carries the Mate Pair gate wording verbatim"
    )
    expect_identical(
      stats::setNames(m1$nPairs, mpaRuleKeys(m1)),
      c(`INDIAN-CHINESE` = 3L, `INDIAN-HYBRID` = 2L,
        `INDIAN-UNKNOWN` = 0L, `INDIAN-OTHER` = 3L),
      info = "A6b: manifest 1 pair counts per rule"
    )
    census <- unique(m1[, c("nChinese", "nIndian", "nHybrid", "nJapanese",
                            "nOther", "nUnknown", "nUncovered")])
    rownames(census) <- NULL
    expect_identical(
      census,
      data.frame(nChinese = 2L, nIndian = 3L, nHybrid = 1L, nJapanese = 2L,
                 nOther = 2L, nUnknown = 0L, nUncovered = 2L),
      info = "A6c: manifest 1 animal census"
    )
  }

  ## The override flow: select a block rule, open the confirm gate.
  app$set_inputs(`matePair-overrideRule` = "CHINESE-INDIAN", wait_ = FALSE)
  app$click("matePair-overrideOpen")
  gateUp <- wait_for_element(app, "#matePair-overrideConfirm")
  expect_true(gateUp, info = "A7: the override confirm gate opens")

  ## A7: the modal carries the Mate Pair wording verbatim.
  modalText <- poll_js(app, text_content_js(".modal-body"))
  expect_true(
    grepl(gateText, modalText, fixed = TRUE),
    info = "A7: the gate shows the Mate Pair wording verbatim"
  )

  ## A8: confirming with a blank reason is refused -- an error notification,
  ## and the gate stays open.
  app$click("matePair-overrideConfirm")
  notice <- poll_js(
    app, text_content_js("#shiny-notification-panel"),
    done = function(v) grepl("non-empty reason", v, fixed = TRUE)
  )
  expect_true(
    grepl("An override needs a non-empty reason.", notice, fixed = TRUE),
    info = "A8: a blank reason is refused with an error notification"
  )
  gateStillOpen <- wait_for_element(app, "#matePair-overrideConfirm",
                                    timeout = 3000)
  expect_true(gateStillOpen, info = "A8: the gate stays open after a refusal")

  ## A9: a written reason is accepted -- the gate closes and the status line
  ## says the override applies to THIS tab.
  if (gateStillOpen) {
    app$set_inputs(`matePair-overrideReason` = reasonText, wait_ = FALSE)
    app$wait_for_idle(timeout = E2E_TIMEOUT)
    app$click("matePair-overrideConfirm")
  }
  overrideStatus <- poll_js(
    app, text_content_js("#matePair-overrideStatus"),
    done = function(v) grepl("overridden", v, fixed = TRUE)
  )
  expect_identical(
    overrideStatus,
    "1 block rule(s) overridden on this tab this session: CHINESE-INDIAN.",
    info = "A9: the override is recorded and named on this tab"
  )
  gateClosed <- poll_js(
    app, "String(document.querySelector('#matePair-overrideConfirm') === null)",
    done = function(v) identical(v, "true"), timeout = 5000
  )
  expect_identical(gateClosed, "true", info = "A9: the gate closes on confirm")

  ## A10: the DISPLAYED run is a snapshot -- overriding afterwards never
  ## rewrites its audit manifest.
  mLate <- download_csv_expect(app, "matePair-downloadAncestryManifest",
                       "manifest of the displayed run after a late override")
  if (!is.null(mLate)) {
    expect_false(any(mLate$overridden),
                 info = "A10: a late override does not rewrite the run's manifest")
    expect_identical(mLate$overrideSummary[1L],
                     "No rules were overridden for this run.",
                     info = "A10: the displayed run's summary is unchanged")
  }

  ## Run 2 applies the override.
  if (!click_element_safe(app, tabSel("Eligible Pairs"))) {
    skip("Could not switch to the Eligible Pairs tab")
  }
  app$click("matePair-analyze")

  ## A11: 23 eligible (the 3 override-relaxed pairs join them), 2 excluded.
  expect_identical(
    poll_dt_info(app, "matePair-pairsTable", "Showing 1 to 10 of 23 entries"),
    "Showing 1 to 10 of 23 entries",
    info = "A11a: run 2 shows 23 eligible pairs"
  )
  visibleJs <- paste0(
    "String(/overridden/.test(",
    "(document.querySelector('#matePair-pairsTable') || {}).textContent ",
    "|| ''))"
  )
  expect_identical(
    poll_js(app, visibleJs, done = function(v) identical(v, "true"),
              timeout = 5000),
    "true",
    info = "A11c: overridden pairs are visible in Eligible Pairs"
  )
  pairsCsv <- download_csv_expect(app, "matePair-downloadPairs", "Eligible Pairs CSV")
  if (!is.null(pairsCsv)) {
    expect_identical(dim(pairsCsv), c(23L, 11L),
                     info = "A11b: the export has 23 rows and 11 columns")
    expect_identical(sum(pairsCsv$ancestryStatus == "overridden", na.rm = TRUE),
                     3L,
                     info = "A11b: the export marks the 3 overridden pairs")
  }
  if (!click_element_safe(app, tabSel("Excluded"))) {
    skip("Could not switch to the Excluded tab")
  }
  expect_identical(
    poll_dt_info(app, "matePair-excludedTable", "Showing 1 to 2 of 2 entries"),
    "Showing 1 to 2 of 2 entries",
    info = "A11a: run 2 shows 2 pairs excluded by ancestry rules"
  )

  ## A12: manifest 2 -- the override, its reason and the gate wording are on
  ## the record; the match counts are unchanged (an override never hides what
  ## the rule matched).
  if (!click_element_safe(app, tabSel("Ancestry"))) {
    skip("Could not switch to the Ancestry tab")
  }
  m2 <- download_csv_expect(app, "matePair-downloadAncestryManifest", "manifest 2")
  if (!is.null(m2)) {
    r <- m2[m2$ancestry1 == "INDIAN" & m2$ancestry2 == "CHINESE", ]
    expect_identical(nrow(r), 1L, info = "A12: manifest 2 has the overridden rule")
    expect_true(isTRUE(r$overridden),
                info = "A12: manifest 2 marks the rule overridden")
    expect_identical(r$reason, reasonText,
                     info = "A12: manifest 2 records the stated reason")
    expect_identical(sum(m2$overridden), 1L,
                     info = "A12: exactly one rule is overridden")
    expect_identical(m2$overrideSummary[1L],
                     "1 of 4 rules overridden for this run.",
                     info = "A12: manifest 2 override summary")
    expect_true(
      all(vapply(m2$warningText, squash_whitespace, character(1L)) == gateText),
      info = "A12: manifest 2 carries the Mate Pair gate wording verbatim"
    )
    expect_identical(
      stats::setNames(m2$nPairs, mpaRuleKeys(m2)),
      c(`INDIAN-CHINESE` = 3L, `INDIAN-HYBRID` = 2L,
        `INDIAN-UNKNOWN` = 0L, `INDIAN-OTHER` = 3L),
      info = "A12: the override does not change what each rule matched"
    )
  }

  ## A13: no uncaught JavaScript error anywhere along the path.
  logs <- app$get_logs()
  errors <- logs[logs$level == "throw", ]
  expect_equal(nrow(errors), 0L, info = "A13: no console errors")
})
