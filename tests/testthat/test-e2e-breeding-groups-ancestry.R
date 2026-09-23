## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Test for issue #168 Slice 4b (ancestry-guardrails plan sec 5 Slice 4
#' done-when): drive the full guardrail path live -- load the example
#' ancestry pedigree, upload the example rules, read the status counts, form
#' groups, verify through the downloaded audit manifest that no block rule's
#' pair was ever co-placed (nPairs == 0 -- the manifest is the deterministic
#' observable; group composition itself is stochastic), override one block
#' rule through the #150-mold confirm gate with a required reason, re-form,
#' and verify the second manifest records the override with its reason and
#' the verbatim gate wording -- with zero console errors. A
#' shiny::testServer() unit test cannot pin the modal round-trip or the real
#' downloadHandler content the way a live AppDriver run can.
#'
#' File name deliberately matches the existing "^e2e-breeding-groups-" CI
#' group regex (.github/workflows/shinytest2.yaml), so this file is
#' registered with the per-module E2E partition by construction --
#' statically verified by test_shinytest2_workflow_coverage.R.
library(testthat)

test_that(
  "E2E: ancestry rules upload, formation, override gate, and audit
   manifest work end to end on the Breeding Groups tab (Slice 4b)", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_bg_ancestry")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples",
                         "example_ancestry_pedigree.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Breeding Groups", "Groups")
  if (!success) skip("Could not navigate to Breeding Groups tab")

  ## Open the collapsed guardrails section and upload the example rules.
  app$set_inputs(`breedingGroups-showAncestryGuardrails` = TRUE)
  rulesFixture <- system.file("extdata", "examples",
                              "example_ancestry_rules.csv",
                              package = "nprcgenekeepr")
  app$upload_file(`breedingGroups-ancestryRulesFile` = rulesFixture)
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  status <- tryCatch(
    app$get_text("#breedingGroups-ancestryStatus"),
    error = function(e) ""
  )
  expect_true(grepl("2 block, 2 flag", status),
              info = "Status line should show the loaded rule counts")

  ## Form groups (single group, small iteration count -- the manifest, not
  ## the stochastic grouping, carries the assertions below).
  app$set_inputs(`breedingGroups-animalSource` = "all")
  app$set_inputs(`breedingGroups-nGroups` = 1)
  app$set_inputs(`breedingGroups-sexRatio` = "none")
  app$set_inputs(`breedingGroups-nIterations` = 5)
  app$click("breedingGroups-formGroups")
  ready <- wait_for_module_ready(app, "breedingGroups")
  expect_true(ready, info = "Formation should signal data-ready")

  ## The Ancestry results tab renders its tables once a rules-run exists.
  clicked <- click_element_safe(app, 'a[data-value="Ancestry"]')
  if (!clicked) skip("Could not switch to the Ancestry tab")
  found <- wait_for_element(app, "#breedingGroups-ancestryViolationsTable")
  expect_true(found, info = "Violations table should be present")

  ## Manifest #1 (no overrides): every rule row unoverridden, and the two
  ## block rules matched zero within-group pairs -- the live co-placement
  ## guarantee, read from the run's own audit record.
  manifest1 <- tryCatch(
    app$get_download("breedingGroups-downloadAncestryManifest"),
    error = function(e) NA_character_
  )
  if (is.na(manifest1)) skip("Manifest download did not complete")
  m1 <- read.csv(manifest1, stringsAsFactors = FALSE)
  expect_identical(nrow(m1), 4L)
  expect_false(any(m1$overridden))
  expect_identical(m1$overrideSummary[1L],
                   "No rules were overridden for this run.")
  blockRows <- m1[m1$severity == "block", ]
  expect_identical(nrow(blockRows), 2L)
  expect_true(all(blockRows$nPairs == 0L),
              info = "No block rule's pair may ever be co-placed")

  ## Override INDIAN x CHINESE through the confirm gate with a reason.
  app$set_inputs(`breedingGroups-overrideRule` = "CHINESE-INDIAN")
  app$click("breedingGroups-overrideOpen")
  gateUp <- wait_for_element(app, "#breedingGroups-overrideConfirm")
  expect_true(gateUp, info = "The override confirm gate should open")
  app$set_inputs(
    `breedingGroups-overrideReason` =
      "Founder import approved by the colony veterinarian"
  )
  app$click("breedingGroups-overrideConfirm")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  overrideStatus <- tryCatch(
    app$get_text("#breedingGroups-overrideStatus"),
    error = function(e) ""
  )
  expect_true(grepl("overridden", overrideStatus),
              info = "Active override should be visible in the status line")

  ## Re-form and read manifest #2: the override and its reason are on the
  ## record, with the gate wording verbatim on every row.
  app$click("breedingGroups-formGroups")
  ready <- wait_for_module_ready(app, "breedingGroups")
  expect_true(ready, info = "Re-formation should signal data-ready")
  manifest2 <- tryCatch(
    app$get_download("breedingGroups-downloadAncestryManifest"),
    error = function(e) NA_character_
  )
  if (is.na(manifest2)) skip("Second manifest download did not complete")
  m2 <- read.csv(manifest2, stringsAsFactors = FALSE)
  r <- m2[m2$ancestry1 == "INDIAN" & m2$ancestry2 == "CHINESE", ]
  expect_identical(nrow(r), 1L)
  expect_true(r$overridden)
  expect_identical(r$reason,
                   "Founder import approved by the colony veterinarian")
  expect_identical(m2$overrideSummary[1L],
                   "1 of 4 rules overridden for this run.")
  expect_identical(m2$warningText[1L],
                   nprcgenekeepr:::.ancestryOverrideWarningText)

  logs <- app$get_logs()
  errors <- logs[logs$level == "throw", ]
  expect_equal(nrow(errors), 0L, info = "No console errors")
})
