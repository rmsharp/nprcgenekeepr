# Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Regenerates the current-UI screenshots in vignettes/articles/shiny_app_use/
# that "pedigree-diagram.qmd" relies on -- a dedicated per-tab article for the
# Pedigree Browser's Diagram tab (BACKLOG.md Housekeeping, found S544,
# 2026-08-13, Session 560), matching the established per-tab-article
# convention (age-sex-pyramid.qmd, genetic-value-analysis.qmd,
# breeding-group-formation.qmd) but -- unlike those code-only articles --
# using live-app screenshots, since the Diagram tab's content IS its visual
# rendering. Mirrors colony-manager-guide-screenshots.R's own conventions
# (shot()/do_step() helpers, shinytest2::AppDriver against the live modular
# app) but uses a fresh AppDriver per fixture group rather than one shared
# session, since each screenshot needs a DIFFERENT bundled example pedigree
# (base/affected/name/twins) -- matching the project's own E2E-test
# convention of one AppDriver per fixture (e.g.
# tests/testthat/test-e2e-pedigree-module.R), not colony-manager-guide-
# screenshots.R's single-session walkthrough.
#
# This session's own pass also regenerates pb_diagram_legend.png in place
# (colony-manager-guide.qmd's own Diagram-view screenshot), which predated
# the Option 2 kinship2-parity mating-unit/duplicate-node layout and was
# flagged stale (BACKLOG.md, found S461).
#
# Usage (repo root):
#   NOT_CRAN=true Rscript vignettes/articles/pedigree-diagram-screenshots.R
#
# Requires Chrome (chromote) and the package loadable via pkgload::load_all().
#
# Pictures are written to NPRC_SHOT_DIR when that environment variable is set
# (for example a scratch folder, to review a run before it replaces the
# guide's own pictures); otherwise to vignettes/articles/shiny_app_use/.
#   NPRC_SHOT_DIR=/path/to/scratch NOT_CRAN=true Rscript \
#     vignettes/articles/pedigree-diagram-screenshots.R

suppressMessages(pkgload::load_all(".", quiet = TRUE))
library(shinytest2)

# Reuse this project's own E2E wait/navigation helpers (upload_and_wait,
# click_element_safe, E2E_TIMEOUT, ...) rather than reinventing them -- see
# colony-manager-guide-screenshots.R's own identical rationale. Plain
# function definitions, no testthat dependency, so source()-ing them outside
# the test harness is safe -- EXCEPT create_test_app()/create_app_driver(),
# which this script deliberately does not call (create_test_app() gates on
# the NPRC_RUN_E2E env var via testthat::skip(), meaningless outside a test;
# this script builds its own AppDriver directly, matching
# colony-manager-guide-screenshots.R's own pattern).
source(file.path("tests", "testthat", "helper-shinytest2.R"))

# Shared screenshot/step/summary code (shot(), do_step(), the end-of-run
# report, the NPRC_SHOT_DIR folder setting, the page-marker reset and the
# pop-up wait), used by both guide-screenshot scripts and tested without a
# browser in tests/testthat/test_captureHarness.R.
source(file.path("tests", "testthat", "helper-captureHarness.R"))

SHOT_DIR <- capture_shot_dir(
  file.path("vignettes", "articles", "shiny_app_use")
)

## shot() and do_step() come from the shared helper and are installed here by
## start_capture_run(); see the header of helper-captureHarness.R for what
## each one records and why an idle-wait timeout before a picture is listed in
## the end-of-run summary.
recorder <- start_capture_run(SHOT_DIR)

app_dir <- system.file("shinytest", package = "nprcgenekeepr")

## new_app(): construct a fresh AppDriver against the modular app -- one per
## fixture group, matching the E2E-test convention (see header comment).
new_app <- function(name) {
  app <- shinytest2::AppDriver$new(
    app_dir, name = name, height = 900, width = 1300, load_timeout = 30000
  )
  app$wait_for_idle(timeout = 30000)
  app
}

