## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md docs-audit item, slice 2 Phase 4b (S944; the owner ruled D5:
## script all nine). The colony manager guide shows nine Marker Genetics
## pictures that were taken by hand between 2026-07-30 and 2026-09-18 and that
## no script makes. Measured S944 in the real app (headless): every number in
## each picture still matches what the tab shows, but the tab now has 8
## sub-tabs and 4 upload boxes where the five oldest pictures show 0 to 5
## sub-tabs and 1 or 2 boxes. Four pictures use data the package ships
## (inst/extdata/examples); five use made-up data that the hand-checked
## fixtures in test_modMarkerGenetics.R reproduce exactly.
##
## The new script, vignettes/articles/marker-genetics-screenshots.R, starts one
## fresh app per picture (the colony script's single session holds the
## 3,694-animal example pedigree, which the P/C/U pictures cannot use). Its
## made-up data comes from one helper, tests/testthat/helper-markerPictureFixtures.R,
## which this file pins. The helper's contract:
##
##   markerPictureFixtures()   a named list of data frames:
##     trioGenotype            P, C, U at loci L1-L10 (long format: id, locus,
##                             allele1, allele2)
##     heterozygosityGenotype  X, Y, Z at loci L1-L4 (Y has no L4)
##     centerAGenotype         Center A's file for the Cross-Center picture
##     centerBGenotype         Center B's file
##     candidateGenotype       the trio with U renamed Q (the Candidate picture)
##     comparisonPedigree      P, Q, U, C: C's dam is P, its sire is Q, U is
##                             unrelated (columns id, sire, dam, sex, birth as
##                             ISO text, fromCenter)
##     exclusionPedigree       P, U, C: C's recorded dam is P, its recorded
##                             sire is the unrelated U
##     candidatePedigree       P, Q, C: C's recorded sire is Q; has a
##                             fromCenter column (getPotentialParents() finds
##                             no candidate without one, R/getPotentialParents.R:101)
##
## The tests that read the guide or the script read ../../vignettes/articles/...,
## which .Rbuildignore excludes: a built package holds no copy, so they skip in
## a built package and under `devtools::check()`, and run from the source tree,
## where the close-out suite runs. The one control that passes before the
## script exists is the first block (the guide cites exactly nine pictures and
## all nine files exist).

pkg_root <- testthat::test_path("..", "..")
scriptDir <- file.path(pkg_root, "vignettes", "articles")
guidePath <- file.path(scriptDir, "colony-manager-guide.qmd")
picturesDir <- file.path(scriptDir, "shiny_app_use")
markerScript <- file.path(scriptDir, "marker-genetics-screenshots.R")
examplesDir <- file.path(pkg_root, "inst", "extdata", "examples")

markerPictures <- c(
  "marker_genetics_comparison.png",
  "marker_genetics_heterozygosity.png",
  "marker_genetics_parentage_exclusion.png",
  "marker_genetics_cross_center.png",
  "marker_genetics_candidate_assignment.png",
  "marker_genetics_linkage_coverage.png",
  "marker_genetics_linkage_ldblock.png",
  "marker_genetics_genomic_roh.png",
  "marker_genetics_mhc_haplotype.png"
)
shippedFiles <- c(
  "example_str_marker_genotypes.csv", "example_locus_metadata.csv",
  "example_sequence_genotypes.csv", "example_sequence_locus_metadata.csv",
  "obfuscated_rhesus_mhc_breeder_genotypes.csv", "obfuscated_rhesus_mhc_ped.csv"
)

skipWithoutSources <- function() {
  skip_if_not(dir.exists(scriptDir),
              "vignettes/articles not present (it is build-ignored)")
}

readGuide <- function() {
  skipWithoutSources()
  skip_if_not(file.exists(guidePath), "colony manager guide not present")
  readLines(guidePath, warn = FALSE)
}

