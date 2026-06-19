#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr

# Tests for setLabKeyDefaults(): explicit optional API-key authentication with
# a .netrc fallback and a clear "no credential found" error. All tests are
# off-network and deterministic -- the only external seam stubbed is
# Rlabkey::labkey.setDefaults; the credential sources (env var, config-file
# apiKey token, netrc location) are routed through a controlled siteInfo list
# plus withr-managed environment variables.

# Build a minimal siteInfo list carrying only the fields setLabKeyDefaults()
# uses. Defaults point credential sources at non-existent paths so the "no
# credential" branch is the resting state unless a test supplies one.
make_site_info <- function(baseUrl = "https://example.test",
                           configFile = tempfile("nocfg_"),
                           homeDir = tempfile("nohome_"),
                           sysname = Sys.info()[["sysname"]]) {
  list(
    baseUrl = baseUrl,
    configFile = configFile,
    homeDir = homeDir,
    sysname = sysname
  )
}

# Platform-correct netrc file name for the running OS.
netrc_basename <- function(sysname = Sys.info()[["sysname"]]) {
  if (grepl("WIND", toupper(sysname))) "_netrc" else ".netrc"
}

test_that("setLabKeyDefaults uses an apiKey from the environment variable", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("withr")

  withr::local_envvar(NPRCGENEKEEPR_LABKEY_APIKEY = "ENVKEY123", NETRC = "")
  site_info <- make_site_info(baseUrl = "https://env.example")
  set_defaults_mock <- mockery::mock(TRUE)
  mockery::stub(setLabKeyDefaults, "labkey.setDefaults", set_defaults_mock)

  result <- setLabKeyDefaults(site_info)

  mockery::expect_called(set_defaults_mock, 1)
  mockery::expect_args(set_defaults_mock, 1,
    apiKey = "ENVKEY123", baseUrl = "https://env.example"
  )
  expect_equal(result$method, "apiKey")
  expect_equal(result$baseUrl, "https://env.example")
})

test_that("setLabKeyDefaults falls back to the config-file apiKey token", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("withr")

  config_file <- tempfile("cfg_")
  writeLines("apiKey = \"CONFIGKEY\"", config_file)
  withr::defer(unlink(config_file))
  withr::local_envvar(NPRCGENEKEEPR_LABKEY_APIKEY = "", NETRC = "")
  site_info <- make_site_info(
    baseUrl = "https://cfg.example", configFile = config_file
  )
  set_defaults_mock <- mockery::mock(TRUE)
  mockery::stub(setLabKeyDefaults, "labkey.setDefaults", set_defaults_mock)

  result <- setLabKeyDefaults(site_info)

  mockery::expect_called(set_defaults_mock, 1)
  mockery::expect_args(set_defaults_mock, 1,
    apiKey = "CONFIGKEY", baseUrl = "https://cfg.example"
  )
  expect_equal(result$method, "apiKey")
})

test_that("setLabKeyDefaults prefers the env var over the config token", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("withr")

  config_file <- tempfile("cfg_")
  writeLines("apiKey = \"CONFIGKEY\"", config_file)
  withr::defer(unlink(config_file))
  withr::local_envvar(NPRCGENEKEEPR_LABKEY_APIKEY = "ENVKEY", NETRC = "")
  site_info <- make_site_info(configFile = config_file)
  set_defaults_mock <- mockery::mock(TRUE)
  mockery::stub(setLabKeyDefaults, "labkey.setDefaults", set_defaults_mock)

  setLabKeyDefaults(site_info)

  mockery::expect_args(set_defaults_mock, 1,
    apiKey = "ENVKEY", baseUrl = "https://example.test"
  )
})

test_that("setLabKeyDefaults uses netrc fallback via the NETRC env var", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("withr")

  netrc_file <- tempfile("netrc_")
  writeLines("machine example.test login apikey password SECRET", netrc_file)
  withr::defer(unlink(netrc_file))
  withr::local_envvar(NPRCGENEKEEPR_LABKEY_APIKEY = "", NETRC = netrc_file)
  site_info <- make_site_info()
  set_defaults_mock <- mockery::mock(TRUE)
  mockery::stub(setLabKeyDefaults, "labkey.setDefaults", set_defaults_mock)

  result <- setLabKeyDefaults(site_info)

  mockery::expect_called(set_defaults_mock, 0)
  expect_equal(result$method, "netrc")
})

test_that("setLabKeyDefaults uses netrc fallback via the home-directory file", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("withr")

  home_dir <- tempfile("home_")
  dir.create(home_dir)
  withr::defer(unlink(home_dir, recursive = TRUE))
  writeLines(
    "machine example.test login apikey password SECRET",
    file.path(home_dir, netrc_basename())
  )
  withr::local_envvar(NPRCGENEKEEPR_LABKEY_APIKEY = "", NETRC = "")
  site_info <- make_site_info(homeDir = home_dir)
  set_defaults_mock <- mockery::mock(TRUE)
  mockery::stub(setLabKeyDefaults, "labkey.setDefaults", set_defaults_mock)

  result <- setLabKeyDefaults(site_info)

  mockery::expect_called(set_defaults_mock, 0)
  expect_equal(result$method, "netrc")
})

test_that("setLabKeyDefaults errors clearly when no credential is found", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("withr")

  withr::local_envvar(NPRCGENEKEEPR_LABKEY_APIKEY = "", NETRC = "")
  # configFile and homeDir default to non-existent temp paths => no apiKey,
  # no home netrc.
  site_info <- make_site_info()
  set_defaults_mock <- mockery::mock(TRUE)
  mockery::stub(setLabKeyDefaults, "labkey.setDefaults", set_defaults_mock)

  expect_error(setLabKeyDefaults(site_info), "No LabKey credential found")
  mockery::expect_called(set_defaults_mock, 0)
})

test_that("setLabKeyDefaults treats an empty-string env var as absent", {
  skip_if_not_installed("mockery")
  skip_if_not_installed("withr")

  netrc_file <- tempfile("netrc_")
  writeLines("machine example.test login apikey password SECRET", netrc_file)
  withr::defer(unlink(netrc_file))
  # Env var explicitly set to "" must NOT take the apiKey branch.
  withr::local_envvar(NPRCGENEKEEPR_LABKEY_APIKEY = "", NETRC = netrc_file)
  site_info <- make_site_info()
  set_defaults_mock <- mockery::mock(TRUE)
  mockery::stub(setLabKeyDefaults, "labkey.setDefaults", set_defaults_mock)

  result <- setLabKeyDefaults(site_info)

  mockery::expect_called(set_defaults_mock, 0)
  expect_equal(result$method, "netrc")
})
