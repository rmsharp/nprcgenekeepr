## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:139 (decided S971). Once the one-file mode reads allele_1 /
## allele_2, text labels and first_name / second_name, and says what it read,
## the pages that describe the mode must say so and no page may keep saying
## that text labels are "not converted" and the genotypes "then not used". The
## owner asked at S971 for much more documentation and for the tutorials to
## grow with it. The places, from a grep of the source tree before this file
## was written:
##
##   inst/extdata/ui_guidance/input_format.html   the Input Format sub-tab
##       (the genotype bullet at lines 85-89 and the two table cells at
##       173 and 179 that say "Whole numbers only. For labeled alleles use a
##       separate genotype file.")
##   vignettes/manual_components/_input.Rmd       the user manual's Input part
##   vignettes/articles/colony-manager-guide.qmd  the File Content paragraph
##       (line 179), and a new paragraph and picture beside the QC Summary
##   vignettes/articles/colony-manager-guide-screenshots.R   the capture script
##   inst/extdata/examples/                       a shipped one-file example
##   NEWS.Rmd and NEWS.md                         the development-version entry
##
## The sentences are the owner's to approve, so these blocks pin facts (which
## columns a page names, which old sentence is gone, which two forms of the
## line it describes, that the picture is cited, shot after a pop-up wait and
## present), not prose. The two lines themselves are pinned word for word in
## test_readOneFileGenotypes.R. Underscores are kept in the text compared here
## (pageText() in helper-pageText.R drops them, and allele_1 needs its own).
## The tests that read these files read ../../ paths that .Rbuildignore
## excludes or the installed package does not hold, so they skip in a built
## package and run from the source tree.

pkgRoot <- testthat::test_path("..", "..")

## plainSource() and expectNames() are in helper-pageText.R.

test_that("the Input Format page no longer says text labels are not converted and the genotypes then not used", {
  page <- plainSource("inst", "extdata", "ui_guidance", "input_format.html",
                      html = TRUE)
  expect_false(grepl("not converted, and the genotypes are then not used",
                     page, fixed = TRUE))
  expect_false(grepl("For labeled alleles use a separate genotype file",
                     page, fixed = TRUE))
})

test_that("the Input Format page names the one-file genotype columns and describes both forms of the line", {
  page <- plainSource("inst", "extdata", "ui_guidance", "input_format.html",
                      html = TRUE)
  expectNames(page, c("allele_1", "allele_2", "Genotypes read from",
                      "No genotype columns were found"))
})

## S972 (BACKLOG.md:139, points 1 and 2; the sentences are the ones the owner
## approved at the PRE-RED gate). The two table cells called the column an
## "integer code of the first allele" while their last cell says whole numbers
## or text labels, and the pages that describe the line now name its third form.
test_that("the Input Format page's first and second rows no longer call the column an integer code", {
  page <- plainSource("inst", "extdata", "ui_guidance", "input_format.html",
                      html = TRUE)
  expect_false(grepl("integer code of the", page, fixed = TRUE))
  expectNames(page, c("First allele: the animal's first allele",
                      "Second allele: the animal's second allele"))
})

test_that("the Input Format page and the guide describe the line for allele columns that are found but are not a usable pair", {
  page <- plainSource("inst", "extdata", "ui_guidance", "input_format.html",
                      html = TRUE)
  guide <- plainSource("vignettes", "articles", "colony-manager-guide.qmd")
  expectNames(page, c("Genotype columns were found", "not a usable pair"))
  expectNames(guide, c("Genotype columns were found", "not a usable pair"))
})

test_that("the user manual's Input part names the one-file genotype columns and the line", {
  manual <- plainSource("vignettes", "manual_components", "_input.Rmd")
  expectNames(manual, c("allele_1", "allele_2", "Genotypes read from"))
})

test_that("the colony manager guide describes the one-file genotype columns and the line, and cites its picture with a description", {
  guide <- plainSource("vignettes", "articles", "colony-manager-guide.qmd")
  expectNames(guide, c("allele_1", "allele_2", "Genotypes read from",
                       "No genotype columns were found"))
  expect_match(guide,
               "shiny_app_use/one_file_genotypes_read\\.png\\)\\{fig-alt=\"[^\"]{40,}\"\\}")
})

test_that("the guide's picture of the QC Summary in one-file mode is a PNG, at least 600 pixels wide", {
  path <- file.path(pkgRoot, "vignettes", "articles", "shiny_app_use",
                    "one_file_genotypes_read.png")
  skip_if_not(dir.exists(dirname(path)), "the guide's pictures are not present")
  expect_true(file.exists(path))
  if (file.exists(path)) {
    bytes <- readBin(path, "raw", 24L)
    expect_identical(bytes[1:8],
                     as.raw(c(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a)))
    width <- sum(as.integer(bytes[17:20]) * c(16777216, 65536, 256, 1))
    expect_gte(width, 600)
  }
})