## load_and_open_diagram(): upload a bundled example-pedigree fixture through
## the Input tab's standard QC flow (upload_and_wait(), the same helper the
## project's own E2E tests use for these exact fixtures -- no minSireAge/
## minDamAge override needed, matching test-e2e-pedigree-module.R's and
## test-e2e-twin-relations-cross-tab.R's own calls), then navigate to
## Pedigree Browser and switch to its Diagram sub-tab.
load_and_open_diagram <- function(app, fixture_name) {
  fixture <- get_test_data_path(fixture_name)
  loaded <- upload_and_wait(app, fixture)
  if (!loaded) {
    message("STEP FAILED: upload/QC for ", fixture_name)
    return(FALSE)
  }
  do_step(paste("navigate to Pedigree Browser --", fixture_name), {
    app$set_inputs(mainNavbar = "Pedigree Browser")
  })
  click_element_safe(app, 'a[data-value="Diagram"]')
}

## set_focal(): narrow the diagram to a small, feature-relevant subgraph via
## the existing Focal Animals + Trim pedigree controls (the same mechanism
## colony-manager-guide-screenshots.R's own pb_5_focal_animals_small.png
## uses). Each 375-animal bundled fixture renders far too dense/small at
## this viewport for its own distinguishing feature (a shading color, a
## connector style, a name label) to read clearly in a static screenshot --
## trimming to the animals that actually demonstrate the feature, plus
## trimPedigree()'s own ancestor/descendant walk around them, keeps every
## shot legible without hand-cropping (no crop/annotate tool in this
## project's toolchain, matching colony-manager-guide-screenshots.R's own
## framing decision).
set_focal <- function(app, ids, label) {
  do_step(paste("narrow to focal animals --", label), {
    app$set_inputs(`pedigree-focalAnimalIds` = paste(ids, collapse = ", "),
                   `pedigree-trimPedigree` = TRUE)
    app$click("pedigree-updateFocalAnimals")
    app$wait_for_idle(timeout = 30000)
  })
}

# --------------------------------------------------------------------------
# 1-2. Base fixture (obfuscated_rhesus_mhc_ped.csv, 375 animals, real
#      consanguineous matings -- the same fixture issue #149's own audit
#      confirmed carries 28 genuinely consanguineous unions, S555): default
#      "direct" edge style, then "Rectilinear (kinship2-style)".
# --------------------------------------------------------------------------
app <- new_app("pedigree_diagram_base")
ok <- load_and_open_diagram(app, "obfuscated_rhesus_mhc_ped.csv")
if (ok) {
  # Narrow to one of the fixture's 28 genuinely consanguineous unions
  # (kinship(sire, dam) = 0.25, confirmed directly via kinship() against
  # the raw fixture, independent of the app -- same evidence technique
  # test-e2e-pedigree-module.R's own consanguineous-marking test uses) plus
  # its offspring, so the marked mate-line is legible rather than lost
  # among the full 375-animal/28-union diagram.
  set_focal(app, c("8LKBV9", "FJIB3R", "GA204Z"), "consanguineous union")

  # set_focal() ends with the "Updated focal animals: N IDs" pop-up on screen;
  # in a fresh capture it overlapped the "Twin/Zygosity Relations" heading of
  # the legend (S927), so wait for it to clear before the picture below.
  do_step("wait for the focal-animals pop-up to clear", {
    wait_for_notifications_clear(app)
  })

  # 1. Default view -- sex-shaped nodes, mating-unit/duplicate-node
  #    convention, consanguineous vermillion mate-lines, legend. Replaces
  #    the stale pre-Option-2 pb_diagram_legend.png in place (kept filename
  #    so colony-manager-guide.qmd's own reference needs no path change).
  shot(app, "pb_diagram_legend.png", selector = "#pedigree-moduleContainer")

  # 2. Rectilinear edge style -- kinship2-style right-angle routing.
  do_step("select Rectilinear edge style", {
    app$set_inputs(`pedigree-pedigreeEdgeStyle` = "rectilinear")
  })
  shot(app, "diagram_rectilinear_edge_style.png",
       selector = "#pedigree-moduleContainer")
}
app$stop()

