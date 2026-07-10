# Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Regenerates the current-UI screenshots in vignettes/shiny_app_use/ that
# ColonyManagerTutorial.Rmd (and the forthcoming "colony-manager-guide.qmd",
# Document 2 -- docs/planning/document2-colony-manager-guide-plan.md) rely on.
# Driven by shinytest2::AppDriver against the live modular GeneKeepR app
# (inst/shinytest/app.R) and the shipped data(examplePedigree)/data(focalAnimals)
# example data, per the plan's Phase A gap inventory (plan doc Section 3A).
#
# Usage (repo root):
#   NOT_CRAN=true Rscript vignettes/articles/colony-manager-guide-screenshots.R
#
# Requires Chrome (chromote) and the package loadable via pkgload::load_all().
#
# Filename disposition (Phase B decision, matching Phase A's per-screenshot
# gap-inventory dispositions): "regenerate as-is" / "regenerate with updated
# framing" entries keep their ORIGINAL filename (replaced in place) so a later
# Phase C need not also update image paths. Only entries Phase A marked
# "retire" get NEW filenames, because the concept they depicted no longer
# exists in the current app.
#
# Framing decision (dragon 1, plan Section 8 item 1): the old tutorial used
# hand-cropped/annotated screenshots (e.g. a red oval highlighting one field;
# a hand-composed side-by-side .idraw comparison). This script does not
# reproduce that -- there is no crop/annotate tool in this project's toolchain
# (confirmed absent), and adding one is out of Phase B's scope. Instead every
# screenshot captures the relevant module's whole panel
# (`#<module>-moduleContainer`, or the full viewport for the Home tab), giving
# the reader full context in one image. Two old hand-composed screenshots are
# explicitly retired and replaced with two plain sequential captures instead
# (see the "Clear Focal Animals" section below).
#
# Numeric-claim continuity (Phase A Section 3A): the downstream tabs (Age-Sex
# Pyramid, Genetic Value Analysis, Summary Statistics, Breeding Groups) all
# consume Pedigree Browser's FILTERED reactive (R/appServer.R
# `shared$currentPedigree <- pedigreeResults$pedigree()`), so this script
# explicitly resets Pedigree Browser to its untrimmed default
# (trimPedigree = FALSE) before capturing them -- matching N4's "332 living
# animals from the ENTIRE example pedigree" claim, which was verified against
# the raw data(examplePedigree) object, not a focal-trimmed subset.

suppressMessages(pkgload::load_all(".", quiet = TRUE))
library(shinytest2)

# Reuse this project's own E2E wait/navigation helpers (wait_for_module_ready,
# click_element_safe, wait_for_element, E2E_TIMEOUT, ...) rather than
# reinventing them -- they already encode this app's known race conditions
# (data-ready attributes, Shiny idle polling). Plain function definitions, no
# testthat dependency, so source()-ing them outside the test harness is safe.
source(file.path("tests", "testthat", "helper-shinytest2.R"))

SHOT_DIR <- file.path("vignettes", "shiny_app_use")
if (!dir.exists(SHOT_DIR)) dir.create(SHOT_DIR, recursive = TRUE)

results <- list()

## shot(): capture a screenshot, tolerating failure so one bad step does not
## abort the whole run. Every screenshot call in this script goes through it.
shot <- function(app, filename, selector = NULL, idle_timeout = 15000) {
  # app$wait_for_idle() (the AppDriver built-in) THROWS on timeout, rather
  # than returning FALSE -- observed after breeding-group formation, where a
  # secondary render wave (group tables/selectInput choices updating) can
  # keep Shiny "busy" past the timeout even though the page is already
  # visually complete. Treat that as a soft warning, not a reason to skip
  # the screenshot -- attempt the capture regardless.
  tryCatch(app$wait_for_idle(timeout = idle_timeout), error = function(e) {
    message("idle-wait timed out before ", filename,
            " -- capturing anyway: ", conditionMessage(e))
  })
  ok <- tryCatch({
    path <- file.path(SHOT_DIR, filename)
    # get_screenshot() refuses to overwrite; this script always replaces
    # in place (see the filename-disposition note above).
    if (file.exists(path)) unlink(path)
    app$get_screenshot(path, selector = selector)
    TRUE
  }, error = function(e) {
    message("FAILED: ", filename, " -- ", conditionMessage(e))
    FALSE
  })
  results[[filename]] <<- ok
  cat(if (ok) "captured: " else "FAILED:   ", filename, "\n", sep = "")
  invisible(ok)
}

