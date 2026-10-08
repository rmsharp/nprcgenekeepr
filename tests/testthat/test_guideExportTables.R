## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md docs-audit item, slice 2 Phase 4a (S943; the owner ruled D4:
## build the tables in the guide). The colony manager guide showed three
## exported CSV files (kinship matrix, first-order relationships, female
## founders) as screenshots of a spreadsheet. Measured S943 against what the
## real app's export buttons write: the first-order picture matched 0 of its
## 22 rows, the founders picture lacked two columns the app writes now, and the
## kinship picture listed the animals in another order. The guide now builds
## each table when it renders, in one chunk labelled `summary-export-tables`,
## from the same exported functions the export buttons use. This file is the
## gate that keeps those tables honest: what the guide shows must equal the same
## rows or cells of the file the real export button writes
## (modSummaryStatsServer run in shiny::testServer on the pedigree the chunk
## built), so a later change to an export cannot leave the guide stale quietly.
##
## The chunk's contract: it defines
##   exportPed            the pedigree the Summary Statistics tab receives
##   shownKinship         numeric matrix, dimnames = animal ids: the cells of
##                        the kinship file for a few animals, one of them a
##                        parent of the others (so a non-zero value shows)
##   shownFirstOrder      data.frame of character columns: the first rows of
##                        the first-order file
##   shownFemaleFounders  data.frame of character columns: the first rows of
##                        the female-founders file
##
## The tests that read the real guide read ../../vignettes/articles/..., which
## .Rbuildignore excludes: a built package holds no copy, so they skip in a
## built package and under `devtools::check()`. They run from the source tree,
## which is where the close-out suite runs. The helper tests at the end run on
## a six-animal pedigree and a made-up guide text, so they pin the helpers, not
## the guide (they pass before the guide changes, by design).

pkg_root <- testthat::test_path("..", "..")
guide_path <- file.path(pkg_root, "vignettes", "articles",
                        "colony-manager-guide.qmd")
pictures_dir <- file.path(pkg_root, "vignettes", "articles", "shiny_app_use")
oldPictures <- c("ss_kinship_matrix.png", "ss_first_order_relationships.png",
                 "ss_female_founders.png")
chunkLabel <- "summary-export-tables"
contractObjects <- c("exportPed", "shownKinship", "shownFirstOrder",
                     "shownFemaleFounders")

## The R code of the chunk whose `#| label:` line is `label`, without its `#|`
## option lines. Stops, naming the label, when no chunk carries it.
guideChunkCode <- function(lines, label) {
  fence <- "```"
  for (start in grep(paste0("^", fence, "\\{r"), lines)) {
    closing <- which(lines == fence & seq_along(lines) > start)
    if (length(closing) == 0L) next
    body <- lines[seq_len(closing[1L] - start - 1L) + start]
    if (any(body == paste0("#| label: ", label))) {
      return(body[!startsWith(body, "#|")])
    }
  }
  stop("no R chunk labelled '", label, "' in the guide", call. = FALSE)
}

## Run that chunk in a fresh environment and return the environment.
evalGuideChunk <- function(lines, label) {
  env <- new.env(parent = globalenv())
  eval(parse(text = guideChunkCode(lines, label)), envir = env)
  env
}

## What the three export buttons write for `ped`, as lines of text.
exportButtonLines <- function(ped) {
  result <- new.env()
  shiny::testServer(
    modSummaryStatsServer,
    args = list(
      geneticValues = shiny::reactive(NULL),
      pedigree = shiny::reactive(ped),
      kinshipMatrix = NULL
    ),
    {
      assign("lines", list(
        kinship = readLines(output$downloadKinship),
        firstOrder = readLines(output$downloadFirstOrder),
        femaleFounders = readLines(output$downloadFemaleFounders)
      ), envir = result)
    }
  )
  result$lines
}

