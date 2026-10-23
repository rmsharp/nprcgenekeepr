## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:33 thread 1 (S1042; the owner picked it at the Phase 0 picker and
## chose the scope at the PRE-RED question: the eight snapshot functions in one
## new section of vignettes/a2interactive.Rmd, not the two named ones alone and
## not the whole inventory). The inventory (S1042, exports at the S541 pass
## against today's NAMESPACE, each name searched in the script): 14 new
## script-callable functions the script never names, 8 of them the snapshot
## family; the other 6 (the MHC haplotype functions, reportAncestryViolations(),
## shrinkPedigree()) and two parameters (kinship(chrtype),
## makePedigreeMatingLayout(kinshipMatrix)) are left to a BACKLOG item.
##
## The section, "Colony Snapshots Over Time", stands between "Genetic Value
## Analysis" and "Breeding Group Formation" and has five chunks. Each is
## labelled and the five run in this order on nprcgenekeepr::qcPed (they read no
## object an earlier section made), at 50 gene-drop iterations. Measured S1042
## on qcPed: the five calls together take under a second; at 10 iterations the
## rebuild gave two "Founder genome equivalents undefined" warnings, at 50 and
## 100 none. The chunks define:
##   snapshot-record    snapshotPed, snapshotGV, firstSnapshot, snapshotHistory
##                      (one "wholePedigree" row, on a fixed date)
##   snapshot-backfill  backfillPreview, earlierSnapshots, and snapshotHistory
##                      again, with the rebuilt rows added (existingHistory)
##   snapshot-save-read historyFile, readBack, checkedHistory
##   snapshot-compare   mixedRuleMessage, deltas
##   snapshot-plot      trendPlot
##
## Two measured facts the contract rests on (S1042): the app saves a history
## with write.csv(history, file, row.names = FALSE) (R/modSnapshotTrends.R:307)
## and readSnapshotHistory() gives snapshotDate back as text where the built
## history holds Dates, so the round trip is compared as text; and a history
## holding two membership rules stops calcSnapshotDeltas() with a message that
## names membershipRule, which the section shows instead of failing.
##
## S1040's lesson, a drafted "2 dates" was false because "2 in all" counted
## notes: the section's prose states no number as a literal. Any count in it is
## inline R, computed from the objects above, so the text cannot drift from the
## output.

## sourceLines(), plainText(), chunkCode() and expectNames() are in
## helper-pageText.R.
scriptPath <- file.path("vignettes", "a2interactive.Rmd")
sectionTitle <- "## Colony Snapshots Over Time"
chunkLabels <- c("snapshot-record", "snapshot-backfill", "snapshot-save-read",
                 "snapshot-compare", "snapshot-plot")
snapshotFunctions <- c("createColonySnapshot", "appendColonySnapshot",
                       "backfillColonySnapshots", "previewBackfillSupport",
                       "checkSnapshotHistory", "readSnapshotHistory",
                       "calcSnapshotDeltas", "plotSnapshotTrends")

## The line numbers of the "## " headings that are headings: a line inside a
## code chunk that starts with "## " is an R comment.
sectionHeadingLines <- function(lines) {
  insideChunk <- cumsum(grepl("^```", lines)) %% 2L == 1L
  which(grepl("^## ", lines) & !insideChunk)
}

## The lines of the section, from its heading to the line before the next
## section heading. character(0) when the script has no such section.
snapshotSection <- function() {
  lines <- sourceLines(scriptPath)
  headings <- sectionHeadingLines(lines)
  start <- headings[trimws(lines[headings]) == sectionTitle]
  if (length(start) != 1L) return(character(0L))
  after <- headings[headings > start]
  end <- if (length(after) > 0L) after[1L] - 1L else length(lines)
  lines[start:end]
}

## The section's text outside its code chunks and without its inline R code.
sectionProse <- function(section) {
  insideChunk <- cumsum(grepl("^```", section)) %% 2L == 1L
  prose <- section[!insideChunk & !grepl("^```", section)]
  gsub("`r [^`]*`", "", prose)
}