## do_step(): run a non-screenshot interaction step defensively, logging
## failure under a step label rather than a filename.
do_step <- function(label, expr) {
  ok <- tryCatch({ force(expr); TRUE }, error = function(e) {
    message("STEP FAILED: ", label, " -- ", conditionMessage(e))
    FALSE
  })
  results[[paste0("[step] ", label)]] <<- ok
  invisible(ok)
}

app_dir <- system.file("shinytest", package = "nprcgenekeepr")

# DRAGON FOUND THIS SESSION (data-corruption bug, not fixed -- out of Phase B
# scope, flagged to BACKLOG.md as high priority): makeExamplePedigreeFile(...,
# fileType = "excel") + readDataFile()'s readxl::read_excel(file$datapath)
# (R/modInput.R, no col_types argument) silently corrupts sire/dam for the
# shipped example pedigree -- readxl infers column type from early rows,
# guesses "logical" because many early sire/dam values are blank, then
# converts every later alphanumeric ID to NA once it can't parse it as
# logical. Confirmed this session: 2026/2026 (100%) of non-blank sire values
# and 2023/2026 dam values become NA on an Excel round-trip of
# data(examplePedigree), with 4049 readxl warnings never surfaced to the
# user. This is the SAME code path any real user's Excel-format pedigree
# upload goes through -- not specific to this script. The tutorial's own
# instructions default to Excel ("we will use an Excel file..."); until the
# bug is fixed, this script uses CSV instead so the captured screenshots
# reproduce Phase A's already-confirmed numbers (54/962/332) rather than
# silently depicting a broken-pedigree state. Phase C must account for this
# -- either wait for a fix, or explicitly narrate CSV as the demonstrated
# format.
example_file <- makeExamplePedigreeFile(
  file.path(tempdir(), "Example_Pedigree.csv"),
  fileType = "csv"
)

# The shipped `focalAnimals` example data object (327 ids) is the
# "large focal group" example -- see Phase A's N3 verdict (the tutorial's
# original, undocumented "85 focal animals" list does not reproduce; this
# script uses the package's own named example object instead, giving a
# reproducible 962-animal trim, confirmed in Phase A).
large_focal_csv <- tempfile(fileext = ".csv")
utils::write.csv(data.frame(id = focalAnimals$id), large_focal_csv,
                 row.names = FALSE)

app <- shinytest2::AppDriver$new(
  app_dir,
  name = "colony_manager_guide_screenshots",
  height = 900,
  width = 1300,
  load_timeout = 30000
)
on.exit(app$stop(), add = TRUE)
app$wait_for_idle(timeout = 30000)

# --------------------------------------------------------------------------
# 1. Home tab (NEW -- replaces retired opening_screen_top/middle/bottom.png)
# --------------------------------------------------------------------------
shot(app, "home_tab_landing.png")

# --------------------------------------------------------------------------
# 2. Input tab (NEW -- second half of the opening_screen_* retirement)
# --------------------------------------------------------------------------
do_step("navigate to Input", app$set_inputs(mainNavbar = "Input"))
# "Input Format" is the tabsetPanel's first/default tabPanel.
shot(app, "input_format_subtab.png", selector = "#dataInput-moduleContainer")

# --------------------------------------------------------------------------
# 3. Input tab: file-selection sidebar, before a file is chosen
#    (opening_screen_top_red_oval.png -- kept name, updated framing)
# --------------------------------------------------------------------------
shot(app, "opening_screen_top_red_oval.png",
     selector = "#dataInput-moduleContainer")

# --------------------------------------------------------------------------
# 4. Input tab: after selecting the example Excel file
#    (input_example_pedigree_xlsx.png -- kept name, updated framing)
# --------------------------------------------------------------------------
do_step("upload example pedigree file", {
  do.call(app$upload_file,
          stats::setNames(list(example_file), "dataInput-pedigreeFileOne"))
})
shot(app, "input_example_pedigree_xlsx.png",
     selector = "#dataInput-moduleContainer")