## The script's lines. When the script is missing the file test fails (the
## source tree has it from S944 on) and an empty vector is returned, so every
## later expectation about its text fails for the same reason.
readMarkerScript <- function() {
  skipWithoutSources()
  present <- file.exists(markerScript)
  expect_true(present, info = "vignettes/articles/marker-genetics-screenshots.R")
  if (!present) return(character(0))
  readLines(markerScript, warn = FALSE)
}

codeOnly <- function(lines) lines[!grepl("^\\s*#", lines)]

## The pictures a script takes: the first string argument of each marker_shot()
## call outside comments.
shotNames <- function(lines) {
  calls <- grep("marker_shot\\(app, \"", codeOnly(lines), value = TRUE)
  sub("^.*marker_shot\\(app, \"([^\"]+)\".*$", "\\1", calls)
}

## Run the pedigree through the same steps the app's Input tab does for an
## uploaded file: write it as a CSV, read it back, runQcStudbook().
qcdPedigree <- function(ped) {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(ped, path, row.names = FALSE)
  runQcStudbook(
    utils::read.csv(path, stringsAsFactors = FALSE, na.strings = c("", "NA")),
    minSireAge = NULL, minDamAge = NULL, reportChanges = TRUE
  )$cleaned
}

writeGenotype <- function(df) {
  path <- tempfile(fileext = ".csv")
  utils::write.csv(df, path, row.names = FALSE)
  path
}

## Run modMarkerGeneticsServer on the fixtures and hand back its returned
## reactives' current values for the tables the pictures show.
runMarkerModule <- function(fx, genotype, genotypeB = NULL, pedigree = NULL,
                            kinshipMatrix = NULL) {
  pictureOut <- new.env()
  pictureKmat <- kinshipMatrix
  if (is.null(pictureKmat)) {
    pictureKmat <- matrix(0, 1L, 1L, dimnames = list("none", "none"))
  }
  picturePed <- pedigree
  pictureInputs <- list(genotypeFile = list(
    name = "genotype.csv", datapath = writeGenotype(genotype)))
  if (!is.null(genotypeB)) {
    pictureInputs$genotypeFileB <- list(
      name = "genotypeB.csv", datapath = writeGenotype(genotypeB))
  }
  pictureGrab <- function(f) tryCatch(f(), error = function(e) NULL)
  shiny::testServer(
    modMarkerGeneticsServer,
    args = list(kinshipMatrix = shiny::reactive(pictureKmat),
                pedigree = shiny::reactive(picturePed)),
    {
      pictureResult <- session$getReturned()
      suppressWarnings(do.call(session$setInputs, pictureInputs))
      assign("comparison", pictureGrab(pictureResult$comparisonTable),
             envir = pictureOut)
      assign("heterozygosity", pictureGrab(pictureResult$heterozygosityTable),
             envir = pictureOut)
      assign("exclusion", pictureGrab(pictureResult$exclusionTable),
             envir = pictureOut)
      assign("crossCenter", pictureGrab(pictureResult$crossCenterTable),
             envir = pictureOut)
      assign("candidate", pictureGrab(pictureResult$candidateAssignmentTable),
             envir = pictureOut)
    }
  )
  as.list(pictureOut)
}

## ---- control: the guide's nine pictures -----------------------------------

test_that("the guide cites exactly the nine Marker Genetics pictures and all nine files exist", {
  lines <- readGuide()
  skip_if_not(dir.exists(picturesDir), "picture folder not present")
  cited <- unique(regmatches(
    lines, regexpr("marker_genetics_[a-z_]+\\.png", lines)))
  expect_setequal(cited, markerPictures)
  expect_true(all(file.exists(file.path(picturesDir, markerPictures))))
})

## ---- the script's own text --------------------------------------------------

