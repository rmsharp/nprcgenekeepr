# Copyright(c) 2017-2026 R. Mark Sharp
# This file is part of nprcgenekeepr
#
# Regenerates the nine Marker Genetics pictures that "colony-manager-guide.qmd"
# shows in vignettes/articles/shiny_app_use/ (docs-audit slice 2, Phase 4b,
# S944; docs/planning/docs-audit-slice2-screenshot-plan.md, Decision 5, which
# the owner ruled "script all nine"). Until then these nine were taken by hand
# (2026-07-30 to 2026-09-18) and nothing could retake them: by S944 the tab had
# grown to 8 sub-tabs and 4 upload boxes while the five oldest pictures showed
# 0 to 5 sub-tabs and 1 or 2 boxes, though every number in them still matched.
#
# One fresh app per scene, not the colony script's single session: that session
# holds the 3,694-animal example pedigree, and the P/C/U pictures need a pedigree
# of three or four animals (their kinship and parentage numbers come from it).
# Four pictures use files the package ships (inst/extdata/examples); five use
# the made-up data of tests/testthat/helper-markerPictureFixtures.R, which
# tests/testthat/test_markerPictureScreenshots.R runs through the real module and
# checks against the numbers the guide's captions quote.
#
# Framing: the five short pictures capture the module's whole panel
# (#markerGenetics-moduleContainer), as the colony script does. The four long
# ones (linkage coverage, LD block, genomic ROH, MHC) are screenshots of the
# browser window (shinytest2's "viewport" selector: the default, the whole
# scrollable page, is 2,000 px or more tall and would show the coverage picture
# and the LD picture as one picture twice), scrolled to the part the caption
# describes.
#
# Usage (repo root):
#   NOT_CRAN=true Rscript vignettes/articles/marker-genetics-screenshots.R
#
# Requires Chrome (chromote) and the package loadable via pkgload::load_all().
# Pictures are written to NPRC_SHOT_DIR when that environment variable is set
# (for example a scratch folder, to review a run before it replaces the guide's
# own pictures); otherwise to vignettes/articles/shiny_app_use/.

suppressMessages(pkgload::load_all(".", quiet = TRUE))
library(shinytest2)

# This project's own E2E wait/navigation helpers (click_element_safe,
# wait_for_element, get_html_safe, ...); plain function definitions, so
# source()-ing them outside the test harness is safe.
source(file.path("tests", "testthat", "helper-shinytest2.R"))

# Shared shot()/do_step()/summary code and the pop-up wait, tested without a
# browser in tests/testthat/test_captureHarness.R.
source(file.path("tests", "testthat", "helper-captureHarness.R"))

# The made-up data (genotype files and the three small pedigrees).
source(file.path("tests", "testthat", "helper-markerPictureFixtures.R"))

SHOT_DIR <- capture_shot_dir(
  file.path("vignettes", "articles", "shiny_app_use")
)
recorder <- start_capture_run(SHOT_DIR)

app_dir <- system.file("shinytest", package = "nprcgenekeepr")
container <- "#markerGenetics-moduleContainer"
fx <- markerPictureFixtures()

# Every picture is taken through this wrapper: a pop-up (for example "QC found
# 1 warning(s)") would otherwise cover part of it.
marker_shot <- function(app, filename, selector = NULL) {
  if (!wait_for_notifications_clear(app)) {
    message("a pop-up was still showing before ", filename)
  }
  shot(app, filename, selector = selector)
}

# ---- the data files, written once -------------------------------------------
write_marker_file <- function(df, filename) {
  path <- file.path(tempdir(), filename)
  utils::write.csv(df, path, row.names = FALSE)
  path
}
trio_file <- write_marker_file(fx$trioGenotype, "trio_genotype.csv")
het_file <- write_marker_file(fx$heterozygosityGenotype,
                              "heterozygosity_genotype.csv")
center_a_file <- write_marker_file(fx$centerAGenotype, "centerA.csv")
center_b_file <- write_marker_file(fx$centerBGenotype, "centerB.csv")
candidate_file <- write_marker_file(fx$candidateGenotype,
                                    "candidate_genotype.csv")
comparison_ped <- write_marker_file(fx$comparisonPedigree,
                                    "comparison_pedigree.csv")
exclusion_ped <- write_marker_file(fx$exclusionPedigree,
                                   "exclusion_pedigree.csv")
candidate_ped <- write_marker_file(fx$candidatePedigree,
                                   "candidate_pedigree.csv")
shipped <- function(filename) {
  system.file("extdata", "examples", filename, package = "nprcgenekeepr")
}