# --------------------------------------------------------------------------
# 5. Input tab: minimum sire/dam age fields filled in
#    (input_minParentAgeSequence.png -- kept name, updated framing;
#    simplified from the old hand-composed multi-panel "sequence" to a
#    single capture of the current split sire/dam fields, per Phase B's
#    no-crop/annotate-tool framing decision above)
# --------------------------------------------------------------------------
do_step("fill min sire/dam age", {
  app$set_inputs(`dataInput-minSireAge` = "2", `dataInput-minDamAge` = "2")
})
shot(app, "input_minParentAgeSequence.png",
     selector = "#dataInput-moduleContainer")

# --------------------------------------------------------------------------
# 6. Input tab: after Read and Check Pedigree (QC Summary sub-tab)
#    (read_and_check_pedigree.png -- kept name, regenerate as-is)
# --------------------------------------------------------------------------
do_step("click Read and Check Pedigree", {
  app$click("dataInput-getData")
  app$wait_for_idle(timeout = 30000)
})
do_step("switch to QC Summary sub-tab", {
  app$set_inputs(`dataInput-mainTabs` = "QC Summary")
})
shot(app, "read_and_check_pedigree.png",
     selector = "#dataInput-moduleContainer")

# --------------------------------------------------------------------------
# Pedigree Browser tab
# --------------------------------------------------------------------------
do_step("navigate to Pedigree Browser", {
  app$set_inputs(mainNavbar = "Pedigree Browser")
})

# 7. Default view, 10(→15)-row table, Display Unknown IDs checked (default)
#    (pb_10_rows_display_unknown_ids.png -- kept name, updated framing)
shot(app, "pb_10_rows_display_unknown_ids.png",
     selector = "#pedigree-moduleContainer")

# 8. Same state, illustrating UNKNOWN IDs specifically. DT's client-side
#    search box is not a bound Shiny input in this table's configuration
#    (confirmed: app$set_inputs("pedigree-pedigreeTable_search", ...) errors
#    with "Unable to find input binding"), so this is captured as the same
#    default view as #7 rather than a filtered one -- documented duplication,
#    not a silent gap.
shot(app, "pb_unknown_displayed.png", selector = "#pedigree-moduleContainer")

# 9. Display Unknown IDs unchecked
#    (pb_no_unknown_displayed.png -- kept name, updated framing)
do_step("uncheck Display Unknown IDs", {
  app$set_inputs(`pedigree-displayUnknownIds` = FALSE)
})
shot(app, "pb_no_unknown_displayed.png", selector = "#pedigree-moduleContainer")
do_step("recheck Display Unknown IDs (restore default)", {
  app$set_inputs(`pedigree-displayUnknownIds` = TRUE)
})

# 10. Empty Focal Animals panel, before typing any IDs
#     (pb_focal_animal_text_box.png -- kept name, updated framing)
shot(app, "pb_focal_animal_text_box.png",
     selector = "#pedigree-moduleContainer")

# 11. Small 5-focal-animal example -- confirmed 54-animal trim (Phase A N2).
#     Operation order does not matter here: the server's pedigreeData()
#     reactive always filters unknown-ids THEN trims, regardless of the
#     order UI checkboxes are toggled (R/modPedigree.R).
#     (pb_5_focal_animals_small.png -- kept name, updated framing)
do_step("enter 5 focal animal IDs", {
  app$set_inputs(
    `pedigree-focalAnimalIds` = "FJS7RQ, H6T2FF, HEVL3L, I04JZV, S63QDN"
  )
})
do_step("uncheck Display Unknown IDs + check Trim pedigree (5-animal case)", {
  app$set_inputs(`pedigree-displayUnknownIds` = FALSE,
                 `pedigree-trimPedigree` = TRUE)
})
do_step("click Update Focal Animals (5-animal case)", {
  app$click("pedigree-updateFocalAnimals")
  app$wait_for_idle(timeout = 30000)
})
shot(app, "pb_5_focal_animals_small.png", selector = "#pedigree-moduleContainer")

