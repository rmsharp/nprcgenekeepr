## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:139 (S974; the owner chose both places at the PRE-RED scope
## question, and approved the sentence below by taking the recommended option).
## S971 made the Input tab read the genotype columns of a one-file pedigree
## and S972 finished its Input page, manual and guide. Two places still said
## nothing about genotypes, measured S974 before any change:
##
##   Genetic Value article and manual  0 lines with the word "genotype" in
##       either (17 and 8 lines on genome uniqueness and alleles), though the
##       Input tab's genotypes reach the gene drop (R/reportGV.R:202, 251):
##       with the shipped one-file example, 18 of its 31 genotyped animals
##       got a different genome uniqueness than without the genotypes
##       (set.seed(1), guIter 200, byID TRUE, every animal in the population;
##       none of the other 344 changed; one run, not a general claim).
##   vignettes/a2interactive.Rmd       names addGenotype() once, in passing
##       (line 1365), and never shows a script giving a pedigree its genotype
##       codes, so a script writer has no path from label columns to reportGV().
##
## The sentence for the article and the manual (once each), as the owner saw it:
##   "If the pedigree has genotypes (on the Input tab, "Pedigree(s) and
##   genotypes in one file" or "Pedigree(s) and genotypes in separate files"),
##   the gene drop uses each genotyped animal's own alleles in place of
##   simulated ones, so genome uniqueness can change for those animals. On the
##   shipped one-file example, 18 of its 31 genotyped animals scored
##   differently with the genotypes than without (one run, same random seed,
##   200 drops)."
## and a new subsection of a2interactive.Rmd, "Using known genotypes", after
## the Genetic Value section and before "Detailed look at the Genetic Value
## Report object", whose chunk is labelled `genotypes-from-label-columns`.
##
## The chunk's contract: it runs on its own (it reads the shipped file itself)
## and defines
##   genotypePed   the example pedigree with the integer columns `first` and
##                 `second` that addGenotype() makes from its label columns
##   genotypeGV    reportGV() run on genotypePed
##
## The blocks that read the three tutorial files read ../../vignettes/...,
## which .Rbuildignore excludes, so they skip in a built package and run from
## the source tree. The two that run the example (the numbers the article
## quotes, and the chunk) are skipped on CRAN, as they take seconds.

pkgRoot <- testthat::test_path("..", "..")
articlePath <- file.path("vignettes", "articles", "genetic-value-analysis.qmd")
manualPath <- file.path("vignettes", "manual_components",
                        "_genetic_value_analysis.Rmd")
scriptPath <- file.path("vignettes", "a2interactive.Rmd")
exampleFile <- "obfuscated_rhesus_mhc_ped_with_genotypes.csv"
chunkLabel <- "genotypes-from-label-columns"

## One tracked file as lines, or a skip where it is not present.
sourceLines <- function(path) {
  full <- file.path(pkgRoot, path)
  skip_if_not(file.exists(full), paste(basename(full), "not present"))
  readLines(full, warn = FALSE)
}

## The lines as plain text: backticks and asterisks dropped, underscores kept
## (first_name needs its own), line breaks collapsed.
plainText <- function(lines) {
  text <- gsub("[`*]", "", paste(lines, collapse = " "))
  gsub("\\s+", " ", text)
}

expectNames <- function(text, phrases) {
  for (phrase in phrases) {
    expect_true(grepl(phrase, text, fixed = TRUE), info = phrase)
  }
}

## The R code of the chunk whose header is "```{r <label>" in an Rmd file;
## character(0) when no chunk carries the label.
rmdChunkCode <- function(lines, label) {
  fence <- "```"
  start <- grep(paste0("^", fence, "\\{r ", label, "[,}]"), lines)
  if (length(start) != 1L) return(character(0))
  closing <- which(lines == fence & seq_along(lines) > start)
  if (length(closing) == 0L) return(character(0))
  lines[seq_len(closing[1L] - start - 1L) + start]
}

examplePath <- function() {
  system.file("extdata", "examples", exampleFile, package = "nprcgenekeepr")
}

## What the Genetic Value tab does with the example's genotypes: the same
## pedigree through reportGV() with and without them, the same seed, 200
## drops. Returns how many animals have genotypes and how many of those got a
## different genome uniqueness.
exampleGenotypeEffect <- function() {
  ped <- suppressWarnings(suppressMessages(
    qcStudbook(getPedigree(examplePath()), reportErrors = FALSE,
               reportChanges = FALSE)))
  withGenotypes <- readOneFileGenotypes(ped)$ped
  without <- ped[, setdiff(names(ped), c("first", "second", "first_name",
                                         "second_name")), drop = FALSE]
  run <- function(p) {
    p <- setPopulation(p, ids = p$id)
    set.seed(1)
    suppressWarnings(suppressMessages(
      reportGV(p, guIter = 200L, guThresh = 1L, pop = NULL, byID = TRUE,
               updateProgress = NULL)))$report
  }
  both <- merge(run(withGenotypes)[, c("id", "gu")], run(without)[, c("id", "gu")],
                by = "id", suffixes = c(".with", ".without"))
  genotyped <- withGenotypes$id[!is.na(withGenotypes$first)]
  changed <- abs(both$gu.with - both$gu.without) > 1e-9
  list(nGenotyped = length(genotyped),
       nChanged = sum(changed & both$id %in% genotyped))
}