# ---- what one scene does ------------------------------------------------------
# A fresh app, run `body(app)`, stop the app. `height` is the browser window's
# height: the window pictures (viewport selector) are exactly that tall.
run_scene <- function(label, body, height = 1000) {
  app <- shinytest2::AppDriver$new(
    app_dir,
    name = paste0("marker_genetics_", label),
    height = height,
    width = 1300,
    load_timeout = 30000
  )
  on.exit(app$stop(), add = TRUE)
  app$wait_for_idle(timeout = 30000)
  body(app)
}

# Upload a pedigree on the Input tab and run QC; stop (so the step is listed as
# failed) when QC reports a missing required column.
load_pedigree <- function(app, path) {
  app$set_inputs(mainNavbar = "Input")
  do.call(app$upload_file,
          stats::setNames(list(path), "dataInput-pedigreeFileOne"))
  app$click("dataInput-getData")
  app$wait_for_idle(timeout = 30000)
  qc_errors <- get_html_safe(app, "#dataInput-qcErrors")
  if (grepl("Missing required column", qc_errors, fixed = TRUE)) {
    stop("the pedigree failed QC: a required column is missing")
  }
  TRUE
}

open_marker_genetics <- function(app) {
  app$set_inputs(mainNavbar = "Marker Genetics")
  if (!wait_for_element(app, container, timeout = 15000)) {
    stop("the Marker Genetics panel did not render within 15s")
  }
  TRUE
}

upload_marker_file <- function(app, input_id, path) {
  do.call(app$upload_file,
          stats::setNames(list(path), paste0("markerGenetics-", input_id)))
  app$wait_for_idle(timeout = 30000)
  TRUE
}

open_subtab <- function(app, label) {
  clicked <- click_element_safe(app, sprintf("a[data-value='%s']", label))
  app$wait_for_idle(timeout = 30000)
  clicked
}

# Scroll the window to the top, or to a heading by its text.
scroll_to_top <- function(app) {
  app$run_js("window.scrollTo(0, 0);")
  invisible(TRUE)
}
scroll_heading_to_top <- function(app, text) {
  found <- app$get_js(sprintf(paste0(
    "(function() {",
    " var hs = Array.from(document.querySelectorAll('h1,h2,h3,h4,h5'));",
    " var h = hs.find(function(x) { return x.textContent.trim() === '%s'; });",
    " if (!h) { return false; }",
    " window.scrollTo(0, h.getBoundingClientRect().top + window.scrollY - 10);",
    " return true; })()"), text))
  isTRUE(found)
}

# --------------------------------------------------------------------------
# 1. Kinship Comparison: P, C and U, the pedigree-based and the marker-based
#    mean kinship side by side (pedigree P, Q, U, C: C's dam is P, its sire Q).
# --------------------------------------------------------------------------
run_scene("comparison", function(app) {
  do_step("comparison: load the 4-animal pedigree",
          load_pedigree(app, comparison_ped))
  do_step("comparison: open Marker Genetics", open_marker_genetics(app))
  do_step("comparison: upload the trio genotype file",
          upload_marker_file(app, "genotypeFile", trio_file))
  marker_shot(app, "marker_genetics_comparison.png", selector = container)
})

# --------------------------------------------------------------------------
# 2. Heterozygosity: X, Y and Z (no pedigree needed).
# --------------------------------------------------------------------------
run_scene("heterozygosity", function(app) {
  do_step("heterozygosity: open Marker Genetics", open_marker_genetics(app))
  do_step("heterozygosity: upload the X, Y, Z genotype file",
          upload_marker_file(app, "genotypeFile", het_file))
  do_step("heterozygosity: open the Heterozygosity sub-tab",
          open_subtab(app, "Heterozygosity"))
  marker_shot(app, "marker_genetics_heterozygosity.png", selector = container)
})

# --------------------------------------------------------------------------
# 3. Parentage Exclusion: C's recorded dam P is consistent, its recorded sire
#    (falsely the unrelated U) is not.
# --------------------------------------------------------------------------
run_scene("parentage-exclusion", function(app) {
  do_step("parentage exclusion: load the 3-animal pedigree",
          load_pedigree(app, exclusion_ped))
  do_step("parentage exclusion: open Marker Genetics",
          open_marker_genetics(app))
  do_step("parentage exclusion: upload the trio genotype file",
          upload_marker_file(app, "genotypeFile", trio_file))
  do_step("parentage exclusion: open the Parentage Exclusion sub-tab",
          open_subtab(app, "Parentage Exclusion"))
  marker_shot(app, "marker_genetics_parentage_exclusion.png",
              selector = container)
})

# --------------------------------------------------------------------------
# 4. Cross-Center: two centers at two loci (no pedigree needed).
# --------------------------------------------------------------------------
run_scene("cross-center", function(app) {
  do_step("cross-center: open Marker Genetics", open_marker_genetics(app))
  do_step("cross-center: upload Center A",
          upload_marker_file(app, "genotypeFile", center_a_file))
  do_step("cross-center: upload Center B",
          upload_marker_file(app, "genotypeFileB", center_b_file))
  do_step("cross-center: open the Cross-Center sub-tab",
          open_subtab(app, "Cross-Center"))
  marker_shot(app, "marker_genetics_cross_center.png", selector = container)
})