test_that("the Marker Genetics script uses the shared helpers and carries no copy of shot() or do_step()", {
  lines <- readMarkerScript()
  expect_true(any(grepl("helper-captureHarness\\.R", lines)))
  expect_true(any(grepl("helper-markerPictureFixtures\\.R", lines)))
  expect_false(any(grepl("^(shot|do_step) <- function", lines)))
})

test_that("the Marker Genetics script takes its folder from capture_shot_dir() and ends with the recorder's summary", {
  lines <- readMarkerScript()
  expect_true(any(grepl("capture_shot_dir\\(", lines)))
  expect_true(any(grepl("\\$summary\\(\\)", lines)))
})

test_that("the Marker Genetics script takes exactly the nine pictures the guide shows, each once", {
  lines <- readMarkerScript()
  expect_setequal(shotNames(lines), markerPictures)
  expect_false(anyDuplicated(shotNames(lines)) > 0L)
})

test_that("every picture is taken through marker_shot(), which waits for pop-ups to clear first", {
  lines <- readMarkerScript()
  code <- codeOnly(lines)
  def <- grep("^marker_shot <- function", code)
  expect_length(def, 1L)
  if (length(def) == 1L) {
    ## the wrapper's body: from its definition to the closing brace at line start
    ends <- grep("^\\}", code)
    body <- code[def:min(ends[ends > def])]
    expect_true(any(grepl("wait_for_notifications_clear\\(", body)))
    expect_true(any(grepl("(^|[^_a-z])shot\\(", body)))
  }
  ## no other direct shot() call anywhere in the script
  direct <- grep("(^|[^_a-z])shot\\(", code)
  expect_length(direct, 1L)
  ## and no wait result is ignored
  waits <- grep("wait_for_(element|module_ready)\\(", code, value = TRUE)
  for (call in waits) {
    expect_match(call, "^\\s*if \\(!wait_for_(element|module_ready)\\(",
                 info = trimws(call))
  }
})

test_that("the script reads the six data files the package ships for the four shipped-data pictures, and they exist", {
  lines <- readMarkerScript()
  code <- paste(codeOnly(lines), collapse = "\n")
  for (f in shippedFiles) {
    expect_match(code, f, fixed = TRUE, info = f)
    expect_true(file.exists(file.path(examplesDir, f)), info = f)
  }
})

## ---- the made-up data, run through the real module --------------------------

test_that("markerPictureFixtures() returns the eight data frames the script uploads", {
  fx <- markerPictureFixtures()
  expect_setequal(names(fx), c(
    "trioGenotype", "heterozygosityGenotype", "centerAGenotype",
    "centerBGenotype", "candidateGenotype", "comparisonPedigree",
    "exclusionPedigree", "candidatePedigree"))
  for (nm in names(fx)) expect_s3_class(fx[[nm]], "data.frame")
})

test_that("the comparison picture's data gives the table its caption describes", {
  fx <- markerPictureFixtures()
  ped <- qcdPedigree(fx$comparisonPedigree)
  kmat <- kinship(ped$id, ped$sire, ped$dam,
                  findGeneration(ped$id, ped$sire, ped$dam))
  tbl <- runMarkerModule(fx, fx$trioGenotype, pedigree = ped,
                         kinshipMatrix = kmat)$comparison
  tbl <- tbl[order(tbl$id), ]
  expect_identical(tbl$id, c("C", "P", "U"))
  expect_equal(tbl$indivMeanKin, c(0.25, 0.1875, 0.125))
  expect_equal(tbl$markerMeanKin, c(0.4 / 3, 0.7 / 3, 0.2 / 3))
})

test_that("the Heterozygosity picture's data gives animals X, Y and Z their observed and expected values", {
  fx <- markerPictureFixtures()
  tbl <- runMarkerModule(fx, fx$heterozygosityGenotype)$heterozygosity
  tbl <- tbl[order(tbl$id), ]
  expect_identical(tbl$id, c("X", "Y", "Z"))
  expect_equal(tbl$ho, c(0.75, 1 / 3, 0.25))
  expect_equal(tbl$he, rep(115 / 288, 3L))
})

