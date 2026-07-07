# Tests for modPotentialParents.R - Potential Parents Shiny Module (#48)
#
# Wires getPotentialParents() into a user-facing Shiny surface: a numeric
# maxGestationalPeriod input (default 210), a "Find Potential Parents" button,
# a sortable results table, and a CSV download. Owner-ratified design in
# Session 79; integration of the shipped #31 logic under umbrella #45.

# =============================================================================
# flattenPotentialParents() - pure helper turning the getPotentialParents
# list-of-lists (or NULL) into a render/CSV-ready data.frame.
# =============================================================================

test_that("flattenPotentialParents exists", {
  expect_true(exists("flattenPotentialParents"))
})

test_that("flattenPotentialParents returns a data.frame with the expected columns", {
  pp <- list(list(id = "A1", sires = "S1", dams = "D1"))
  df <- flattenPotentialParents(pp)

  expect_true(is.data.frame(df))
  expect_identical(names(df), c("id", "nSires", "nDams", "sires", "dams"))
})

test_that("flattenPotentialParents maps NULL to a 0-row data.frame (empty state)", {
  df <- flattenPotentialParents(NULL)

  expect_true(is.data.frame(df))
  expect_equal(nrow(df), 0L)
  expect_true(all(c("id", "nSires", "nDams", "sires", "dams") %in% names(df)))
})

test_that("flattenPotentialParents maps an empty list to a 0-row data.frame", {
  df <- flattenPotentialParents(list())

  expect_true(is.data.frame(df))
  expect_equal(nrow(df), 0L)
  expect_true(all(c("id", "nSires", "nDams", "sires", "dams") %in% names(df)))
})

test_that("flattenPotentialParents flattens a multi-animal list correctly", {
  pp <- list(
    list(id = "A1", sires = c("S1", "S2"), dams = "D1"),
    list(id = "A2", sires = "S3", dams = c("D2", "D3", "D4"))
  )
  df <- flattenPotentialParents(pp)

  expect_equal(nrow(df), 2L)
  expect_equal(df$id, c("A1", "A2"))
  expect_equal(df$nSires, c(2L, 1L))
  expect_equal(df$nDams, c(1L, 3L))
  expect_equal(df$sires, c("S1, S2", "S3"))
  expect_equal(df$dams, c("D1", "D2, D3, D4"))
})

test_that("flattenPotentialParents handles an entry with no candidate sires", {
  pp <- list(list(id = "A1", sires = character(0), dams = "D1"))
  df <- flattenPotentialParents(pp)

  expect_equal(df$nSires, 0L)
  expect_equal(df$sires, "")
  expect_equal(df$nDams, 1L)
  expect_equal(df$dams, "D1")
})

# =============================================================================
# CSV content - the flattened data.frame round-trips through write.csv.
# =============================================================================

test_that("flattenPotentialParents output round-trips through write.csv", {
  pp <- list(
    list(id = "A1", sires = c("S1", "S2"), dams = "D1"),
    list(id = "A2", sires = character(0), dams = c("D2", "D3"))
  )
  df <- flattenPotentialParents(pp)

  tf <- tempfile(fileext = ".csv")
  on.exit(unlink(tf))
  utils::write.csv(df, tf, row.names = FALSE)
  back <- utils::read.csv(tf, stringsAsFactors = FALSE, colClasses = "character")

  expect_equal(nrow(back), 2L)
  expect_true(all(c("id", "nSires", "nDams", "sires", "dams") %in% names(back)))
  expect_equal(back$id, c("A1", "A2"))
  expect_equal(back$sires, c("S1, S2", ""))
  expect_equal(back$dams, c("D1", "D2, D3"))
})

# =============================================================================
# modPotentialParentsUI()
# =============================================================================

test_that("modPotentialParentsUI returns a shiny.tag", {
  ui <- modPotentialParentsUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modPotentialParentsUI contains the expected controls and namespace", {
  ui_html <- as.character(modPotentialParentsUI("ppNS"))

  expect_true(grepl("ppNS-maxGestationalPeriod", ui_html))
  expect_true(grepl("ppNS-findParents", ui_html))
  expect_true(grepl("ppNS-downloadParents", ui_html))
  expect_true(grepl("ppNS-resultsTable", ui_html))
  expect_true(grepl("Find Potential Parents", ui_html))
})

test_that("modPotentialParentsUI numeric input defaults to 210", {
  ui_html <- as.character(modPotentialParentsUI("test"))
  expect_true(grepl("value=\"210\"", ui_html))
})

