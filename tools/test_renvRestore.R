## Guard for `renv::restore()` from an empty package cache (S1111).
##
## What it holds. From an empty cache, restore failed on two counts: renv.lock
## pinned Matrix older than R's own copy, so renv downgraded it and the source
## build stopped on a missing libintl.h; and curl, once behind the current
## release, had to build from source and then could not load. Mark's rulings:
## the lock names a dated repository, so its versions stay available as
## ready-built packages, and contributors use restore.
##
## It lives in tools/ because tests/ is frozen until CRAN answers on 3.0.0, so
## CI does not run it. Run the file checks with:
##   Rscript -e 'testthat::test_file("tools/test_renvRestore.R")'
## Add the real restore, about 20 seconds and network access, by setting
## NPRC_RUN_RESTORE=true in front of that command.

library(testthat) # nolint: undesirable_function_linter.

repoRoot <- findRepoRoot()
lock <- jsonlite::fromJSON(
  file.path(repoRoot, "renv.lock"),
  simplifyVector = FALSE
)
lockVersions <- vapply(lock$Packages, function(p) p$Version, "")

## "Rlabkey (>= 3.2.0)" and "Rlabkey" both give "Rlabkey".
packageNames <- function(specs) {
  sub("[ (].*$", "", trimws(unlist(specs, use.names = FALSE)))
}

test_that("the lock and the activate script name one renv version", {
  activate <- readLines(file.path(repoRoot, "renv", "activate.R"), warn = FALSE)
  line <- grep('^\\s*version <- "', activate, value = TRUE)[[1L]]
  requested <- sub('^\\s*version <- "([^"]+)".*$', "\\1", line)
  expect_identical(requested, lockVersions[["renv"]])
})

test_that("the lock names a dated repository, not one that moves", {
  urls <- vapply(lock$R$Repositories, function(r) r$URL, "")
  expect_gt(length(urls), 0L)
  expect_match(
    urls,
    "^https://packagemanager\\.posit\\.co/cran/[0-9]{4}-[0-9]{2}-[0-9]{2}$"
  )
})

test_that("the lock does not hold R's own packages back", {
  ## An older pin makes renv replace R's copy with a source build, and Matrix
  ## cannot build on a Mac without libintl.h.
  for (package in c("Matrix", "lattice", "codetools")) {
    description <- file.path(R.home("library"), package, "DESCRIPTION")
    skip_if_not(
      file.exists(description),
      paste(package, "is not in R's library")
    )
    own <- read.dcf(description, fields = "Version")[[1L]]
    expect_true(
      package_version(lockVersions[[package]]) >= package_version(own),
      info = paste0(package, ": lock ", lockVersions[[package]], ", R ", own)
    )
  }
})

test_that("the lock holds everything the package needs", {
  ## A plain renv::snapshot() once dropped 39 of 136 packages (S1110).
  fields <- read.dcf(
    file.path(repoRoot, "DESCRIPTION"),
    fields = c("Imports", "Suggests")
  )
  declared <- packageNames(strsplit(fields, ",", fixed = TRUE))
  needed <- unique(c(
    declared,
    packageNames(lapply(lock$Packages, function(p) {
      c(p$Depends, p$Imports, p$LinkingTo)
    }))
  ))
  standard <- c("R", tools::standard_package_names()$base)
  missing <- setdiff(needed, c(standard, names(lockVersions)))
  expect_setequal(missing, character())
})

## Restores this repository's lock from empty folders in a child R process. The
## script stops, before installing anything, unless the project loaded into its
## temp library: when renv cannot start, restore runs in a plain session and
## writes to the person's own R library, as one S1111 experiment did.
runRestore <- function() {
  home <- tempfile("restore-")
  project <- file.path(home, "project")
  dir.create(file.path(project, "renv"), recursive = TRUE)
  for (file in c(
    "DESCRIPTION", "renv.lock", ".Rprofile",
    file.path("renv", "activate.R"), file.path("renv", "settings.json")
  )) {
    file.copy(file.path(repoRoot, file), file.path(project, file))
  }
  activate <- file.path(project, "renv", "activate.R")
  activateBefore <- readLines(activate, warn = FALSE)
  folders <- file.path(home, c("root", "libroot", "user", "sandbox"))
  for (folder in folders) {
    dir.create(folder)
  }
  script <- file.path(home, "restore.R")
  writeLines(r"(
    options(renv.consent = TRUE)
    first <- normalizePath(.libPaths()[1L])
    root <- normalizePath(Sys.getenv("RENV_PATHS_LIBRARY_ROOT"))
    if (!startsWith(first, root)) {
      cat("NOT-LOADED", first, "\n")
      quit(status = 3L)
    }
    cat("LOADED\n")
    renv::restore(prompt = FALSE)
    needed <- names(renv::lockfile_read("renv.lock")$Packages)
    cat("MISSING:", setdiff(needed, rownames(installed.packages())), "\n")
  )", script)
  output <- withr::with_dir(
    project,
    suppressWarnings(system2(
      file.path(R.home("bin"), "Rscript"),
      shQuote(script),
      stdout = TRUE,
      stderr = TRUE,
      timeout = 600L,
      env = c(
        paste0("RENV_PROJECT=", project),
        paste0("RENV_PATHS_ROOT=", folders[[1L]]),
        paste0("RENV_PATHS_LIBRARY_ROOT=", folders[[2L]]),
        paste0("R_LIBS_USER=", folders[[3L]]),
        paste0("RENV_PATHS_SANDBOX=", folders[[4L]]),
        "R_LIBS=",
        ## Under testthat, a failed install did not stop renv::restore(), so the
        ## child must not look like a test run.
        "TESTTHAT="
      )
    ))
  )
  activateAfter <- readLines(activate, warn = FALSE)
  ## renv makes its sandbox read-only.
  system2("chmod", c("-R", "u+w", shQuote(home)))
  unlink(home, recursive = TRUE)
  list(
    text = paste(output, collapse = "\n"),
    status = attr(output, "status") %||% 0L,
    activateUnchanged = identical(activateBefore, activateAfter)
  )
}

test_that("restore works from an empty package cache", {
  skip_if_not(
    identical(Sys.getenv("NPRC_RUN_RESTORE"), "true"),
    "set NPRC_RUN_RESTORE=true to run the real restore"
  )
  result <- runRestore()
  expect_match(result$text, "LOADED", fixed = TRUE)
  expect_no_match(result$text, "NOT-LOADED", fixed = TRUE)
  expect_identical(result$status, 0L, info = result$text)
  expect_match(result$text, "MISSING: *\\n?$")
  ## A rewritten activate script leaves every contributor a changed file.
  expect_true(result$activateUnchanged)
  ## A dated repository serves every version ready-built on a Mac. A source
  ## build is the first sign that the lock has stopped matching it.
  if (identical(Sys.info()[["sysname"]], "Darwin")) {
    expect_no_match(result$text, "built from source", fixed = TRUE)
  }
})