# Reset for the large-group example: clear the typed IDs (the CSV upload
# path is used instead), untrim for now. Display Unknown IDs stays FALSE
# (NOT reset to the app's TRUE default) -- Phase A's N3 re-derivation (962
# animals for the shipped `focalAnimals` object) used the same
# filter-unknown-then-trim order as N2's confirmed 54-animal result;
# leaving it TRUE here inflates the trimmed count (1,144, verified this
# session) because UNKNOWN placeholder ids widen the ancestor/descendant
# search itself, not just the display.
do_step("reset before large focal group example", {
  app$set_inputs(`pedigree-displayUnknownIds` = FALSE,
                 `pedigree-trimPedigree` = FALSE,
                 `pedigree-focalAnimalIds` = "")
})

# 12. Large focal group via CSV upload -- the shipped `focalAnimals` object
#     (327 ids), matching the tutorial's own CSV-upload framing (not typing).
#     (pb_selection_large_focal_group.png -- kept name, updated framing,
#     new focal-ID list per Phase A's N3 verdict)
do_step("upload large focal-group CSV", {
  do.call(app$upload_file,
          stats::setNames(list(large_focal_csv), "pedigree-focalAnimalFile"))
})
shot(app, "pb_selection_large_focal_group.png",
     selector = "#pedigree-moduleContainer")

# 13. Trim pedigree checkbox selected, before clicking Update
#     (pb_select_trim_for_focal_animals.png -- kept name, updated framing)
do_step("check Trim pedigree (large-group case)", {
  app$set_inputs(`pedigree-trimPedigree` = TRUE)
})
shot(app, "pb_select_trim_for_focal_animals.png",
     selector = "#pedigree-moduleContainer")

# 14. Trimmed result (962 animals per Phase A's re-derivation)
#     (pb_trimmed_for_focal_animals.png -- kept name, updated framing)
do_step("click Update Focal Animals (large-group case)", {
  app$click("pedigree-updateFocalAnimals")
  app$wait_for_idle(timeout = 30000)
})
shot(app, "pb_trimmed_for_focal_animals.png",
     selector = "#pedigree-moduleContainer")

# 15/16. Clear Focal Animals -- NEW two-capture replacement for the retired
#        hand-composed pb_cleared_focal_animals_combined.png (+ .idraw).
shot(app, "pb_focal_animals_before_clear.png",
     selector = "#pedigree-moduleContainer")
do_step("check Clear Focal Animals and Update", {
  app$set_inputs(`pedigree-clearFocalAnimals` = TRUE)
  app$click("pedigree-updateFocalAnimals")
  app$wait_for_idle(timeout = 30000)
})
shot(app, "pb_focal_animals_after_clear.png",
     selector = "#pedigree-moduleContainer")

# Per the tutorial's own instruction, reverse the clear -- but land on the
# UNTRIMMED default (trimPedigree = FALSE) for the downstream tabs, since
# they consume this filtered reactive and N4 (332 living animals) was
# verified against the entire, untrimmed example pedigree.
do_step("restore default (untrimmed) Pedigree Browser state", {
  app$set_inputs(`pedigree-clearFocalAnimals` = FALSE,
                 `pedigree-trimPedigree` = FALSE,
                 `pedigree-displayUnknownIds` = TRUE)
  app$click("pedigree-updateFocalAnimals")
  app$wait_for_idle(timeout = 30000)
})

# --------------------------------------------------------------------------
# Age-Sex Pyramid tab (age_plot.png -- kept name, updated framing)
# --------------------------------------------------------------------------
do_step("navigate to Age-Sex Pyramid", {
  app$set_inputs(mainNavbar = "Age-Sex Pyramid")
})
shot(app, "age_plot.png", selector = "#pyramid-moduleContainer")

# --------------------------------------------------------------------------
# Genetic Value Analysis tab
# --------------------------------------------------------------------------
do_step("navigate to Genetic Value Analysis", {
  app$set_inputs(mainNavbar = "Genetic Value Analysis")
})

