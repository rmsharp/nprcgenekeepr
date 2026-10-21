## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md ("The archive pointers name `docs/archive/`, but the shards sit
## in `methodology/archive/`", found S1001; the owner chose, S1023, to fix the
## pointers of the live ledgers and keep a check). Measured S1023 by opening
## every pointer against its own file's directory in all 17 tracked files that
## hold one: 57 pointers (114 links) open nothing, though each names a file
## that exists under methodology/archive/ -- SESSION_NOTES.md 23, HANDOFFS.md
## 17, and 17 inside six frozen CHANGELOG shards (left as history by the
## owner). `methodology_trim.py` 1.8.0 already writes working links for a
## ledger directly in methodology/, so this file is the gate: it fails when a
## sync or a hand edit brings dead ones back into the three live ledgers.
##
## archivePointerRows() and archivePointerProblems()
## (tests/testthat/helper-archivePointers.R) read the pointers. The first
## blocks run them on small invented repositories, so a pass means the check
## can fail; the last three read ../../methodology/*.md, which .Rbuildignore
## excludes: a built package holds no copy, so they skip there and run from the
## source tree, where the close-out suite runs.

## The two lines `methodology_trim.py` writes for one shard, plus the first
## line of its closing sentence, for a ledger directly in methodology/.
pointerLines <- function(name,
                         text = paste0("methodology/archive/", name),
                         target = paste0("archive/", name),
                         proofTarget = paste0(target, ".verify.sh")) {
  c(paste0("**Archived 3 record(s), 2026-01-01 → 2026-01-02** into [`",
           text, "`](", target, ") — same format, same order, frozen."),
    paste0("Losslessness is proved by [`", text, ".verify.sh`](", proofTarget,
           "), which re-derives L1/L2/L3 from git; run it rather"),
    "than trusting this sentence.")
}

## A small repository: methodology/SESSION_NOTES.md holding `ledgerLines`, and
## an empty file for each name in `shards` under methodology/archive/. Returns
## the repository root; the directory goes when the calling test ends.
pointerRepo <- function(ledgerLines, shards = character(0),
                        env = parent.frame()) {
  root <- withr::local_tempdir(.local_envir = env)
  dir.create(file.path(root, "methodology", "archive"), recursive = TRUE)
  writeLines(ledgerLines, file.path(root, "methodology", "SESSION_NOTES.md"))
  file.create(file.path(root, "methodology", "archive", shards))
  root
}

shardFiles <- function(name) c(name, paste0(name, ".verify.sh"))

problemsOf <- function(root) {
  archivePointerProblems(file.path(root, "methodology", "SESSION_NOTES.md"),
                         root)
}

test_that("a pointer pair reads as a shard row then a proof row", {
  name <- "SESSION_NOTES-through-2026-01-02.md"
  rows <- archivePointerRows(pointerLines(name))
  expect_equal(rows$kind, c("shard", "proof"))
  expect_equal(rows$line, 1:2)
  expect_equal(rows$text, c(paste0("methodology/archive/", name),
                            paste0("methodology/archive/", name,
                                   ".verify.sh")))
  expect_equal(rows$target, c(paste0("archive/", name),
                              paste0("archive/", name, ".verify.sh")))
})

test_that("a line that only quotes the sentence is not a pointer", {
  lines <- c("A record: **Archived 3 record(s), x to y** into [`a`](b) here",
             "see Losslessness is proved by [`a`](b) above")
  expect_equal(nrow(archivePointerRows(lines)), 0L)
})

test_that("a ledger with no pointer has no rows and no problems", {
  root <- pointerRepo(c("# Session Notes", "", "## ACTIVE TASK"))
  expect_equal(nrow(archivePointerRows(c("# Session Notes", ""))), 0L)
  expect_equal(problemsOf(root), character(0))
})

test_that("a pointer to files that are there, named by their path, is clean", {
  name <- "SESSION_NOTES-through-2026-01-02.md"
  root <- pointerRepo(pointerLines(name), shardFiles(name))
  expect_equal(problemsOf(root), character(0))
})

test_that("a pointer to a file that is not there is a problem, per link", {
  name <- "SESSION_NOTES-through-2026-01-02.md"
  old <- paste0("docs/archive/", name)
  root <- pointerRepo(pointerLines(name, text = old, target = old),
                      shardFiles(name))
  problems <- problemsOf(root)
  expect_length(problems, 2L)
  expect_match(problems[1L], paste0("^line 1: ", old, " does not open"))
  expect_match(problems[2L], paste0("^line 2: ", old, ".verify.sh does not"))
})

test_that("link text that is not the file's path is a problem", {
  name <- "SESSION_NOTES-through-2026-01-02.md"
  root <- pointerRepo(pointerLines(name, text = paste0("archive/", name)),
                      shardFiles(name))
  problems <- problemsOf(root)
  expect_length(problems, 2L)
  expect_match(problems[1L], paste0("^line 1: the link text archive/", name,
                                    " is not the file's path methodology/"))
})

test_that("a shard link with no proof link after it is a problem", {
  name <- "SESSION_NOTES-through-2026-01-02.md"
  root <- pointerRepo(pointerLines(name)[1L], shardFiles(name))
  problems <- problemsOf(root)
  expect_length(problems, 1L)
  expect_match(problems, "^line 1: the next link is not the proof archive/")
})

test_that("a proof link that names another file is a problem", {
  name <- "SESSION_NOTES-through-2026-01-02.md"
  other <- "archive/Other.md.verify.sh"
  root <- pointerRepo(pointerLines(name, proofTarget = other),
                      c(shardFiles(name), "Other.md.verify.sh"))
  expect_true(any(grepl("the next link is not the proof", problemsOf(root))))
})

test_that("a proof link with no shard link before it is a problem", {
  name <- "SESSION_NOTES-through-2026-01-02.md"
  root <- pointerRepo(pointerLines(name)[2L], shardFiles(name))
  expect_true(any(grepl("a proof link with no shard link before it",
                        problemsOf(root))))
})

pkg_root <- testthat::test_path("..", "..")

## Every pointer of methodology/<name> opens its shard and its proof.
expectPointersOpen <- function(name) {
  ledger <- file.path(pkg_root, "methodology", name)
  skip_if_not(file.exists(ledger), "no methodology/ here (a built package)")
  expect_gt(nrow(archivePointerRowsOf(ledger)), 0L)
  problems <- archivePointerProblems(ledger, pkg_root)
  expect_equal(length(problems), 0L,
               info = paste(c(paste(length(problems), "problems, the first:"),
                              head(problems, 3L)), collapse = "\n"))
}

test_that("every archive pointer in SESSION_NOTES.md opens its files", {
  expectPointersOpen("SESSION_NOTES.md")
})

test_that("every archive pointer in HANDOFFS.md opens its files", {
  expectPointersOpen("HANDOFFS.md")
})

test_that("every archive pointer in CHANGELOG.md opens its files", {
  expectPointersOpen("CHANGELOG.md")
})