## The guide's chunk run once, and the button files for the pedigree it built.
guideRun <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      lines <- readLines(guide_path, encoding = "UTF-8", warn = FALSE)
      env <- evalGuideChunk(lines, chunkLabel)
      cache <<- list(env = env, buttons = exportButtonLines(env$exportPed))
    }
    cache
  }
})

## The first `n` rows of a button's file, every column read as text.
fileHead <- function(lines, n) {
  utils::read.csv(text = lines[seq_len(n + 1L)], colClasses = "character",
                  check.names = FALSE)
}

## A table as a plain character matrix with column names only.
cells <- function(x) {
  m <- as.matrix(x)
  dimnames(m) <- list(NULL, colnames(x))
  m
}

## The animal ids down the first column of the kinship file.
kinshipFileIds <- function(lines) {
  sub("^\"([^\"]*)\".*", "\\1", lines[-1L])
}

## The kinship file's cells for the animals `rowIds` (rows) and `colIds`
## (columns), read from the file's own text.
kinshipFileCells <- function(lines, rowIds, colIds) {
  header <- scan(text = lines[1L], what = "", sep = ",", quiet = TRUE)
  ids <- kinshipFileIds(lines)
  out <- matrix(NA_real_, length(rowIds), length(colIds),
                dimnames = list(rowIds, colIds))
  for (id in rowIds) {
    values <- scan(text = lines[-1L][match(id, ids)], what = "", sep = ",",
                   quiet = TRUE)
    names(values) <- header
    out[id, ] <- as.numeric(values[colIds])
  }
  out
}

skipWithoutGuide <- function() {
  skip_if_not_installed("shiny")
  skip_if_not(file.exists(guide_path), "the guide is not in this build")
}

## ---- the guide's chunk ------------------------------------------------------

test_that("the guide has a chunk that builds the three shown tables", {
  skipWithoutGuide()
  lines <- readLines(guide_path, encoding = "UTF-8", warn = FALSE)
  expect_error(code <- guideChunkCode(lines, chunkLabel), NA)
  env <- guideRun()$env
  expect_true(all(contractObjects %in% ls(env)))
  expect_true(is.matrix(env$shownKinship) && is.numeric(env$shownKinship))
  for (shown in list(env$shownFirstOrder, env$shownFemaleFounders)) {
    expect_true(is.data.frame(shown))
    expect_true(all(vapply(shown, is.character, logical(1L))))
    expect_gte(nrow(shown), 3L)
  }
})

test_that("the shown kinship cells include a non-zero value between two animals", {
  skipWithoutGuide()
  shown <- guideRun()$env$shownKinship
  expect_gte(nrow(shown), 3L)
  expect_true(any(shown[upper.tri(shown)] > 0))
})

## ---- shown rows equal the rows the real export buttons write ---------------

test_that("the kinship cells shown are the cells Export Kinship Matrix writes", {
  skipWithoutGuide()
  run <- guideRun()
  shown <- run$env$shownKinship
  lines <- run$buttons$kinship
  expect_true(all(c(rownames(shown), colnames(shown)) %in%
                    kinshipFileIds(lines)))
  expect_equal(shown,
               kinshipFileCells(lines, rownames(shown), colnames(shown)))
})

test_that("the first-order rows shown are the first rows Export First-Order writes", {
  skipWithoutGuide()
  run <- guideRun()
  shown <- run$env$shownFirstOrder
  expect_identical(names(shown),
                   c("id", "parents", "offspring", "siblings", "total"))
  expect_identical(cells(shown),
                   cells(fileHead(run$buttons$firstOrder, nrow(shown))))
})

test_that("the founder rows shown are the first rows Export Female Founders writes", {
  skipWithoutGuide()
  run <- guideRun()
  shown <- run$env$shownFemaleFounders
  expect_true(all(c("id", "sire", "dam", "sex", "recordStatus", "fromCenter",
                    "placeholder") %in% names(shown)))
  expect_identical(cells(shown),
                   cells(fileHead(run$buttons$femaleFounders, nrow(shown))))
})