test_that("the colony script takes the one-file picture last, after choosing the mode, uploading the example, checking it and waiting out the pop-ups", {
  path <- file.path(pkgRoot, "vignettes", "articles",
                    "colony-manager-guide-screenshots.R")
  skip_if_not(file.exists(path), "the capture script is not present")
  lines <- readLines(path, warn = FALSE)
  code <- lines[!grepl("^\\s*#", lines)]
  shotAt <- grep("^shot\\(app, \"one_file_genotypes_read\\.png\"", code)
  expect_length(shotAt, 1L)
  ## the step loads a different pedigree, so no later picture may rely on the
  ## example pedigree the script loaded first
  expect_identical(shotAt, utils::tail(grep("^shot\\(", code), 1L))
  if (length(shotAt) == 1L) {
    before <- code[seq_len(shotAt - 1L)]
    before <- before[nzchar(trimws(before))]
    expect_match(before[[length(before)]],
                 "wait_for_popups_before\\(app, \"one_file_genotypes_read\\.png\"\\)")
  }
  script <- paste(code, collapse = "\n")
  expect_match(script,
               "dataInput-fileContent[`\"]?\\s*=\\s*\"commonPedGenoFile\"")
  expect_match(script, "dataInput-pedigreeFileTwo", fixed = TRUE)
  expect_match(script, "obfuscated_rhesus_mhc_ped_with_genotypes.csv",
               fixed = TRUE)
  ## the older Warnings-picture block needs exactly one app$click(
  ## "dataInput-getData") and one set_inputs to QC Summary, so this step
  ## clicks with click_element_safe(): any mention of the button counts
  expect_gte(sum(grepl("dataInput-getData", code, fixed = TRUE)), 2L)
})

test_that("the shipped one-file example is the rhesus MHC pedigree with its genotyped animals' labels", {
  exDir <- file.path("extdata", "examples")
  pedPath <- system.file(exDir, "obfuscated_rhesus_mhc_ped.csv",
                         package = "nprcgenekeepr")
  genoPath <- system.file(exDir, "obfuscated_rhesus_mhc_breeder_genotypes.csv",
                          package = "nprcgenekeepr")
  onePath <- system.file(exDir, "obfuscated_rhesus_mhc_ped_with_genotypes.csv",
                         package = "nprcgenekeepr")
  skip_if(pedPath == "" || genoPath == "")
  expect_true(nzchar(onePath))
  if (nzchar(onePath)) {
    ped <- utils::read.csv(pedPath, stringsAsFactors = FALSE)
    geno <- utils::read.csv(genoPath, stringsAsFactors = FALSE)
    one <- utils::read.csv(onePath, stringsAsFactors = FALSE)
    expect_identical(names(one), c(names(ped), "first_name", "second_name"))
    expect_identical(one$id, ped$id)
    expect_equal(nrow(one), nrow(ped))
    labelled <- !is.na(one$first_name) & !is.na(one$second_name)
    expect_equal(sum(labelled), nrow(geno))
    at <- match(one$id[labelled], geno$id)
    expect_identical(one$first_name[labelled], geno$first_name[at])
    expect_identical(one$second_name[labelled], geno$second_name[at])
  }
})

## The development-version section of a NEWS file, as one string.
newsDevSection <- function(file) {
  path <- file.path(pkgRoot, file)
  skip_if_not(file.exists(path), paste(file, "not present"))
  lines <- readLines(path, warn = FALSE)
  starts <- grep("^# nprcgenekeepr ", lines)
  paste(lines[starts[[1L]]:(starts[[2L]] - 1L)], collapse = " ")
}

test_that("the development-version NEWS entry says the one-file mode reads these columns, in NEWS.Rmd and in the knitted NEWS.md", {
  for (file in c("NEWS.Rmd", "NEWS.md")) {
    section <- gsub("\\s+", " ", newsDevSection(file))
    expect_match(section, "allele\\\\?_1", info = file)
    expect_match(section, "genotypes in one file", fixed = TRUE, info = file)
  }
})

## S972: the line has a third form, so "or that it found none" no longer says
## what the Input tab does.
test_that("the development-version NEWS entry says the line tells why the app read no genotypes, in NEWS.Rmd and in the knitted NEWS.md", {
  for (file in c("NEWS.Rmd", "NEWS.md")) {
    section <- gsub("\\s+", " ", newsDevSection(file))
    expect_match(section, "or why it read none", fixed = TRUE, info = file)
    expect_false(grepl("or that it found none", section, fixed = TRUE),
                 info = file)
  }
})
