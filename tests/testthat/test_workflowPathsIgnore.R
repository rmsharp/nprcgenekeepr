## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md ("Stop the four push workflows from running on pushes that
## change only build-ignored files", raised 2026-09-24; the owner ruled a
## `paths-ignore` list S898 and chose its scope S899): lint, pkgdown,
## R-CMD-check and test-coverage each cost a long CI run on every push to
## master, even when the push changes only project-notes files that no
## workflow reads. A literal copy of .Rbuildignore would be wrong, because
## three of the four workflows read some build-ignored files from the
## checkout: lint.yaml lints data-raw/*.R and reads .lintr, pkgdown.yaml builds
## the site from _pkgdown.yml and vignettes/articles/, and a change to a
## workflow file needs a live run to prove it. So the list is a short,
## explicit one -- the notes and methodology-tooling files plus docs/** -- and
## these tests pin three properties of it:
##   1. each of the four push triggers carries the list, and the four copies
##      are identical (a drifted copy would skip, or run, differently);
##   2. every entry is excluded by .Rbuildignore, so the list never names a
##      file that ships in the package;
##   3. the files a workflow reads are NOT matched, and pull_request stays
##      unfiltered (the owner ruled pushes only, S899).
## What these tests cannot show is GitHub's own behavior: only a live push of
## nothing but listed files, starting no run, proves that. The workflow files
## and .Rbuildignore are absent from a built package, so the tests skip there.

pkg_root <- testthat::test_path("..", "..")
workflow_dir <- file.path(pkg_root, ".github", "workflows")
rbuildignore_path <- file.path(pkg_root, ".Rbuildignore")

## The four workflows that run on every push to the default branch.
push_workflows <- c(
  "lint.yaml", "pkgdown.yaml", "R-CMD-check.yaml", "test-coverage.yaml"
)

## Files whose change cannot alter any of the four workflows' results: the
## project notes, the methodology tooling and its settings, and docs/**.
skippable_paths <- c(
  "BACKLOG.md", "CHANGELOG.md", "HANDOFFS.md", "SESSION_NOTES.md",
  "PROJECT_LEARNINGS.md", "CLAUDE.md", "SESSION_RUNNER.md", "SAFEGUARDS.md",
  "docs/audits/CI_RED_MASTER_DIAGNOSIS_2026-10-04.md",
  "docs/archive/CHANGELOG-through-2026-10-03.md",
  "docs/planning/sexcodes-adoption-plan.md",
  "methodology_trim.py", "quality_ratchet.py",
  ".quality-gates.json", ".context-budget.json"
)

## Files a workflow reads, whether or not .Rbuildignore lists them. A change to
## any of these CAN change a workflow's result, so none may be matched.
ci_input_paths <- c(
  ".github/workflows/lint.yaml",             # a workflow edit needs a live run
  ".lintr",                                   # lint.yaml's own configuration
  "_pkgdown.yml",                             # pkgdown.yaml's configuration
  "vignettes/articles/age-sex-pyramid.qmd",   # pkgdown.yaml builds these
  "vignettes/a2interactive.Rmd",
  "data-raw/kinship2FidelityValidation.R",    # lint_package() lints data-raw
  "R/reportGV.R", "tests/testthat/test_reportGV.R",
  "DESCRIPTION", "NAMESPACE", "NEWS.md", "NEWS.Rmd", "README.md", "README.Rmd",
  ".Rbuildignore", "codecov.yml", "renv.lock",
  "inst/extdata/example.csv", "man/reportGV.Rd"
)

dropCommentLines <- function(lines) {
  lines[!grepl("^\\s*#", lines)]
}

indentOf <- function(line) {
  nchar(sub("^(\\s*).*$", "\\1", line))
}

## Lines nested under lines[at]: every following non-blank line indented more
## deeply, up to the first line that is not.
childLines <- function(lines, at) {
  base <- indentOf(lines[at])
  rest <- lines[-seq_len(at)]
  rest <- rest[nzchar(trimws(rest))]
  kept <- character(0)
  for (ln in rest) {
    if (indentOf(ln) <= base) break
    kept <- c(kept, ln)
  }
  kept
}

