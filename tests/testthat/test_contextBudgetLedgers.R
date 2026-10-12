## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md ("Optional: put HANDOFFS.md under the context-budget hook",
## found S951, picked S965): HANDOFFS.md crossed 262,144 B, the size the Read
## tool refuses to open whole, in S950's close-out commit and nothing said so
## until the next Phase 0 dashboard; CHANGELOG.md crossed the 196,608 B trim
## line the same way in S959. Both ledgers get a row in
## methodology/.context-budget.json: a warning from 196,608 B, and the
## pre-commit hook refuses a commit that makes the file bigger once it is past
## 262,144 B (the owner's two numbers, S965).
##
## The class is what these tests pin. Measured S965 in a scratch copy: a ledger
## declared "read-mandated", as SESSION_NOTES.md is, also gets a token check
## capped at the 25,000-token read cap, so HANDOFFS.md at 87,830 B (about 38,691
## tokens) read OVER and the hook refused a commit that added a 1,000 B
## receipt. The protocol never orders a session to read either ledger whole (it
## reads one block through git), so each is an "on-demand" file: bytes only.
##
## The live ledgers grow every session, so no test reads their sizes. Each
## builds a scratch git folder holding the REAL config and the REAL
## context_budget.py, with the two ledgers written at a chosen size (a multiple
## of 100 B), and asks the tool for its verdict. methodology/ is excluded from a
## built package (.Rbuildignore), so these tests skip there and run from the
## source tree, where the close-out suite runs.

## Absolute: the tool is run from inside a scratch folder, where `../..` means
## something else.
pkg_root <- normalizePath(testthat::test_path("..", ".."), mustWork = FALSE)
budget_tool <- file.path(pkg_root, "methodology", "context_budget.py")
budget_config <- file.path(pkg_root, "methodology", ".context-budget.json")
budget_anchor <- file.path(pkg_root, "methodology", "SESSION_RUNNER.md")
ledger_paths <- c("methodology/HANDOFFS.md", "methodology/CHANGELOG.md")

skip_unless_budget_tools <- function() {
  skip_if_not(all(file.exists(c(budget_tool, budget_config, budget_anchor))),
              "methodology/ is not in this build")
  skip_if_not(nzchar(unname(Sys.which("python3"))), "python3 is not installed")
  skip_if_not(nzchar(unname(Sys.which("git"))), "git is not installed")
}

## `bytes` of 100-byte lines (99 characters and a newline), written in binary
## so a size is the same on every platform.
ledgerText <- function(bytes) {
  stopifnot(bytes %% 100L == 0L)
  strrep(paste0(strrep("x", 99L), "\n"), bytes %/% 100L)
}

writeLedger <- function(path, bytes, append = FALSE) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  con <- file(path, if (append) "ab" else "wb")
  on.exit(close(con))
  writeBin(charToRaw(ledgerText(bytes)), con)
}

budgetGit <- function(root, ...) {
  system2("git", c("-C", shQuote(root), "-c", "user.name=budget-test",
                   "-c", "user.email=budget-test@example.org", ...),
          stdout = TRUE, stderr = TRUE)
}

## A committed scratch folder: the project's budget config, the layout anchor
## the tool looks for, and both ledgers at `bytes`.
budgetTree <- function(bytes, env = parent.frame()) {
  root <- withr::local_tempdir(.local_envir = env)
  dir.create(file.path(root, "methodology"))
  file.copy(budget_config, file.path(root, "methodology"))
  file.copy(budget_anchor, file.path(root, "methodology"))
  for (path in ledger_paths) writeLedger(file.path(root, path), bytes)
  budgetGit(root, "init", "-q")
  budgetGit(root, "add", "-A")
  budgetGit(root, "commit", "-q", "--no-verify", "-m", "base")
  root
}

## Stage `bytes` more (or, with `shrinkTo`, a smaller file) in both ledgers.
stageLedgers <- function(root, grow = 0L, shrinkTo = NULL) {
  for (path in ledger_paths) {
    if (is.null(shrinkTo)) {
      writeLedger(file.path(root, path), grow, append = TRUE)
    } else {
      writeLedger(file.path(root, path), shrinkTo)
    }
  }
  budgetGit(root, "add", "-A")
  invisible(root)
}

