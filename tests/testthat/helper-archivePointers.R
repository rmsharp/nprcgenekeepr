## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support (S1023, BACKLOG "The archive pointers name
## `docs/archive/`, but the shards sit in `methodology/archive/`"): what
## test_archivePointersResolve.R uses to read the pointers that
## `methodology_trim.py` writes at the top of a ledger and to name the ones
## that do not open a file.
##
## A trim writes two lines for each shard it makes:
##   **Archived N record(s), D1 -> D2** into [`TEXT`](TARGET) -- same format
##   Losslessness is proved by [`TEXT`](TARGET), which re-derives ...
## TEXT is the file's path from the repository root and TARGET is the same
## file from the ledger's own directory. Only a line that BEGINS with those
## words is a pointer, so a record that quotes the sentence is not one.

archivePointerPattern <- c(
  shard = paste0("^\\*\\*Archived [0-9]+ record\\(s\\), [^*]*\\*\\* into ",
                 "\\[`([^`]+)`\\]\\(([^)]+)\\)"),
  proof = paste0("^Losslessness is proved by ",
                 "\\[`([^`]+)`\\]\\(([^)]+)\\)")
)

## One row per pointer line of `lines` (the file as readLines() gives it), in
## file order: kind ("shard" or "proof"), line number, link text, link target.
archivePointerRows <- function(lines) {
  oneKind <- function(kind) {
    hit <- regmatches(lines, regexec(archivePointerPattern[[kind]], lines))
    at <- which(lengths(hit) == 3L)
    data.frame(kind = rep(kind, length(at)), line = at,
               text = vapply(hit[at], `[`, "", 2L),
               target = vapply(hit[at], `[`, "", 3L),
               stringsAsFactors = FALSE)
  }
  rows <- do.call(rbind, lapply(names(archivePointerPattern), oneKind))
  rows <- rows[order(rows$line), , drop = FALSE]
  rownames(rows) <- NULL
  rows
}

## The same rows for the ledger file `ledger`.
archivePointerRowsOf <- function(ledger) {
  archivePointerRows(readLines(ledger, warn = FALSE, encoding = "UTF-8"))
}

## What is wrong with the pointers of the ledger file `ledger`, one string per
## problem and character(0) when nothing is: a target that opens no file, link
## text that is not the file's path from `root` (the repository root), a shard
## link not followed by its own `.verify.sh` link, a proof link with no shard
## link before it.
archivePointerProblems <- function(ledger, root) {
  rows <- archivePointerRowsOf(ledger)
  root <- normalizePath(root)
  problems <- character(0)
  for (i in seq_len(nrow(rows))) {
    where <- paste0("line ", rows$line[i], ": ")
    file <- file.path(dirname(ledger), rows$target[i])
    if (!file.exists(file)) {
      problems <- c(problems,
                    paste0(where, rows$target[i], " does not open a file"))
      next
    }
    repoPath <- substring(normalizePath(file), nchar(root) + 2L)
    if (rows$text[i] != repoPath) {
      problems <- c(problems,
                    paste0(where, "the link text ", rows$text[i],
                           " is not the file's path ", repoPath))
    }
  }
  for (i in which(rows$kind == "shard")) {
    proof <- paste0(rows$target[i], ".verify.sh")
    if (i == nrow(rows) || rows$kind[i + 1L] != "proof" ||
          rows$target[i + 1L] != proof) {
      problems <- c(problems,
                    paste0("line ", rows$line[i],
                           ": the next link is not the proof ", proof))
    }
  }
  for (i in which(rows$kind == "proof")) {
    if (i == 1L || rows$kind[i - 1L] != "shard") {
      problems <- c(problems,
                    paste0("line ", rows$line[i],
                           ": a proof link with no shard link before it"))
    }
  }
  problems
}