## The chunk run once, in a fresh environment, for the blocks that read it.
## NULL when the file has no such chunk.
chunkEnv <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      code <- rmdChunkCode(sourceLines(scriptPath), chunkLabel)
      if (length(code) == 0L) return(NULL)
      env <- new.env(parent = globalenv())
      suppressWarnings(suppressMessages(eval(parse(text = code), envir = env)))
      cache <<- env
    }
    cache
  }
})

## The Input tab's own result for the same file: the real module, in "one
## file" mode, as test_modInputOneFileGenotypes.R drives it.
inputTabStudbook <- function() {
  out <- NULL
  shiny::testServer(modInputServer, args = list(), {
    session$setInputs(fileContent = "commonPedGenoFile",
                      fileType = "fileTypeExcel", separator = ",",
                      minSireAge = "0.1", minDamAge = "0.1")
    session$setInputs(pedigreeFileTwo = list(
      name = basename(examplePath()), datapath = examplePath()))
    session$setInputs(getData = 1)
    session$flushReact()
    out <<- session$getReturned()$cleanedStudbook()
  })
  out
}

test_that("the Genetic Value article says the Input tab's genotypes replace simulated alleles in the gene drop", {
  article <- plainText(sourceLines(articlePath))
  expectNames(article, c("Pedigree(s) and genotypes in one file",
                         "Pedigree(s) and genotypes in separate files",
                         "own alleles in place of simulated ones",
                         "genome uniqueness can change"))
})

test_that("the Genetic Value manual says the same", {
  manual <- plainText(sourceLines(manualPath))
  expectNames(manual, c("Pedigree(s) and genotypes in one file",
                        "Pedigree(s) and genotypes in separate files",
                        "own alleles in place of simulated ones",
                        "genome uniqueness can change"))
})

test_that("the article's example numbers are what the same run gives", {
  skip_on_cran()
  article <- plainText(sourceLines(articlePath))
  effect <- exampleGenotypeEffect()
  expect_gt(effect$nChanged, 0L)
  expectNames(article, c(
    sprintf("%d of its %d genotyped animals", effect$nChanged,
            effect$nGenotyped),
    "one run, same random seed, 200 drops"))
})

test_that("a2interactive.Rmd has a 'Using known genotypes' subsection inside the Genetic Value section", {
  lines <- sourceLines(scriptPath)
  heading <- grep("^### Using known genotypes\\s*$", lines)
  expect_length(heading, 1L)
  genetic <- grep("^## Genetic Value Analysis\\s*$", lines)
  detail <- grep("^### Detailed look at the Genetic Value Report object",
                 lines)
  expect_true(length(heading) == 1L && heading > genetic && heading < detail)
  section <- if (length(heading) == 1L && length(detail) == 1L) {
    plainText(lines[seq(heading, detail - 1L)])
  } else {
    ""
  }
  expectNames(section, c("addGenotype", "first_name", "second_name",
                         "reportGV", "Pedigree(s) and genotypes in one file"))
})

test_that("the subsection's chunk runs on its own and gives reportGV() genotypes", {
  skip_on_cran()
  env <- chunkEnv()
  expect_false(is.null(env), info = paste("no chunk labelled", chunkLabel))
  if (!is.null(env)) {
    pedWithCodes <- env$genotypePed
    expect_true(all(c("first", "second") %in% names(pedWithCodes)))
    expect_true(is.integer(pedWithCodes$first))
    expect_true(is.integer(pedWithCodes$second))
    expect_false(is.null(getGVGenotype(pedWithCodes)))
    expect_true("gu" %in% names(env$genotypeGV$report))
  }
})

test_that("the script's codes are the codes the Input tab gives the same file", {
  skip_on_cran()
  inputTab <- inputTabStudbook()
  expect_gt(sum(!is.na(inputTab$first)), 0L)
  env <- chunkEnv()
  expect_false(is.null(env), info = paste("no chunk labelled", chunkLabel))
  if (!is.null(env)) {
    script <- env$genotypePed
    columns <- c("id", "first", "second")
    script <- script[order(script$id), columns]
    inputTab <- inputTab[order(inputTab$id), columns]
    rownames(script) <- rownames(inputTab) <- NULL
    expect_equal(script, inputTab)
  }
})