## A chunk's header line and its "#|" option lines.
chunkOptionText <- function(section, label) {
  start <- grep(paste0("^```\\{r ", label, "[,}]"), section)
  if (length(start) != 1L) return(character(0L))
  body <- section[-seq_len(start)]
  options <- body[cumsum(!startsWith(body, "#|")) == 0L]
  c(section[start], options)
}

## The five chunks run once, in order, in a fresh environment, with every
## warning kept; then the plot is drawn on a null device. NULL when the section
## is absent.
chunkRun <- local({
  cache <- NULL
  function() {
    if (is.null(cache)) {
      section <- snapshotSection()
      if (length(section) == 0L) return(NULL)
      env <- new.env(parent = globalenv())
      warned <- character(0L)
      keep <- function(expr) {
        withCallingHandlers(
          suppressMessages(expr),
          warning = function(w) {
            warned <<- c(warned, conditionMessage(w))
            invokeRestart("muffleWarning")
          }
        )
      }
      for (label in chunkLabels) {
        code <- chunkCode(section, label)
        if (!is.null(code)) keep(eval(parse(text = code), envir = env))
      }
      if (inherits(env$trendPlot, "ggplot")) {
        grDevices::pdf(NULL)
        on.exit(grDevices::dev.off(), add = TRUE)
        keep(print(env$trendPlot))
      }
      cache <<- list(env = env, warnings = warned)
    }
    cache
  }
})

test_that("a2interactive.Rmd has a 'Colony Snapshots Over Time' section between Genetic Value Analysis and Breeding Group Formation", {
  lines <- sourceLines(scriptPath)
  headings <- sectionHeadingLines(lines)
  titles <- trimws(lines[headings])
  at <- which(titles == sectionTitle)
  expect_length(at, 1L)
  expect_true(length(at) == 1L && at > 1L && at < length(titles))
  if (length(at) == 1L && at > 1L && at < length(titles)) {
    expect_identical(titles[at - 1L], "## Genetic Value Analysis")
    expect_identical(titles[at + 1L], "## Breeding Group Formation")
  }
})

test_that("the section names the eight snapshot functions and says what a rebuilt snapshot rests on", {
  section <- snapshotSection()
  expect_gt(length(section), 0L)
  ## The prose only: a name in a chunk's code does not count.
  text <- plainText(sectionProse(section))
  expectNames(text, snapshotFunctions)
  ## The limit, in the colony manager guide's approved words
  ## (vignettes/articles/colony-manager-guide.qmd, "Genetic-Health Trends").
  expectNames(text, c("a parent identified later counts as known earlier",
                      "today's genotypes are used for every date"))
})

test_that("the section holds the five labelled chunks, in order", {
  section <- snapshotSection()
  expect_gt(length(section), 0L)
  positions <- vapply(chunkLabels, function(label) {
    hit <- grep(paste0("^```\\{r ", label, "[,}]"), section)
    if (length(hit) == 1L) hit else NA_integer_
  }, integer(1L))
  expect_false(anyNA(positions), info = paste(
    "missing:", paste(chunkLabels[is.na(positions)], collapse = ", ")))
  expect_false(is.unsorted(positions))
})

test_that("the chunks hide no warning, read no clock and fix the seed where a gene drop runs", {
  section <- snapshotSection()
  expect_gt(length(section), 0L)
  for (label in chunkLabels) {
    expect_false(any(grepl("warning = FALSE", chunkOptionText(section, label),
                           fixed = TRUE)), info = label)
    code <- chunkCode(section, label)
    expect_false(is.null(code), info = paste("no chunk labelled", label))
    expect_false(any(grepl("suppressWarnings|Sys\\.Date|Sys\\.time", code)),
                 info = label)
  }
  for (label in c("snapshot-record", "snapshot-backfill")) {
    expect_true(any(grepl("set\\.seed\\(", chunkCode(section, label))),
                info = paste(label, "sets no seed"))
  }
})

