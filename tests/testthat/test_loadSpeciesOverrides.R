## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Issue #73 Part 2 Slice 1 (GVA tab): the user-configurable species
#' reproductive-parameter override path. A colony points an optional config-file
#' key (speciesOverridesPath) at a CSV carrying the four speciesGestation columns
#' (species, gestation, minMaleBreedingAge, minFemaleBreedingAge); two optional
#' scalar keys (minBreedingAgeDefault, gestationDefault) override the
#' absent-species fallbacks. loadSpeciesOverrides() reads them, MERGES the CSV
#' onto the bundled speciesGestation table (a user CSV overrides only the species
#' it lists; every unlisted species keeps its bundled value -- D4), and fails
#' soft (warn + built-ins, never crash boot) exactly like loadSiteConfig().
#' getSpeciesOverridesPath() is the getConfigApiKey-style optional soft-lookup.
#' Isolation copies test_loadSiteConfig.R (withr::local_tempdir + HOME envvar).

# ---------------------------------------------------------------------------
# getSpeciesOverridesPath() -- optional soft-lookup (mirrors getConfigApiKey)
# ---------------------------------------------------------------------------

test_that("getSpeciesOverridesPath returns '' for a NULL or missing file", {
  expect_identical(nprcgenekeepr:::getSpeciesOverridesPath(NULL), "")
  expect_identical(
    nprcgenekeepr:::getSpeciesOverridesPath(tempfile("nope_")), ""
  )
})

test_that("getSpeciesOverridesPath reads the key when present, '' when absent", {
  cfg <- tempfile("cfg_")
  writeLines('speciesOverridesPath = "/data/colony_species.csv"', cfg)
  withr::defer(unlink(cfg))
  expect_identical(
    nprcgenekeepr:::getSpeciesOverridesPath(cfg), "/data/colony_species.csv"
  )

  cfg2 <- tempfile("cfg_")
  writeLines('center = "SNPRC"', cfg2)
  withr::defer(unlink(cfg2))
  expect_identical(nprcgenekeepr:::getSpeciesOverridesPath(cfg2), "")
})

test_that("getSpeciesOverridesPath ignores a commented-out key", {
  # A commented "# key = value" example line must NOT be read as active
  # (getTokenList does not itself strip # comments).
  cfg <- tempfile("cfg_")
  writeLines('# speciesOverridesPath = "/home/you/overrides.csv"', cfg)
  withr::defer(unlink(cfg))
  expect_identical(nprcgenekeepr:::getSpeciesOverridesPath(cfg), "")
})

# ---------------------------------------------------------------------------
# loadSpeciesOverrides() -- top-level reader (mirrors loadSiteConfig)
# ---------------------------------------------------------------------------

test_that("loadSpeciesOverrides returns a NULL-member list when no config file", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  ov <- loadSpeciesOverrides()
  expect_type(ov, "list")
  expect_null(ov$breedingTable)
  expect_null(ov$gestationTable)
  expect_null(ov$breedingAgeDefault)
  expect_null(ov$gestationDefault)
})

test_that("loadSpeciesOverrides merges the CSV and parses the fallback keys", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  csv <- file.path(tmp, "overrides.csv")
  utils::write.csv(
    data.frame(
      species = "RHESUS", gestation = 200L,
      minMaleBreedingAge = 5.0, minFemaleBreedingAge = 3.0,
      stringsAsFactors = FALSE
    ),
    csv, row.names = FALSE
  )
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(
    c(
      sprintf('speciesOverridesPath = "%s"', csv),
      "minBreedingAgeDefault = 5",
      "gestationDefault = 99"
    ),
    file.path(tmp, cfg_name)
  )

  ov <- loadSpeciesOverrides()

  ## the overridden RHESUS row reaches the accessors
  expect_equal(
    getSpeciesMinBreedingAge("RHESUS", "M", breedingTable = ov$breedingTable), 5.0
  )
  expect_equal(
    getSpeciesMinBreedingAge("RHESUS", "F", breedingTable = ov$breedingTable), 3.0
  )
  expect_equal(
    getSpeciesGestation("RHESUS", gestationTable = ov$gestationTable), 200L
  )
  ## an unlisted species keeps its bundled value (D4 merge, not replace)
  expect_equal(
    getSpeciesMinBreedingAge("CYNOMOLGUS", "M", breedingTable = ov$breedingTable),
    4.0
  )
  expect_equal(
    getSpeciesGestation("BONOBO", gestationTable = ov$gestationTable), 240L
  )
  ## fallbacks parsed (numeric / integer)
  expect_equal(ov$breedingAgeDefault, 5)
  expect_equal(ov$gestationDefault, 99L)
})