# --------------------------------------------------------------------------
# 5. Candidate Parent Assignment: C's recorded sire Q is excluded (LOD minus
#    infinity, which the table shows as a blank cell). The pedigree needs a
#    fromCenter column or the tab lists no candidate at all.
# --------------------------------------------------------------------------
run_scene("candidate-assignment", function(app) {
  do_step("candidate assignment: load the 3-animal pedigree",
          load_pedigree(app, candidate_ped))
  do_step("candidate assignment: open Marker Genetics",
          open_marker_genetics(app))
  do_step("candidate assignment: upload the genotype file",
          upload_marker_file(app, "genotypeFile", candidate_file))
  do_step("candidate assignment: open the Candidate Parent Assignment sub-tab",
          open_subtab(app, "Candidate Parent Assignment"))
  marker_shot(app, "marker_genetics_candidate_assignment.png",
              selector = container)
})

# --------------------------------------------------------------------------
# 6 and 7. Linkage and LD Block Metrics, the 12-locus example STR panel: the
#    coverage report (window at the top), then the LD Block Statistic table
#    with its caveat banner (window scrolled to that heading).
# --------------------------------------------------------------------------
run_scene("linkage", function(app) {
  do_step("linkage: open Marker Genetics", open_marker_genetics(app))
  do_step("linkage: upload the STR genotype file",
          upload_marker_file(app, "linkageGenotypeFile",
                             shipped("example_str_marker_genotypes.csv")))
  do_step("linkage: upload the locus metadata file",
          upload_marker_file(app, "locusMetadataFile",
                             shipped("example_locus_metadata.csv")))
  do_step("linkage: open the Linkage and LD Block Metrics sub-tab",
          open_subtab(app, "Linkage and LD Block Metrics"))
  do_step("linkage: scroll to the top", scroll_to_top(app))
  marker_shot(app, "marker_genetics_linkage_coverage.png", selector = "viewport")
  do_step("linkage: scroll to the LD Block Statistic heading",
          scroll_heading_to_top(app, "LD Block Statistic"))
  marker_shot(app, "marker_genetics_linkage_ldblock.png", selector = "viewport")
})

# --------------------------------------------------------------------------
# 8. Genomic ROH (F_ROH): the 50-individual, 1,000-locus sequence-scale panel,
#    minimum SNP count lowered from 50 to 3 so the small panel yields segments.
# --------------------------------------------------------------------------
run_scene("genomic-roh", function(app) {
  do_step("genomic ROH: open Marker Genetics", open_marker_genetics(app))
  do_step("genomic ROH: upload the sequence genotype file",
          upload_marker_file(app, "genotypeFile",
                             shipped("example_sequence_genotypes.csv")))
  do_step("genomic ROH: upload the sequence locus metadata file",
          upload_marker_file(app, "locusMetadataFile",
                             shipped("example_sequence_locus_metadata.csv")))
  do_step("genomic ROH: open the Genomic ROH (F_ROH) sub-tab",
          open_subtab(app, "Genomic ROH (F_ROH)"))
  do_step("genomic ROH: lower the minimum SNP count to 3", {
    app$set_inputs(`markerGenetics-rohMinSnp` = 3)
    app$wait_for_idle(timeout = 30000)
    TRUE
  })
  do_step("genomic ROH: scroll to the top", scroll_to_top(app))
  marker_shot(app, "marker_genetics_genomic_roh.png", selector = "viewport")
}, height = 1100)

# --------------------------------------------------------------------------
# 9. MHC Haplotype Reporting: the bundled 31-animal file with its 375-animal
#    pedigree loaded.
# --------------------------------------------------------------------------
run_scene("mhc-haplotype", function(app) {
  do_step("MHC: load the 375-animal pedigree",
          load_pedigree(app, shipped("obfuscated_rhesus_mhc_ped.csv")))
  do_step("MHC: open Marker Genetics", open_marker_genetics(app))
  do_step("MHC: open the MHC Haplotype Reporting sub-tab",
          open_subtab(app, "MHC Haplotype Reporting"))
  do_step("MHC: upload the haplotype file",
          upload_marker_file(app, "mhcHaplotypeFile",
                             shipped("obfuscated_rhesus_mhc_breeder_genotypes.csv")))
  do_step("MHC: scroll to the top", scroll_to_top(app))
  marker_shot(app, "marker_genetics_mhc_haplotype.png", selector = "viewport")
}, height = 1300)

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
recorder$summary()
