## Guard for the contributor guide: `.github/CONTRIBUTING.md` (the short file
## GitHub links to) and `vignettes/articles/contributing.qmd` (the full article).
##
## It holds the owner's three S1110 rulings: a short file plus a full article;
## tests required of outside contributors, while this project's internal
## session protocol is neither asked for nor described; written for R developers,
## with an opening section for anyone filing an Issue.
##
## It lives in tools/ because tests/ is frozen until CRAN answers on 3.0.0, so
## CI does not run it. Run it with:
##   Rscript -e 'testthat::test_file("tools/test_contributingGuide.R")'

library(testthat)

repoRoot <- local({
  dir <- getwd()
  while (!file.exists(file.path(dir, "DESCRIPTION")) && dirname(dir) != dir) {
    dir <- dirname(dir)
  }
  dir
})
shortPath <- file.path(repoRoot, ".github", "CONTRIBUTING.md")
articlePath <- file.path(repoRoot, "vignettes", "articles", "contributing.qmd")

## An absent file reads as "", so each block below fails on its own assertion
## rather than stopping on a file-open error.
guideText <- function(path) {
  if (!file.exists(path)) {
    return("")
  }
  paste(readLines(path, warn = FALSE), collapse = "\n")
}

guideLines <- function(path) {
  strsplit(guideText(path), "\n", fixed = TRUE)[[1L]]
}

## The body of one "## Heading" section of the article, "" when it is absent.
articleSection <- function(heading) {
  lines <- guideLines(articlePath)
  start <- which(lines == paste("##", heading))
  if (length(start) != 1L) {
    return("")
  }
  later <- which(grepl("^## ", lines) & seq_along(lines) > start)
  end <- if (length(later) > 0L) later[1L] - 1L else length(lines)
  paste(lines[start:end], collapse = "\n")
}

## Backticked tokens shaped like a path in this repository. A token with a
## placeholder such as `test_<name>.R` names no one file, so it is left out.
namedPaths <- function(text) {
  ticked <- regmatches(text, gregexpr("`[^`\n]+`", text))[[1L]]
  ## A path the reader is told to pass to a command, inside a code block.
  quoted <- regmatches(text, gregexpr("\"[^\"\n]+\\.[A-Za-z]+\"", text))[[1L]]
  tokens <- gsub("[`\"]", "", c(ticked, quoted))
  isPath <- grepl(
    paste0(
      "^[.A-Za-z0-9_-]+/[.A-Za-z0-9_/-]*$",
      "|^[.A-Za-z0-9_/-]+\\.(R|Rmd|md|qmd|yml|yaml|lock|csv|txt)$",
      "|^(DESCRIPTION|NAMESPACE)$"
    ),
    tokens
  )
  unique(tokens[isPath])
}

articleHeadings <- c(
  "Report a problem or ask for a feature",
  "Set up a copy of the package",
  "Where things live",
  "Run the tests",
  "Write tests with your change",
  "Check style with lint",
  "Update the documentation",
  "Propose a change"
)

test_that("both guide files exist", {
  expect_true(file.exists(shortPath))
  expect_true(file.exists(articlePath))
})

test_that("the short file stays short and leaves the commands to the article", {
  text <- guideText(shortPath)
  expect_gt(nchar(text), 0L)
  expect_lte(length(guideLines(shortPath)), 40L)
  ## A command held in two places goes stale in one of them.
  expect_false(grepl("::", text, fixed = TRUE))
})

test_that("the short file links to the article, Issues and the code of conduct", {
  text <- guideText(shortPath)
  expect_match(
    text,
    "https://rmsharp.github.io/nprcgenekeepr/articles/contributing.html",
    fixed = TRUE
  )
  expect_match(
    text,
    "https://github.com/rmsharp/nprcgenekeepr/issues",
    fixed = TRUE
  )
  expect_match(text, "CODE_OF_CONDUCT.md", fixed = TRUE)
})

test_that("the article is listed in the site's Articles menu", {
  config <- yaml::read_yaml(file.path(repoRoot, "_pkgdown.yml"))
  menu <- unlist(lapply(config$articles, `[[`, "contents"))
  expect_true("articles/contributing" %in% menu)
})