# --------------------------------------------------------------------------
# 3. Name fixture (obfuscated_rhesus_mhc_ped_name.csv): Show Names on
#    Diagram toggled on.
# --------------------------------------------------------------------------
app <- new_app("pedigree_diagram_names")
ok <- load_and_open_diagram(app, "obfuscated_rhesus_mhc_ped_name.csv")
if (ok) {
  # BRI2MW is the fixture's row-1 individual, deliberately given a name
  # long enough to exercise the diagram's own truncation (per
  # test-e2e-pedigree-module.R's own show-names test); E80KU8 is its own
  # child, 677E7M/6VUC6R two more named individuals sharing the same small
  # lineage -- together a legible few-generation, mostly-named subgraph.
  set_focal(app, c("BRI2MW", "E80KU8", "677E7M", "6VUC6R"), "named lineage")

  do_step("enable Show Names on Diagram", {
    app$set_inputs(`pedigree-pedigreeShowNames` = TRUE)
  })
  shot(app, "diagram_show_names.png", selector = "#pedigree-moduleContainer")
}
app$stop()

# --------------------------------------------------------------------------
# 4. Affected-status fixture (obfuscated_rhesus_mhc_ped_affected.csv):
#    shading is automatic (no toggle) once an `affected` column is present.
# --------------------------------------------------------------------------
app <- new_app("pedigree_diagram_affected")
ok <- load_and_open_diagram(app, "obfuscated_rhesus_mhc_ped_affected.csv")
if (ok) {
  # This fixture's own known values (test-e2e-pedigree-module.R): 677E7M is
  # affected == TRUE, BRI2MW is affected == FALSE, MND3AC is affected == NA
  # -- all three shading states in one small, legible screenshot.
  set_focal(app, c("677E7M", "BRI2MW", "MND3AC"), "affected/unaffected/NA")

  shot(app, "diagram_affected_shading.png",
       selector = "#pedigree-moduleContainer")
}
app$stop()

# --------------------------------------------------------------------------
# 5. Twin fixtures (obfuscated_rhesus_mhc_ped_twins.csv +
#    obfuscated_rhesus_mhc_twin_relations.csv): Show Twin Connectors toggled
#    on, after uploading the twin/zygosity sidecar -- MZ (solid) / DZ
#    (short-dash) / UZ (long-dash, "?") connector styling.
# --------------------------------------------------------------------------
app <- new_app("pedigree_diagram_twins")
ok <- load_and_open_diagram(app, "obfuscated_rhesus_mhc_ped_twins.csv")
if (ok) {
  do_step("upload twin/zygosity relations file", {
    app$upload_file(
      `pedigree-twinRelationsFile` = get_test_data_path(
        "obfuscated_rhesus_mhc_twin_relations.csv"
      )
    )
    app$wait_for_idle(timeout = E2E_TIMEOUT)
  })
  do_step("enable Show Twin Connectors", {
    app$set_inputs(`pedigree-pedigreeShowTwinConnectors` = TRUE)
  })
  # All 3 declared pairs from obfuscated_rhesus_mhc_twin_relations.csv --
  # E06FRB/HV7LZ3 (MZ), 8GSXTQ/P844CW (DZ), BRI2MW/677E7M (UZ) -- as focal
  # animals, so one screenshot shows all 3 connector styles (solid/
  # short-dash/long-dash-"?") at once, in their real surrounding lineage.
  set_focal(app, c("E06FRB", "HV7LZ3", "8GSXTQ", "P844CW", "BRI2MW",
                    "677E7M"), "all 3 declared twin pairs")
  shot(app, "diagram_twin_connectors.png",
       selector = "#pedigree-moduleContainer")
}
app$stop()

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
recorder$summary()