test_that("loadSpeciesOverrides ignores commented-out override keys", {
  # The shipped example config documents the keys as commented "# key = value"
  # lines. A user who has not uncommented them must get bundled behavior with no
  # boot warning -- the commented lines must not activate.
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(
    c(
      'center = "SNPRC"',
      '# speciesOverridesPath = "/home/you/overrides.csv"',
      "# minBreedingAgeDefault = 5",
      "# gestationDefault = 99"
    ),
    file.path(tmp, cfg_name)
  )
  expect_silent(ov <- loadSpeciesOverrides())
  expect_null(ov$breedingTable)
  expect_null(ov$gestationTable)
  expect_null(ov$breedingAgeDefault)
  expect_null(ov$gestationDefault)
})

test_that("loadSpeciesOverrides returns NULL members when no path key set", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines('center = "SNPRC"', file.path(tmp, cfg_name))

  ov <- loadSpeciesOverrides()
  expect_null(ov$breedingTable)
  expect_null(ov$gestationTable)
  expect_null(ov$breedingAgeDefault)
  expect_null(ov$gestationDefault)
})

test_that("loadSpeciesOverrides soft-fails (warn, NULL) on a missing CSV", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(
    'speciesOverridesPath = "/no/such/overrides.csv"',
    file.path(tmp, cfg_name)
  )
  expect_warning(ov <- loadSpeciesOverrides())
  expect_null(ov$breedingTable)
  expect_null(ov$gestationTable)
})

test_that("loadSpeciesOverrides soft-fails (warn, NULL) on a malformed CSV", {
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  bad <- file.path(tmp, "bad.csv")
  utils::write.csv(data.frame(foo = 1L, bar = 2L), bad, row.names = FALSE)
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(sprintf('speciesOverridesPath = "%s"', bad),
             file.path(tmp, cfg_name))
  expect_warning(ov <- loadSpeciesOverrides())
  expect_null(ov$breedingTable)
  expect_null(ov$gestationTable)
})

test_that("loadSpeciesOverrides MERGE keeps every unlisted bundled species (D4)", {
  # The #1 dragon: the accessors REPLACE (an absent species falls to the
  # fallback, not the bundled value), so the reader MUST merge a partial CSV
  # onto the bundled table. A one-row CSV must leave the other 13 species at
  # their bundled values.
  tmp <- withr::local_tempdir()
  withr::local_envvar(c(HOME = tmp))
  csv <- file.path(tmp, "overrides.csv")
  utils::write.csv(
    data.frame(
      species = "RHESUS", gestation = 200L,
      minMaleBreedingAge = 5.0, minFemaleBreedingAge = 3.0,
      stringsAsFactors = FALSE
    ),
    csv, row.names = FALSE
  )
  cfg_name <- basename(getConfigFileName(Sys.info())[["configFile"]])
  writeLines(sprintf('speciesOverridesPath = "%s"', csv),
             file.path(tmp, cfg_name))

  ov <- loadSpeciesOverrides()
  ## all 14 bundled species survive the merge
  expect_true(all(
    nprcgenekeepr::speciesGestation$species %in% ov$breedingTable$species
  ))
  ## spot-check several unlisted species kept their bundled values
  expect_equal(getSpeciesGestation("CYNOMOLGUS", gestationTable = ov$gestationTable), 170L)
  expect_equal(getSpeciesGestation("CHIMPANZEE", gestationTable = ov$gestationTable), 240L)
  expect_equal(
    getSpeciesMinBreedingAge("BABOON", "M", breedingTable = ov$breedingTable), 6.0
  )
  expect_equal(
    getSpeciesMinBreedingAge("SQUIRREL MONKEY", "F", breedingTable = ov$breedingTable),
    2.5
  )
})

# ---------------------------------------------------------------------------
# appServer wiring -- overrides loaded at boot and passed to the GVA module (D7)
# ---------------------------------------------------------------------------

test_that("appServer loads species overrides and passes them to the GVA module", {
  src <- paste(deparse(appServer), collapse = "\n")
  expect_match(src, "loadSpeciesOverrides", fixed = TRUE)
  expect_match(src, "speciesOverrides", fixed = TRUE)
})