## ---- the three pictures are gone --------------------------------------------

test_that("the guide no longer uses the three spreadsheet pictures, and the files are gone", {
  skip_if_not(file.exists(guide_path), "the guide is not in this build")
  lines <- readLines(guide_path, encoding = "UTF-8", warn = FALSE)
  for (picture in oldPictures) {
    expect_false(any(grepl(picture, lines, fixed = TRUE)), info = picture)
    expect_false(file.exists(file.path(pictures_dir, picture)),
                 info = picture)
  }
})

## ---- the helpers, on a six-animal pedigree and a made-up guide text --------

controlPed <- function() {
  data.frame(
    id   = c("F1", "F2", "F3", "O1", "O2", "O3"),
    sire = c(NA, NA, NA, "F1", "F1", "F1"),
    dam  = c(NA, NA, NA, "F2", "F3", "F2"),
    sex  = c("M", "F", "F", "M", "F", "M"),
    stringsAsFactors = FALSE
  )
}

test_that("the helpers read the button files and tell a changed table from the file", {
  skip_if_not_installed("shiny")
  ped <- controlPed()
  buttons <- exportButtonLines(ped)

  ## first-order file: header plus one row per animal, no row-number column
  expect_identical(names(fileHead(buttons$firstOrder, 2L)),
                   c("id", "parents", "offspring", "siblings", "total"))
  own <- fileHead(buttons$firstOrder, 3L)
  expect_identical(cells(own), cells(fileHead(buttons$firstOrder, 3L)))
  changed <- own
  changed$total[1L] <- "99"
  expect_false(identical(cells(changed),
                         cells(fileHead(buttons$firstOrder, 3L))))
  fewerColumns <- own[, -ncol(own)]
  expect_false(identical(cells(fewerColumns),
                         cells(fileHead(buttons$firstOrder, 3L))))

  ## kinship file read from its own text equals kinship() on the pedigree
  ids <- c("F1", "O1", "O2")
  gen <- findGeneration(ped$id, ped$sire, ped$dam)
  expected <- kinship(ped$id, ped$sire, ped$dam, gen)[ids, ids]
  fromFile <- kinshipFileCells(buttons$kinship, ids, ids)
  expect_equal(fromFile, expected)
  expect_equal(fromFile["F1", "O1"], 0.25)
  wrong <- fromFile
  wrong["F1", "O1"] <- 0.125
  expect_false(isTRUE(all.equal(wrong, expected)))

  ## founders file: the two female founders only
  expect_setequal(fileHead(buttons$femaleFounders, 2L)$id, c("F2", "F3"))
})

test_that("guideChunkCode returns the labelled chunk's code without its option lines", {
  fence <- "```"
  qmd <- c("# Title",
           paste0(fence, "{r}"), "#| label: other", "x <- 1", fence,
           "Prose that mentions summary-export-tables.",
           paste0(fence, "{r}"), paste0("#| label: ", chunkLabel),
           "#| echo: false", "a <- 1", "b <- 2", fence)
  expect_identical(guideChunkCode(qmd, chunkLabel), c("a <- 1", "b <- 2"))
  expect_identical(guideChunkCode(qmd, "other"), "x <- 1")
})

test_that("guideChunkCode stops, naming the label, when no chunk carries it", {
  fence <- "```"
  qmd <- c(paste0(fence, "{r}"), "#| label: other", "x <- 1", fence,
           "The label summary-export-tables appears only in prose here.")
  expect_error(guideChunkCode(qmd, chunkLabel), chunkLabel, fixed = TRUE)
  ## an unclosed chunk is not returned
  unclosed <- c(paste0(fence, "{r}"), paste0("#| label: ", chunkLabel),
                "a <- 1")
  expect_error(guideChunkCode(unclosed, chunkLabel), chunkLabel, fixed = TRUE)
})