## The lines under `on: <event>:`, or NULL when the workflow has no such event.
triggerChildren <- function(path, event) {
  lines <- dropCommentLines(readLines(path, warn = FALSE))
  on_at <- grep("^on:\\s*$", lines)
  if (length(on_at) != 1L) return(NULL)
  on_lines <- childLines(lines, on_at)
  event_at <- grep(sprintf("^\\s+%s:", event), on_lines)
  if (length(event_at) != 1L) return(NULL)
  childLines(on_lines, event_at)
}

## The entries of `on: push: paths-ignore:` (block-list form), in file order;
## character(0) when the push trigger has no such list.
pathsIgnoreEntries <- function(path) {
  kids <- triggerChildren(path, "push")
  at <- grep("^\\s*paths-ignore:\\s*$", kids)
  if (length(at) != 1L) return(character(0))
  items <- kids[-seq_len(at)]
  is_item <- grepl("^\\s*-\\s+\\S", items)
  run <- if (all(is_item)) items else items[seq_len(which(!is_item)[1] - 1L)]
  entry <- sub("^\\s*-\\s+", "", run)
  entry <- sub("\\s+#.*$", "", entry)
  gsub("^[\"']|[\"']$", "", trimws(entry))
}

## GitHub's filter-pattern subset: `**` matches any characters including `/`,
## `*` any characters except `/`, `?` one character except `/`.
globMatches <- function(glob, path) {
  rx <- gsub("([.+^$(){}|\\[\\]\\\\])", "\\\\\\1", glob, perl = TRUE)
  rx <- gsub("\\*\\*", "\001", rx)
  rx <- gsub("\\*", "[^/]*", rx)
  rx <- gsub("\001", ".*", rx, fixed = TRUE)
  rx <- gsub("\\?", "[^/]", rx)
  grepl(paste0("^", rx, "$"), path)
}

anyGlobMatches <- function(globs, path) {
  any(vapply(globs, globMatches, logical(1), path = path))
}

readRbuildignorePatterns <- function() {
  lines <- readLines(rbuildignore_path, warn = FALSE)
  lines[nzchar(lines) & !grepl("^#", lines)]
}

## R CMD build drops a path when any pattern matches the path itself or one of
## its parent directories; matching is case-insensitive perl regex.
rbuildignoreExcludes <- function(patterns, path) {
  parts <- strsplit(path, "/", fixed = TRUE)[[1]]
  prefixes <- Reduce(function(a, b) paste0(a, "/", b), parts, accumulate = TRUE)
  any(vapply(patterns, function(p) {
    any(isTRUE(tryCatch(
      any(grepl(p, prefixes, perl = TRUE, ignore.case = TRUE)),
      error = function(e) FALSE
    )))
  }, logical(1)))
}

test_that("the glob matcher behaves like GitHub's filter patterns", {
  ## Guards the probes below against passing vacuously: a matcher that never
  ## matches would make every "must NOT match" expectation true.
  expect_true(globMatches("BACKLOG.md", "BACKLOG.md"))
  expect_false(globMatches("BACKLOG.md", "BACKLOG.mdx"))
  expect_false(globMatches("BACKLOG.md", "docs/BACKLOG.md"))
  expect_true(globMatches("docs/**", "docs/a.md"))
  expect_true(globMatches("docs/**", "docs/audits/deep/a.md"))
  expect_false(globMatches("docs/**", "docs.md"))
  expect_false(globMatches("docs/**", "R/docs/a.md"))
  expect_true(globMatches("*.md", "README.md"))
  expect_false(globMatches("*.md", "docs/README.md"))
  expect_true(globMatches(".quality-gates.json", ".quality-gates.json"))
  expect_false(globMatches(".quality-gates.json", "xquality-gates.json"))
})