# =============================================================================
# modPotentialParentsServer()
# =============================================================================

test_that("modPotentialParentsServer computes a populated table on button press", {
  skip_if_not_installed("shiny")

  pedOne <- nprcgenekeepr::rhesusPedigree
  pedOne$fromCenter <- TRUE

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(pedOne), minSireAge = 2, minDamAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      td <- session$getReturned()$tableData()

      expect_true(is.data.frame(td))
      expect_true(nrow(td) > 0L)
      expect_true(all(c("id", "nSires", "nDams", "sires", "dams") %in% names(td)))
      expect_true("BRI2MW" %in% td$id)
    }
  )
})

test_that("modPotentialParentsServer degrades to an empty table when fromCenter is absent", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2003-01-01")),
    exit = as.Date(NA),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped), minSireAge = 2, minDamAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      td <- session$getReturned()$tableData()

      expect_true(is.data.frame(td))
      expect_equal(nrow(td), 0L)
    }
  )
})

test_that("modPotentialParentsServer degrades to an empty table when there are no unknowns", {
  skip_if_not_installed("shiny")

  # Only from-center animal (C) has both parents known; A and B have unknown
  # parents but are not from-center -> getPotentialParents returns NULL.
  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2003-01-01")),
    exit = as.Date(NA),
    fromCenter = c(FALSE, FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped), minSireAge = 2, minDamAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)
      td <- session$getReturned()$tableData()

      expect_true(is.data.frame(td))
      expect_equal(nrow(td), 0L)
    }
  )
})

test_that("modPotentialParentsServer returns the expected reactive list", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B", "C"),
    sire = c(NA, NA, "A"),
    dam = c(NA, NA, "B"),
    sex = c("M", "F", "F"),
    birth = as.Date(c("2000-01-01", "2000-01-01", "2003-01-01")),
    exit = as.Date(NA),
    fromCenter = c(TRUE, TRUE, TRUE),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped)),
    {
      result <- session$getReturned()

      expect_true(is.list(result))
      expect_true(all(c("potentialParents", "tableData") %in% names(result)))
      expect_true(is.function(result$potentialParents))
      expect_true(is.function(result$tableData))
    }
  )
})

# =============================================================================
# Issue #46 item 2b - species-keyed prefill of the gestation numericInput.
#
# firstPedigreeSpecies() - pure helper: the single representative species used
# to default the gestation window (first non-NA, non-empty species value).
# =============================================================================

test_that("firstPedigreeSpecies exists", {
  expect_true(exists("firstPedigreeSpecies"))
})

test_that("firstPedigreeSpecies returns the first non-NA species value", {
  ped <- data.frame(
    id = c("A", "B", "C"),
    species = c(NA, "TESTSP", "RHESUS"),
    stringsAsFactors = FALSE
  )
  expect_identical(firstPedigreeSpecies(ped), "TESTSP")
})

test_that("firstPedigreeSpecies skips empty and whitespace-only species", {
  ped <- data.frame(
    id = c("A", "B", "C"),
    species = c("", "   ", "MULATTA"),
    stringsAsFactors = FALSE
  )
  expect_identical(firstPedigreeSpecies(ped), "MULATTA")
})

test_that("firstPedigreeSpecies returns NA when all species are NA or empty", {
  ped <- data.frame(
    id = c("A", "B"),
    species = c(NA, ""),
    stringsAsFactors = FALSE
  )
  expect_identical(firstPedigreeSpecies(ped), NA_character_)
})

test_that("firstPedigreeSpecies returns NA when there is no species column", {
  ped <- data.frame(
    id = c("A", "B"),
    sex = c("M", "F"),
    stringsAsFactors = FALSE
  )
  expect_identical(firstPedigreeSpecies(ped), NA_character_)
})

test_that("firstPedigreeSpecies returns NA for NULL or a non-data.frame", {
  expect_identical(firstPedigreeSpecies(NULL), NA_character_)
  expect_identical(firstPedigreeSpecies("not a data.frame"), NA_character_)
})

# =============================================================================
# pedigreeGestationDefault() - pure helper: species -> gestation default.
# An injected gestationTable makes differentiation testable (the shipped
# RHESUS-only table collapses every species to the 210 fallback, so a test
# against it would false-GREEN against an ignores-species implementation).
# =============================================================================