# gva_calculating.png -- kept name, updated framing (mandatory). A
# mid-progress spinner capture is inherently racy under automation; this
# captures the run-READY state instead, which is what is actually new here
# (the Kinship Overrides panel did not exist in the source tutorial).
shot(app, "gva_calculating.png", selector = "#geneticValue-moduleContainer")

do_step("run Genetic Value Analysis (1000 iterations, default threshold)", {
  # app$click("id") calls set_inputs(id = "click") internally, which blocks
  # on Shiny returning within its ~4s default -- far too short for a
  # 1000-iteration gene drop. click_element_safe() (this project's own E2E
  # helper) performs a raw selector click instead, which does not block the
  # same way; the real wait happens in the explicit step below.
  click_element_safe(app, "#geneticValue-runAnalysis")
})
do_step("wait for Genetic Value Analysis to complete", {
  if (!wait_for_module_ready(app, "geneticValue", timeout = 300000)) {
    stop("Genetic Value Analysis did not complete within 300s")
  }
})

# gva_first_high_value.png -- kept name, updated framing
shot(app, "gva_first_high_value.png", selector = "#geneticValue-moduleContainer")

# gva_high_and_low_value.png -- kept name, updated framing. Widen "Show top
# N" so more of the ranking (including lower-ranked/Undetermined rows) is
# in scope; the exact cutover row is a live number Phase C must capture
# itself when it drafts prose (Phase A N6 -- not pre-guessed here).
do_step("widen Show top N for the high/low value view", {
  app$set_inputs(`geneticValue-topN` = 500)
})
shot(app, "gva_high_and_low_value.png", selector = "#geneticValue-moduleContainer")

# --------------------------------------------------------------------------
# Summary Statistics tab
# --------------------------------------------------------------------------
do_step("navigate to Summary Statistics", {
  app$set_inputs(mainNavbar = "Summary Statistics")
})
# ss_first_view.png -- kept name, regenerate as-is
shot(app, "ss_first_view.png", selector = "#summaryStats-moduleContainer")
# ss_trimmed_all_plots.png -- kept name, regenerate as-is (the six
# histogram/boxplot panel)
shot(app, "ss_trimmed_all_plots.png", selector = "#summaryStats-moduleContainer")
# ss_export_mean_kinship_coefficient_histogram.png -- kept name, regenerate
# as-is (same panel; the original screenshot illustrates the exported plot,
# which is this panel's live rendering, not a separate app state)
shot(app, "ss_export_mean_kinship_coefficient_histogram.png",
     selector = "#summaryStats-moduleContainer")

## NOTE -- three files this script deliberately does NOT touch, a Phase B
## correction to Phase A's own "regenerate as-is" disposition for them:
## ss_kinship_matrix.png, ss_first_order_relationships.png, and
## ss_female_founders.png illustrate the CONTENTS of an exported CSV opened
## in a spreadsheet program ("The first few rows of such a file are shown
## below" -- ColonyManagerTutorial.Rmd L549, L564, L580), not app UI. Like
## examplePedigreeTutorial.png / examplePedigreeTutorial_with_alleles.png,
## shinytest2::AppDriver cannot produce these, and they are unaffected by
## the Shiny-module migration -- left untouched, matching the treatment
## Phase A already gave the two examplePedigreeTutorial files.

# --------------------------------------------------------------------------
# Breeding Group Formation tab
# --------------------------------------------------------------------------
do_step("navigate to Breeding Groups", {
  app$set_inputs(mainNavbar = "Breeding Groups")
})

# breeding_group_first_view.png -- kept name, updated framing (mandatory)
shot(app, "breeding_group_first_view.png",
     selector = "#breedingGroups-moduleContainer")

# breeding_group_1.png -- kept name, updated framing (1 group desired)
do_step("set Number of groups = 1 and Form Groups", {
  app$set_inputs(`breedingGroups-nGroups` = 1, wait_ = FALSE)
  click_element_safe(app, "#breedingGroups-formGroups")
})
do_step("wait for 1-group formation to complete", {
  if (!wait_for_module_ready(app, "breedingGroups", timeout = 180000)) {
    stop("1-group formation did not complete within 180s")
  }
})
shot(app, "breeding_group_1.png", selector = "#breedingGroups-moduleContainer")

