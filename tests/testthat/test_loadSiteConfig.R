#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Regression coverage for issue #50: the modular app crashed on boot when a
#' config file in the documented format (inst/extdata/example_nprcgenekeepr_config
#' -- comments, blank lines, multi-line quoted / comma-separated values) was
#' present, because the appServer config observer parsed it with
#' read.table(sep = "="), which assumes a strict 2-column table and stops with
#' "line N did not have 2 elements". loadSiteConfig() parses via the tolerant
#' getSiteInfo() path, wrapped in tryCatch so a malformed file can never crash
#' boot.

test_that("loadSiteConfig returns NULL when no config file is present (#50)", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  expect_null(loadSiteConfig())
})

test_that("loadSiteConfig parses the documented config format (#50)", {
  # THE bug case: read.table(sep = "=") choked on this exact file
  # ("line 6 did not have 2 elements") and crashed the app on boot.
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  example_cfg <- system.file("extdata", "example_nprcgenekeepr_config",
                             package = "nprcgenekeepr")
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  file.copy(example_cfg, file.path(tmp, cfg_name))

  cfg <- loadSiteConfig()
  expect_type(cfg, "list")
  expect_equal(cfg$center, "SNPRC")
  expect_gte(length(cfg$lkPedColumns), 6L)
})

test_that("loadSiteConfig returns NULL (no crash) on a malformed config (#50)", {
  # tryCatch safety net: a present-but-unparseable file -- here missing the
  # required 'center' definition, which getParamDef() stop()s on -- must not
  # propagate the error; loadSiteConfig swallows it and returns NULL.
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(c("baseUrl = \"http://example\"", "schemaName = \"study\""),
             file.path(tmp, cfg_name))
  expect_null(loadSiteConfig())
})

test_that("the documented config format breaks read.table(sep = '=') (#50 root cause)", {
  # Characterization guard: documents WHY the observer must not use read.table.
  # Stays green before and after the fix; fails loudly if anyone reintroduces
  # the strict 2-column parser against the documented format.
  example_cfg <- system.file("extdata", "example_nprcgenekeepr_config",
                             package = "nprcgenekeepr")
  expect_error(
    read.table(example_cfg, header = TRUE, sep = "=", stringsAsFactors = FALSE)
  )
})

test_that("appServer config observer loads via loadSiteConfig, not read.table (#50)", {
  src <- paste(deparse(appServer), collapse = "\n")
  expect_match(src, "loadSiteConfig", fixed = TRUE)
  expect_false(grepl("read.table", src, fixed = TRUE))
})