# RHESUS keeps 210; TESTSP is a distinct, non-default value (90).
testGestTable <- data.frame(
  species = c("RHESUS", "TESTSP"),
  gestation = c(210L, 90L),
  stringsAsFactors = FALSE
)

test_that("pedigreeGestationDefault exists", {
  expect_true(exists("pedigreeGestationDefault"))
})

test_that("pedigreeGestationDefault keys the default on the pedigree species", {
  ped <- data.frame(
    id = c("A", "B"),
    species = c("TESTSP", "TESTSP"),
    stringsAsFactors = FALSE
  )
  expect_identical(
    pedigreeGestationDefault(ped, gestationTable = testGestTable), 90L
  )
})

test_that("pedigreeGestationDefault returns 210 for RHESUS", {
  ped <- data.frame(
    id = c("A", "B"),
    species = c("RHESUS", "RHESUS"),
    stringsAsFactors = FALSE
  )
  expect_identical(
    pedigreeGestationDefault(ped, gestationTable = testGestTable), 210L
  )
})

test_that("pedigreeGestationDefault falls back to 210 with no species column", {
  ped <- data.frame(
    id = c("A", "B"),
    sex = c("M", "F"),
    stringsAsFactors = FALSE
  )
  expect_identical(
    pedigreeGestationDefault(ped, gestationTable = testGestTable), 210L
  )
})

test_that("pedigreeGestationDefault falls back to 210 when species are all NA", {
  ped <- data.frame(
    id = c("A", "B"),
    species = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  expect_identical(
    pedigreeGestationDefault(ped, gestationTable = testGestTable), 210L
  )
})

test_that("pedigreeGestationDefault returns a single integer", {
  ped <- data.frame(
    id = "A", species = "TESTSP", stringsAsFactors = FALSE
  )
  out <- pedigreeGestationDefault(ped, gestationTable = testGestTable)
  expect_true(is.integer(out))
  expect_length(out, 1L)
})

test_that("pedigreeGestationDefault uses the bundled table when none supplied", {
  ped <- data.frame(
    id = "A", species = "RHESUS", stringsAsFactors = FALSE
  )
  expect_identical(pedigreeGestationDefault(ped), 210L)
})

# =============================================================================
# prefillGuardAllows() - pure helper: the override guard (the documented
# 'dragon'). A prefill is allowed only when the user has NOT manually edited
# the value (current is unset, or still equal to the last value we set).
# =============================================================================

test_that("prefillGuardAllows exists", {
  expect_true(exists("prefillGuardAllows"))
})

test_that("prefillGuardAllows allows prefill when current is NULL or NA", {
  expect_true(prefillGuardAllows(NULL, 210L))
  expect_true(prefillGuardAllows(NA_integer_, 210L))
})

test_that("prefillGuardAllows allows prefill when current equals the last auto value", {
  expect_true(prefillGuardAllows(210L, 210L))
  expect_true(prefillGuardAllows(90L, 90L))
})

test_that("prefillGuardAllows blocks prefill when the user has edited the value", {
  expect_false(prefillGuardAllows(150L, 210L))
  expect_false(prefillGuardAllows(90L, 210L))
})

# =============================================================================
# modPotentialParentsServer() - the species-keyed prefill, end to end.
# =============================================================================

test_that("modPotentialParentsServer exposes a gestationDefault reactive", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B"),
    sire = c(NA, NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    species = c("RHESUS", "RHESUS"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped), minSireAge = 2, minDamAge = 2),
    {
      result <- session$getReturned()
      expect_true("gestationDefault" %in% names(result))
      expect_true(is.function(result$gestationDefault))
    }
  )
})

test_that("modPotentialParentsServer gestationDefault keys on the pedigree species", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B"),
    sire = c(NA, NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    species = c("TESTSP", "TESTSP"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(
      pedigree = shiny::reactive(ped), minSireAge = 2, minDamAge = 2,
      gestationTable = testGestTable
    ),
    {
      expect_identical(session$getReturned()$gestationDefault(), 90L)
    }
  )
})

test_that("modPotentialParentsServer gestationDefault falls back to 210 without species", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B"),
    sire = c(NA, NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(
      pedigree = shiny::reactive(ped), minSireAge = 2, minDamAge = 2,
      gestationTable = testGestTable
    ),
    {
      expect_identical(session$getReturned()$gestationDefault(), 210L)
    }
  )
})