# breeding_group_6_infants_with_dam.png -- kept name, updated framing.
# The current UI's dynamic per-group seed textareas are shown; hand-picking
# real infant/dam ID pairs for all 6 groups is a content-authoring decision
# left to Phase C (which drafts the actual narrative), not invented here --
# see this session's HANDOFFS.md / plan-doc note.
do_step("set Number of groups = 6 and enable seed groups", {
  app$set_inputs(`breedingGroups-nGroups` = 6,
                 `breedingGroups-seedGroups` = TRUE, wait_ = FALSE)
})
do_step("wait for seed textareas to render", {
  if (!wait_for_element(app, "#breedingGroups-seedTextareas",
                        timeout = 10000)) {
    stop("seed textareas did not render within 10s")
  }
})
shot(app, "breeding_group_6_infants_with_dam.png",
     selector = "#breedingGroups-moduleContainer")

do_step("form 6 seeded groups", {
  click_element_safe(app, "#breedingGroups-formGroups")
})
do_step("wait for 6-group formation to complete", {
  if (!wait_for_module_ready(app, "breedingGroups", timeout = 180000)) {
    stop("6-group formation did not complete within 180s")
  }
})

# breeding_group_first_group_no_kinship_seeds_indicated.png -- kept name,
# updated framing (Group Detail sub-tab, group 1, no kinship)
do_step("open Group Detail sub-tab", {
  click_element_safe(app, "a[data-value='Group Detail']")
})
shot(app, "breeding_group_first_group_no_kinship_seeds_indicated.png",
     selector = "#breedingGroups-moduleContainer")

# breeding_group_6_seed_grps_grp_6_kinship.png -- kept name, updated framing
# (with-kinship + group 6 selected)
do_step("enable Include kinship and re-form groups", {
  app$set_inputs(`breedingGroups-withKinship` = TRUE, wait_ = FALSE)
  click_element_safe(app, "#breedingGroups-formGroups")
})
do_step("wait for kinship-enabled group formation to complete", {
  if (!wait_for_module_ready(app, "breedingGroups", timeout = 180000)) {
    stop("kinship-enabled group formation did not complete within 180s")
  }
})
do_step("select group 6 in Group Detail", {
  click_element_safe(app, "a[data-value='Group Detail']")
  app$set_inputs(`breedingGroups-viewGrp` = "Group 6", wait_ = FALSE)
  app$wait_for_idle(timeout = 10000)
})
shot(app, "breeding_group_6_seed_grps_grp_6_kinship.png",
     selector = "#breedingGroups-moduleContainer")

# breeding_group_sex_ratio_specification.png -- kept name, updated framing.
# DRAGON FOUND THIS SESSION (not fixed -- out of Phase B scope, flagged to
# BACKLOG.md): the current UI's "Custom" sexRatio radio choice has NO
# accompanying numeric-value input anywhere in modBreedingGroupsUI(); the
# server's parseSexRatio(input$sexRatio) tries as.numeric("custom"), which
# is NA and silently falls back to 0.0 -- identical to "None". The tutorial's
# "sex ratio of 2.5" demonstration (N7) cannot currently be reproduced
# through the UI at all. This screenshot shows the "Custom" option selected
# (the option exists) but Phase C must NOT claim a working numeric-ratio
# demonstration until this gap is fixed.
do_step("select Custom sex ratio (see dragon note above)", {
  app$set_inputs(`breedingGroups-sexRatio` = "custom",
                 `breedingGroups-withKinship` = FALSE, wait_ = FALSE)
  app$wait_for_idle(timeout = 10000)
})
shot(app, "breeding_group_sex_ratio_specification.png",
     selector = "#breedingGroups-moduleContainer")

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
cat("\n==================== capture summary ====================\n")
n_ok <- sum(vapply(results, isTRUE, logical(1L)))
n_total <- length(results)
cat(sprintf("%d/%d steps succeeded\n", n_ok, n_total))
if (n_ok < n_total) {
  cat("Failed steps:\n")
  for (nm in names(results)) {
    if (!isTRUE(results[[nm]])) cat("  - ", nm, "\n", sep = "")
  }
}