budgetStatusJson <- function(root) {
  withr::with_dir(root, suppressWarnings(
    system2("python3", c("-I", shQuote(budget_tool), "--status", "--json"),
            stdout = TRUE, stderr = FALSE)))
}

## list(status = exit code, text = everything the hook printed).
budgetPrecommit <- function(root) {
  out <- withr::with_dir(root, suppressWarnings(
    system2("python3", c("-I", shQuote(budget_tool), "--precommit"),
            stdout = TRUE, stderr = TRUE)))
  status <- attr(out, "status")
  list(status = if (is.null(status)) 0L else status,
       text = paste(out, collapse = "\n"))
}

## The serialized JSON of one file's row, from its "path" key to the next
## "path" key; NA when the tool has no row for the path. Matched as text, the
## way this suite matches JSON (see helper-shinytest2.R).
budgetRow <- function(json, path) {
  text <- paste(json, collapse = "\n")
  start <- regexpr(paste0('"path": "', path, '"'), text, fixed = TRUE)
  if (start < 0L) return(NA_character_)
  rest <- substring(text, start + attr(start, "match.length"))
  nextRow <- regexpr('"path": ', rest, fixed = TRUE)
  if (nextRow < 0L) rest else substr(rest, 1L, nextRow - 1L)
}

budgetRowStatus <- function(row) {
  regmatches(row, regexec('"status": "([a-z]+)"', row))[[1L]][2L]
}

test_that("each ledger has a row with a 196,608 B warn line and a 262,144 B ceiling", {
  skip_unless_budget_tools()
  json <- budgetStatusJson(budgetTree(100000L))
  for (path in ledger_paths) {
    row <- budgetRow(json, path)
    expect_false(is.na(row), info = paste(path, "has no row"))
    ## `warn_bytes` is the last key of an on-demand row, so no comma follows it.
    expect_match(row, '"max_bytes": 262144\\b', info = path)
    expect_match(row, '"warn_bytes": 196608\\b', info = path)
  }
})

test_that("a ledger at 100,000 B is ok and gets no token check", {
  skip_unless_budget_tools()
  json <- budgetStatusJson(budgetTree(100000L))
  for (path in ledger_paths) {
    row <- budgetRow(json, path)
    expect_false(is.na(row), info = paste(path, "has no row"))
    expect_equal(budgetRowStatus(row), "ok", info = path)
    expect_false(grepl('"tokens"', row, fixed = TRUE), info = path)
  }
})

test_that("a ledger past 196,608 B warns and a commit that grows it still passes", {
  skip_unless_budget_tools()
  root <- budgetTree(200000L)
  json <- budgetStatusJson(root)
  for (path in ledger_paths) {
    row <- budgetRow(json, path)
    expect_false(is.na(row), info = paste(path, "has no row"))
    expect_equal(budgetRowStatus(row), "warn", info = path)
  }
  verdict <- budgetPrecommit(stageLedgers(root, grow = 1000L))
  expect_equal(verdict$status, 0L, info = verdict$text)
})

test_that("a ledger past 262,144 B is over: growth is refused and shrinking passes", {
  skip_unless_budget_tools()
  root <- budgetTree(263000L)
  json <- budgetStatusJson(root)
  for (path in ledger_paths) {
    row <- budgetRow(json, path)
    expect_false(is.na(row), info = paste(path, "has no row"))
    expect_equal(budgetRowStatus(row), "over", info = path)
  }
  grown <- budgetPrecommit(stageLedgers(root, grow = 1000L))
  expect_equal(grown$status, 2L, info = grown$text)
  expect_match(grown$text, "REFUSED", fixed = TRUE)
  for (path in ledger_paths) {
    expect_match(grown$text, path, fixed = TRUE)
  }
  shrunk <- budgetPrecommit(stageLedgers(root, shrinkTo = 100000L))
  expect_equal(shrunk$status, 0L, info = shrunk$text)
})
