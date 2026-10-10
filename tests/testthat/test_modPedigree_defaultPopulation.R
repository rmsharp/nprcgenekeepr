## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:65-82 (found S938, ruled by the owner S954): with no focal animals
## entered, the Pedigree Browser flagged every animal ever recorded as "the
## population", so the Genetic Value tab ranked the dead and shipped along with
## the living (3,694 animals; the 332 living were labelled 55 High / 272 Low in
## one real-app run, 271 High / 56 Low among themselves). The owner ruled: with
## no focal animals the population is the living animals, judged by the
## internal isLivingAnimal() (status first, else no exit date, else everyone).
## Settled at Pre-RED (S955): a pedigree with nobody alive still flags every
## animal (the Genetic Value tab's own fallback, R/modGeneticValue.R:306-310).
## The exported setPopulation() is untouched: an empty ids still flags everyone.
##
## The guards that pass before the change (nobody alive, focal animals win,
## nothing trimmed, setPopulation()) pin what a plausible wrong fix would
## break, e.g. setting the column straight from isLivingAnimal().

# Slow shiny-module integration tests (testServer() calls); skip on CRAN like
# test_modPedigree_processing.R. They still run on CI and locally.
testthat::skip_on_cran()

animals <- c("A", "B", "C", "D", "E", "F")

## Six animals, three generations; extra columns (status, exit) go on as named.
studbookWith <- function(...) {
  ped <- data.frame(
    id = animals,
    sire = c(NA, NA, "A", "A", "B", "C"),
    dam = c(NA, NA, "B", "B", NA, "D"),
    sex = c("M", "F", "F", "M", "F", "M"),
    gen = c(0L, 0L, 1L, 1L, 1L, 2L),
    stringsAsFactors = FALSE
  )
  extra <- list(...)
  for (column in names(extra)) ped[[column]] <- extra[[column]]
  ped
}

## Drive the Pedigree Browser module the way the existing processing tests do
## and hand back what it returned. `withFocalText` is typed into the Focal
## Animals box and Update pressed; `thenClear` ticks Clear and presses Update.
runBrowser <- function(studbook, withFocalText = NULL, thenClear = FALSE,
                       trimBox = FALSE) {
  seen <- new.env()
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ studbook })),
    {
      session$setInputs(
        displayUnknownIds = TRUE,
        trimPedigree = trimBox,
        clearFocalAnimals = FALSE,
        focalAnimalIds = ""
      )
      if (!is.null(withFocalText)) {
        session$setInputs(focalAnimalIds = withFocalText)
        session$setInputs(updateFocalAnimals = 1)
      }
      if (thenClear) {
        session$setInputs(clearFocalAnimals = TRUE)
        session$setInputs(updateFocalAnimals = 2)
      }
      result <- session$getReturned()
      seen$processed <- result$processedPedigree()
      seen$count <- result$populationCount()
      seen$focal <- result$focalAnimals()
      seen$display <- result$pedigree()
      seen$analysis <- result$analysisPedigree()
    }
  )
  seen
}

flaggedIds <- function(seen) {
  seen$processed$id[seen$processed$population]
}

## A, C and F are alive; B is dead, D has no status, E is unknown.
mixedStatus <- c("ALIVE", "DEAD", "ALIVE", NA, "UNKNOWN", "ALIVE")

test_that("with no focal animals a status column flags only the ALIVE animals", {
  skip_if_not_installed("shiny")
  seen <- runBrowser(studbookWith(status = mixedStatus))
  expect_setequal(flaggedIds(seen), c("A", "C", "F"))
  expect_false(anyNA(seen$processed$population))
})

test_that("with no focal animals and no status column an animal with no exit date is flagged", {
  skip_if_not_installed("shiny")
  exit <- as.Date(c(NA, "2020-01-01", NA, "2021-05-05", NA, NA))
  seen <- runBrowser(studbookWith(exit = exit))
  expect_setequal(flaggedIds(seen), c("A", "C", "E", "F"))
})

test_that("a status column alone decides who is alive, whatever the exit date says", {
  skip_if_not_installed("shiny")
  ## B is DEAD with no exit date and D is UNKNOWN with none: neither is alive.
  ## C is ALIVE with an exit date: alive. F is DEAD with one: not alive.
  status <- c("ALIVE", "DEAD", "ALIVE", "UNKNOWN", "ALIVE", "DEAD")
  exit <- as.Date(c(NA, NA, "2022-02-02", NA, NA, "2019-01-01"))
  seen <- runBrowser(studbookWith(status = status, exit = exit))
  expect_setequal(flaggedIds(seen), c("A", "C", "E"))
})

test_that("with a status column and nobody ALIVE every animal is flagged", {
  skip_if_not_installed("shiny")
  status <- c("DEAD", "SHIPPED", "DEAD", "UNKNOWN", "DEAD", NA)
  seen <- runBrowser(studbookWith(status = status))
  expect_setequal(flaggedIds(seen), animals)
})

test_that("with an exit column and every animal gone every animal is flagged", {
  skip_if_not_installed("shiny")
  exit <- as.Date("2020-01-01") + 0:5
  seen <- runBrowser(studbookWith(exit = exit))
  expect_setequal(flaggedIds(seen), animals)
})

test_that("focal animals entered win over the living default, dead ones included", {
  skip_if_not_installed("shiny")
  ## A, B and E are alive; C is dead and D shipped, yet only C and D are focal.
  status <- c("ALIVE", "ALIVE", "DEAD", "SHIPPED", "ALIVE", "DEAD")
  seen <- runBrowser(studbookWith(status = status), withFocalText = "C, D")
  expect_setequal(flaggedIds(seen), c("C", "D"))
  expect_setequal(seen$focal, c("C", "D"))
})

test_that("clearing the focal animals goes back to the living animals", {
  skip_if_not_installed("shiny")
  ## B is dead: if Clear left it focal it would be the only animal flagged.
  status <- c("ALIVE", "DEAD", "ALIVE", "DEAD", "DEAD", "ALIVE")
  seen <- runBrowser(studbookWith(status = status), withFocalText = "B",
                     thenClear = TRUE)
  expect_identical(seen$focal, character(0L))
  expect_setequal(flaggedIds(seen), c("A", "C", "F"))
})

test_that("populationCount counts the living animals when no focal animals are entered", {
  skip_if_not_installed("shiny")
  seen <- runBrowser(studbookWith(status = mixedStatus))
  expect_equal(seen$count, 3L)
})

test_that("the living default is not a focal selection: nothing is trimmed and no focal animals are reported", {
  skip_if_not_installed("shiny")
  ## Trim is ticked, but trimming follows the focal animals only.
  seen <- runBrowser(studbookWith(status = mixedStatus), trimBox = TRUE)
  expect_identical(seen$focal, character(0L))
  expect_equal(nrow(seen$display), length(animals))
  expect_equal(nrow(seen$analysis), length(animals))
})

test_that("setPopulation() still flags every animal when given no IDs, status column or not", {
  ped <- studbookWith(status = mixedStatus)
  expect_true(all(setPopulation(ped, character(0L))$population))
  expect_true(all(setPopulation(ped, NULL)$population))
  expect_setequal(
    ped$id[setPopulation(ped, c("B", "D"))$population], c("B", "D")
  )
})