test_that("modPotentialParentsServer does not clobber a user's manual value on pedigree re-fire", {
  skip_if_not_installed("shiny")

  pedA <- data.frame(
    id = c("A", "B"),
    sire = c(NA, NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    species = c("TESTSP", "TESTSP"),
    stringsAsFactors = FALSE
  )
  pedB <- data.frame(
    id = c("C", "D"),
    sire = c(NA, NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    species = c("TESTSP", "TESTSP"),
    stringsAsFactors = FALSE
  )
  pedVal <- shiny::reactiveVal(pedA)

  shiny::testServer(
    modPotentialParentsServer,
    args = list(
      pedigree = pedVal, minSireAge = 2, minDamAge = 2, gestationTable = testGestTable
    ),
    {
      # User manually overrides the prefilled default.
      session$setInputs(maxGestationalPeriod = 150)
      session$flushReact()
      # A new pedigree loads (re-fires the pedigree reactive).
      pedVal(pedB)
      session$flushReact()
      # The guard exercised the skip branch; the default still computes.
      expect_identical(session$getReturned()$gestationDefault(), 90L)
    }
  )
})

# =============================================================================
# Issue #73 Part 2 Slice 2 - user-configurable gestation override reaches the
# Potential Parents prefill. The merged override table (a user CSV merged onto
# the bundled speciesGestation by loadSpeciesOverrides) supplies per-species
# gestation values; gestationDefault supplies the absent-species fallback. Both
# are loaded once at boot (shared$speciesOverrides) and passed to the module.
# Scope is the prefill default only (D5); the computed window is unchanged.
# =============================================================================

# RHESUS overridden to a distinct, non-default value (999); TESTSP stays 90.
overGestTable <- data.frame(
  species = c("RHESUS", "TESTSP"),
  gestation = c(999L, 90L),
  stringsAsFactors = FALSE
)

test_that("pedigreeGestationDefault honors a custom gestationDefault for a species-less pedigree", {
  ped <- data.frame(
    id = c("A", "B"),
    sex = c("M", "F"),
    stringsAsFactors = FALSE
  )
  expect_identical(
    pedigreeGestationDefault(ped, gestationTable = testGestTable,
                             gestationDefault = 300L),
    300L
  )
})

test_that("pedigreeGestationDefault honors a custom gestationDefault for a species absent from the table", {
  ped <- data.frame(
    id = c("A", "B"),
    species = c("UNICORN", "UNICORN"),
    stringsAsFactors = FALSE
  )
  expect_identical(
    pedigreeGestationDefault(ped, gestationTable = testGestTable,
                             gestationDefault = 300L),
    300L
  )
})

test_that("pedigreeGestationDefault with gestationDefault omitted falls to the built-in 210 (R2)", {
  # Backward-compat guard: a bare NULL must NOT be threaded into the accessor's
  # default (rep(NULL, n) empties); omitting it leaves the built-in 210.
  ped <- data.frame(
    id = c("A", "B"),
    species = c("UNICORN", "UNICORN"),
    stringsAsFactors = FALSE
  )
  expect_identical(
    pedigreeGestationDefault(ped, gestationTable = testGestTable),
    210L
  )
})

test_that("modPotentialParentsServer honors a custom gestationDefault for a species-less pedigree", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B"),
    sire = c(NA, NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(
      pedigree = shiny::reactive(ped), minSireAge = 2, minDamAge = 2,
      gestationTable = testGestTable, gestationDefault = 300L
    ),
    {
      expect_identical(session$getReturned()$gestationDefault(), 300L)
    }
  )
})

test_that("modPotentialParentsServer override gestationTable drives the prefill (Slice 2 end-to-end)", {
  skip_if_not_installed("shiny")

  ped <- data.frame(
    id = c("A", "B"),
    sire = c(NA, NA),
    dam = c(NA, NA),
    sex = c("M", "F"),
    species = c("RHESUS", "RHESUS"),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modPotentialParentsServer,
    args = list(
      pedigree = shiny::reactive(ped), minSireAge = 2, minDamAge = 2,
      gestationTable = overGestTable
    ),
    {
      expect_identical(session$getReturned()$gestationDefault(), 999L)
    }
  )
})

test_that("appServer wires the override gestationTable and gestationDefault into the Potential Parents module", {
  src <- paste(deparse(appServer), collapse = "\n")
  expect_match(src, "speciesOverrides$gestationTable", fixed = TRUE)
  expect_match(src, "speciesOverrides$gestationDefault", fixed = TRUE)
})