test_that("the Parentage Exclusion picture's data flags C's recorded sire and not its recorded dam", {
  fx <- markerPictureFixtures()
  ped <- qcdPedigree(fx$exclusionPedigree)
  tbl <- runMarkerModule(fx, fx$trioGenotype, pedigree = ped)$exclusion
  expect_identical(nrow(tbl), 2L)
  dam <- tbl[tbl$role == "dam", ]
  sire <- tbl[tbl$role == "sire", ]
  expect_identical(c(dam$id, dam$parentId), c("C", "P"))
  expect_identical(dam$exclusionCount, 0L)
  expect_false(dam$flagged)
  expect_identical(c(sire$id, sire$parentId), c("C", "U"))
  expect_identical(sire$exclusionCount, 3L)
  expect_true(sire$flagged)
})

test_that("the Cross-Center picture's two files give the per-locus and pooled Fst its caption describes", {
  fx <- markerPictureFixtures()
  tbl <- runMarkerModule(fx, fx$centerAGenotype,
                         genotypeB = fx$centerBGenotype)$crossCenter
  expect_identical(tbl$locus, c("L1", "L2", "Pooled"))
  expect_equal(tbl$fst, c(58 / 1001, 139 / 308, 614 / 2233))
})

test_that("the Candidate Parent Assignment picture's data gives one row: C's recorded sire Q, excluded at all 10 loci used", {
  fx <- markerPictureFixtures()
  ped <- qcdPedigree(fx$candidatePedigree)
  tbl <- runMarkerModule(fx, fx$candidateGenotype, pedigree = ped)$candidate
  expect_identical(nrow(tbl), 1L)
  expect_identical(tbl$id, "C")
  expect_identical(tbl$role, "sire")
  expect_identical(tbl$candidateId, "Q")
  expect_identical(tbl$LOD, -Inf)
  expect_identical(tbl$nLociUsed, 10L)
  expect_true(tbl$excluded)
  expect_false(tbl$lowPower)
})

test_that("the candidate pedigree keeps its fromCenter column: without it the table is empty", {
  fx <- markerPictureFixtures()
  expect_true("fromCenter" %in% names(fx$candidatePedigree))
  expect_true(all(fx$candidatePedigree$fromCenter))
  without <- qcdPedigree(fx$candidatePedigree[, setdiff(
    names(fx$candidatePedigree), "fromCenter")])
  tbl <- runMarkerModule(fx, fx$candidateGenotype, pedigree = without)$candidate
  expect_identical(nrow(tbl), 0L)
})

## ---- the guide's wording ---------------------------------------------------

## issue #155 (closed 2026-08-10) made the Candidate tab list candidates for an
## animal whose recorded parent is present but wrong; the note below was
## written the day before and still said it would show none.
test_that("the guide no longer says a wrong recorded parent shows no candidates", {
  text <- gsub("\\s+", " ", paste(readGuide(), collapse = " "))
  expect_false(grepl("will show no candidates", text, fixed = TRUE))
})

test_that("the Heterozygosity caption names the animals its picture shows, X, Y and Z", {
  lines <- readGuide()
  line <- grep("marker_genetics_heterozygosity\\.png", lines, value = TRUE)
  expect_length(line, 1L)
  ## the visible caption is the text inside ![...]; the alt text after it is
  ## not the caption
  caption <- sub("^!\\[(.*)\\]\\(shiny_app_use/.*$", "\\1", line)
  expect_false(identical(caption, line))
  expect_false(grepl("same example trio", caption, fixed = TRUE))
  expect_match(caption, "X, Y,? (and )?Z")
})

test_that("the guide's abstract no longer dates its claims to before the picture retakes", {
  text <- gsub("\\s+", " ", paste(readGuide(), collapse = " "))
  expect_false(grepl("current as of 2026-09-30", text, fixed = TRUE))
})