test_that("the article has its sections, Issues first", {
  lines <- guideLines(articlePath)
  found <- sub("^## ", "", lines[grepl("^## ", lines)])
  expect_identical(found, articleHeadings)
})

test_that("the Issues section needs no setup and protects colony data", {
  section <- articleSection("Report a problem or ask for a feature")
  expect_match(
    section,
    "https://github.com/rmsharp/nprcgenekeepr/issues",
    fixed = TRUE
  )
  expect_match(section, "sessionInfo()", fixed = TRUE)
  expect_match(section, "packageVersion(", fixed = TRUE)
  expect_match(section, "expected", fixed = TRUE)
  expect_match(section, "example data", fixed = TRUE)
  expect_match(section, "real colony records", fixed = TRUE)
})

test_that("the commands a contributor runs are all there", {
  expectInSection <- function(heading, command) {
    expect_match(articleSection(heading), command, fixed = TRUE)
  }
  ## From an empty cache, tools/test_renvRestore.R runs this restore for real.
  expectInSection("Set up a copy of the package", "renv::restore()")
  expect_no_match(
    articleSection("Set up a copy of the package"),
    "exclude = ",
    fixed = TRUE
  )
  ## Loading in the session that installed failed with an R_decompress1 error;
  ## a fresh session loaded and tested normally (S1111).
  expect_match(
    articleSection("Set up a copy of the package"),
    "restart R",
    ignore.case = TRUE
  )
  expectInSection(
    "Set up a copy of the package",
    'renv::install(c("devtools", "lintr", "roxygen2@'
  )
  ## A fresh clone fails test_getVersion.R until the package has been installed.
  expectInSection(
    "Set up a copy of the package",
    "devtools::install(upgrade = FALSE)"
  )
  expectInSection("Set up a copy of the package", "pkgload::load_all(")
  expectInSection("Run the tests", "testthat::test_file(")
  expectInSection("Run the tests", "NOT_CRAN")
  expectInSection("Run the tests", "devtools::test()")
  expectInSection("Run the tests", "devtools::check()")
  expectInSection("Check style with lint", "lintr::lint_package()")
  expectInSection("Update the documentation", "devtools::document()")
  expectInSection("Update the documentation", "NEWS.Rmd")
  expectInSection("Update the documentation", "_pkgdown.yml")
})

test_that("the guide installs the roxygen2 version the package records", {
  ## Any other version rewrites DESCRIPTION, NAMESPACE and many help pages when
  ## a contributor runs devtools::document(); 8.1.1 changed 27 files (S1110).
  recorded <- read.dcf(
    file.path(repoRoot, "DESCRIPTION"),
    fields = "Config/roxygen2/version"
  )[[1L]]
  expect_false(is.na(recorded))
  expect_match(
    guideText(articlePath),
    paste0("roxygen2@", recorded),
    fixed = TRUE
  )
})

test_that("tests are required with a change, and test-first is explained", {
  section <- articleSection("Write tests with your change")
  expect_match(section, "pull request", fixed = TRUE)
  expect_match(section, "failing test", fixed = TRUE)
  expect_match(section, "not required", fixed = TRUE)
})

test_that("every repository path the guide names exists", {
  for (path in c(shortPath, articlePath)) {
    named <- namedPaths(guideText(path))
    expect_gt(length(named), 0L)
    missing <- named[!file.exists(file.path(repoRoot, named))]
    expect_identical(missing, character(0L))
  }
})

test_that("the guide never describes this project's internal protocol", {
  internal <- c(
    "SESSION_NOTES", "SESSION_RUNNER", "SAFEGUARDS", "HANDOFFS", "BACKLOG",
    "CHANGELOG", "PROJECT_LEARNINGS", "CLAUDE", "methodology/", "phase gate",
    "RED", "GREEN", "REFACTOR"
  )
  for (path in c(shortPath, articlePath)) {
    text <- guideText(path)
    expect_gt(nchar(text), 0L)
    for (word in internal) {
      expect_false(grepl(word, text, fixed = TRUE), label = word)
    }
  }
})

test_that("a site build runs none of the article's code", {
  text <- guideText(articlePath)
  expect_gt(nchar(text), 0L)
  expect_false(grepl("```{", text, fixed = TRUE))
})
