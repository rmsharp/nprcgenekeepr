## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' E2E Test for BL-N Slice 3 (twinRelations-into-kinship() plan, docs/
#' planning/twin-relations-kinship-computation-plan.md sec 4): a twinRelations
#' file uploaded on the Pedigree Browser's Diagram tab must correct kinship
#' app-wide, reflected in a tab the user visits WITHOUT ever running Genetic
#' Value Analysis -- the literal Dragon-1 scenario the plan's own Pre-RED
#' resolved (single upload point, no visit-order dependency because Shiny's
#' reactive graph runs every module server from session start, not gated by
#' tab visibility). A shiny::testServer() unit test cannot pin this end-to-end
#' cross-module propagation the way a live AppDriver run can (Slice 3's own
#' DONE criterion explicitly requires live shinytest2/chromote verification,
#' not just testServer()).
library(testthat)

test_that(
  "E2E: a twinRelations file uploaded on the Diagram tab corrects the
   Summary Statistics kinship export for the declared MZ pair, without ever
   visiting Genetic Value Analysis (Slice 3)", {
  skip_if_not_installed("shinytest2")
  skip_if_not_installed("chromote")
  skip_on_cran()

  app_dir <- create_test_app()
  app <- create_app_driver(app_dir, "e2e_twin_relations_cross_tab")
  on.exit(app$stop(), add = TRUE)

  fixture <- system.file("extdata", "examples",
                         "obfuscated_rhesus_mhc_ped_twins.csv",
                         package = "nprcgenekeepr")
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) skip("Upload/QC did not complete")

  success <- navigate_to_tab(app, "Pedigree Browser", "Pedigree")
  if (!success) skip("Could not navigate to Pedigree tab")

  clicked <- click_element_safe(app, 'a[data-value="Diagram"]')
  if (!clicked) skip("Could not switch to the Diagram tab")

  ## Upload the twin sidecar -- deliberately leave the "Show Twin Connectors"
  ## toggle untouched (its default, off). Slice 3's own return-list entry
  ## (twinRelationsData()) is the RAW, UNGATED reactive -- unlike
  ## diagramLayout()'s own gated copy (sec 2.7) -- so kinship correction must
  ## reach shared$twinRelations regardless of that toggle's state.
  twinRelationsFixture <- system.file(
    "extdata", "examples", "obfuscated_rhesus_mhc_twin_relations.csv",
    package = "nprcgenekeepr"
  )
  app$upload_file(`pedigree-twinRelationsFile` = twinRelationsFixture)
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  ## Navigate STRAIGHT to Summary Statistics -- never visiting Genetic Value
  ## Analysis -- the literal "regardless of tab visit order" DONE criterion.
  success <- navigate_to_tab(app, "Summary Statistics")
  if (!success) skip("Could not navigate to Summary Statistics tab")
  app$wait_for_idle(timeout = E2E_TIMEOUT)

  csv_path <- tryCatch(
    app$get_download("summaryStats-downloadKinship"),
    error = function(e) NA_character_
  )
  if (is.na(csv_path)) skip("Kinship matrix download did not complete")

  km <- read.csv(csv_path, row.names = 1L, check.names = FALSE)

  ## E06FRB/HV7LZ3 are the sidecar fixture's declared MZ-twin pair (same pair
  ## test-e2e-pedigree-module.R's own twin-connector tests use) -- an
  ## MZ-corrected kinship of exactly 0.5, not the ordinary full-sibling value.
  expect_true(all(c("E06FRB", "HV7LZ3") %in% rownames(km)),
             info = "Kinship export should include both twin-pair ids")
  expect_equal(km["E06FRB", "HV7LZ3"], 0.5,
              info = paste(
                "Summary Statistics' kinship export should reflect the",
                "twinRelations upload made on the Diagram tab, even though",
                "Genetic Value Analysis was never run"
              ))

  logs <- app$get_logs()
  errors <- logs[logs$level == "throw", ]
  expect_equal(nrow(errors), 0L, info = "No console errors")
})