for (workflow_file in push_workflows) {
  ## Bound per iteration so each test_that() checks its own workflow_file.
  workflow_path <- file.path(workflow_dir, workflow_file)

  test_that(sprintf(
    "%s skips a push that changes only notes and tooling files", workflow_file
  ), {
    skip_if_not(file.exists(workflow_path),
                sprintf("%s not present in this build", workflow_file))

    entries <- pathsIgnoreEntries(workflow_path)
    expect_gt(length(entries), 0L,
              label = sprintf("number of push paths-ignore entries in %s",
                              workflow_file))

    for (p in skippable_paths) {
      expect_true(
        anyGlobMatches(entries, p),
        info = sprintf("%s: a push changing only %s should skip CI", workflow_file, p)
      )
    }
    for (p in ci_input_paths) {
      expect_false(
        anyGlobMatches(entries, p),
        info = sprintf("%s: %s is read by a workflow, so changing it must still run CI",
                       workflow_file, p)
      )
    }
  })

  test_that(sprintf(
    "%s filters only the push trigger, leaving the other triggers alone",
    workflow_file
  ), {
    skip_if_not(file.exists(workflow_path),
                sprintf("%s not present in this build", workflow_file))

    ## The skip list must exist before its neighbours are worth checking.
    expect_gt(length(pathsIgnoreEntries(workflow_path)), 0L,
              label = sprintf("push paths-ignore entries in %s", workflow_file))

    push_kids <- triggerChildren(workflow_path, "push")
    expect_true(
      any(grepl("^\\s*branches:\\s*\\[main,\\s*master\\]\\s*$", push_kids)),
      info = "the push trigger keeps its branches: [main, master] filter"
    )
    ## `paths` and `paths-ignore` cannot both filter one event.
    expect_false(any(grepl("^\\s*paths:", push_kids)))

    pr_kids <- triggerChildren(workflow_path, "pull_request")
    expect_false(is.null(pr_kids), info = "the pull_request trigger is kept")
    expect_false(
      any(grepl("^\\s*paths(-ignore)?:", pr_kids)),
      info = "the owner ruled pushes only (S899): pull_request stays unfiltered"
    )
  })
}

test_that("the four push workflows carry one identical paths-ignore list", {
  paths <- file.path(workflow_dir, push_workflows)
  skip_if_not(all(file.exists(paths)), "workflow files not present in this build")

  lists <- lapply(paths, pathsIgnoreEntries)
  names(lists) <- push_workflows
  expect_gt(length(lists[[1]]), 0L, label = "lint.yaml push paths-ignore entries")
  for (wf in push_workflows[-1]) {
    expect_identical(
      sort(lists[[wf]]), sort(lists[["lint.yaml"]]),
      info = sprintf("%s's paths-ignore list differs from lint.yaml's", wf)
    )
  }
})

test_that("every paths-ignore entry names only files .Rbuildignore excludes", {
  paths <- file.path(workflow_dir, push_workflows)
  skip_if_not(all(file.exists(paths)), "workflow files not present in this build")
  skip_if_not(file.exists(rbuildignore_path), ".Rbuildignore not present in this build")

  entries <- sort(unique(unlist(lapply(paths, pathsIgnoreEntries))))
  expect_gt(length(entries), 0L, label = "distinct paths-ignore entries")

  patterns <- readRbuildignorePatterns()
  for (entry in entries) {
    ## One concrete path the entry would match, e.g. "docs/**" -> "docs/x/y.txt".
    probe <- gsub("\\?", "x", gsub("\\*", "x", sub("\\*\\*", "x/y.txt", entry)))
    expect_true(
      globMatches(entry, probe),
      info = sprintf("test bug: probe %s does not match its own entry %s", probe, entry)
    )
    expect_true(
      rbuildignoreExcludes(patterns, probe),
      info = sprintf(
        "paths-ignore entry %s would skip CI for a file that ships in the package (%s is not excluded by .Rbuildignore)",
        entry, probe
      )
    )
  }
})