test_that("the section's prose gives no number as a literal", {
  section <- snapshotSection()
  expect_gt(length(section), 0L)
  prose <- sectionProse(section)
  withDigits <- prose[grepl("[0-9]", prose)]
  expect_length(withDigits, 0L)
})

test_that("the plot chunk gives the figure alt text", {
  section <- snapshotSection()
  expect_gt(length(section), 0L)
  expect_true(any(grepl("fig.alt", chunkOptionText(section, "snapshot-plot"),
                        fixed = TRUE)))
})

test_that("the five chunks run in order on their own and give no warning, the plot drawn too", {
  skip_on_cran()
  run <- chunkRun()
  expect_false(is.null(run), info = "no 'Colony Snapshots Over Time' section")
  if (!is.null(run)) expect_length(run$warnings, 0L)
})

test_that("the first two chunks build a history of one recorded and three rebuilt snapshots", {
  skip_on_cran()
  run <- chunkRun()
  expect_false(is.null(run), info = "no 'Colony Snapshots Over Time' section")
  if (!is.null(run)) {
    env <- run$env
    expect_true(all(c("snapshotPed", "snapshotGV", "firstSnapshot",
                      "backfillPreview", "earlierSnapshots",
                      "snapshotHistory") %in% ls(env)))
    if (is.data.frame(env$snapshotHistory)) {
      expect_no_error(checkSnapshotHistory(env$snapshotHistory))
      expect_equal(as.list(table(env$snapshotHistory$membershipRule)),
                   list(reconstructedLiving = 3L, wholePedigree = 1L))
    }
    if (is.list(env$earlierSnapshots)) {
      expect_true(all(c("history", "support", "skipped") %in%
                        names(env$earlierSnapshots)))
      expect_equal(nrow(env$earlierSnapshots$skipped), 0L)
    }
    ## The preview shows the dates the build then rebuilds.
    if (is.data.frame(env$backfillPreview) &&
          is.data.frame(env$snapshotHistory)) {
      rebuilt <- env$snapshotHistory$snapshotDate[
        env$snapshotHistory$membershipRule == "reconstructedLiving"]
      expect_setequal(as.character(env$backfillPreview$snapshotDate),
                      as.character(rebuilt))
    }
  }
})

test_that("the history is saved, read back and checked", {
  skip_on_cran()
  run <- chunkRun()
  expect_false(is.null(run), info = "no 'Colony Snapshots Over Time' section")
  if (!is.null(run)) {
    env <- run$env
    expect_true(all(c("historyFile", "readBack", "checkedHistory") %in%
                      ls(env)))
    if (is.data.frame(env$readBack) && is.data.frame(env$snapshotHistory)) {
      expect_equal(nrow(env$readBack), nrow(env$snapshotHistory))
      ## readSnapshotHistory() gives the dates back as text.
      expect_identical(as.character(env$readBack$snapshotDate),
                       as.character(env$snapshotHistory$snapshotDate))
      expect_identical(as.character(env$readBack$membershipRule),
                       as.character(env$snapshotHistory$membershipRule))
    }
    if (is.data.frame(env$checkedHistory) &&
          is.data.frame(env$snapshotHistory)) {
      expect_equal(nrow(env$checkedHistory), nrow(env$snapshotHistory))
    }
  }
})

test_that("the comparison shows the mixed-rule message and a delta table, and the plot is a ggplot", {
  skip_on_cran()
  run <- chunkRun()
  expect_false(is.null(run), info = "no 'Colony Snapshots Over Time' section")
  if (!is.null(run)) {
    env <- run$env
    expect_true(all(c("mixedRuleMessage", "deltas", "trendPlot") %in% ls(env)))
    if (is.character(env$mixedRuleMessage)) {
      expect_length(env$mixedRuleMessage, 1L)
      expect_match(env$mixedRuleMessage, "membershipRule", fixed = TRUE)
    }
    if (is.data.frame(env$deltas)) {
      expect_true(all(c("metric", "from", "to", "delta") %in%
                        names(env$deltas)))
      expect_gt(nrow(env$deltas), 0L)
    }
    expect_s3_class(env$trendPlot, "ggplot")
  }
})
