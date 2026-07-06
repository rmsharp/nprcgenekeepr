## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## Tests for modGeneticDiversity (issue #112 Slice S4): the Shiny module that
## assembles live breeding-group / genetic-value / kinship reactives, calls the
## S3 assembler getGeneticDiversityStats(), and renders the S1 heat map. The
## server takes plain reactives plus a currentDate (default Sys.Date()) so the
## tests can pin the date and reuse the S3 assembler's deterministic fixture
## (currentDate 2020-07-01 -> production birth window 2018-2019).

currentDate <- as.Date("2020-07-01")

## Same kinship-matrix idiom as the S2/S3 fixtures: off-diagonal pairs start
## "related" (0.25 > 0.015625), the diagonal is 0.5, and each `unrelated` pair
## is set symmetrically to 0.
makeKmat <- function(ids, unrelated = list()) {
  kmat <- matrix(0.25, nrow = length(ids), ncol = length(ids),
                 dimnames = list(ids, ids))
  diag(kmat) <- 0.5
  for (pair in unrelated) {
    kmat[pair[1L], pair[2L]] <- 0
    kmat[pair[2L], pair[1L]] <- 0
  }
  kmat
}

ped <- data.frame(
  id = c("f1", "f2", "m1", "o1", "o2",
         "c1", "c2", "c3", "cm", "co",
         "h1", "h2", "ho"),
  sire = NA_character_,
  dam = NA_character_,
  sex = c("F", "F", "M", "M", "F",
          "F", "F", "F", "M", "M",
          "F", "F", "M"),
  birth = as.Date(c(
    "2008-01-01", "2009-01-01", "2005-01-01", "2018-06-01", "2019-02-01",
    "2008-01-01", "2009-01-01", "2010-01-01", "2004-01-01", "2018-06-01",
    "2008-01-01", "2009-01-01", "2018-06-01")),
  exit = as.Date(c(
    NA, NA, NA, "2019-06-01", "2019-12-01",
    NA, NA, NA, NA, "2019-06-01",
    NA, NA, "2019-06-01")),
  ancestry = c(
    "INDIAN", "INDIAN", "INDIAN", "INDIAN", "INDIAN",
    "CHINESE", "INDIAN", "INDIAN", "INDIAN", "INDIAN",
    "INDIAN", "INDIAN", "INDIAN"),
  stringsAsFactors = FALSE
)

gv <- data.frame(
  id = ped$id,
  value = c(
    "High Value", "High Value", "High Value", "High Value", "High Value",
    "Low Value", "Low Value", "Low Value", "High Value", "High Value",
    "High Value", "High Value", "High Value"),
  stringsAsFactors = FALSE
)

## Only the green group's two females are unrelated to its single adult male.
kmat <- makeKmat(ped$id, list(c("f1", "m1"), c("f2", "m1")))

g1 <- c("f1", "f2", "m1", "o1", "o2")   # all-green group
g2 <- c("c1", "c2", "c3", "cm", "co")   # all-red group
gH <- c("h1", "h2", "ho")               # 2 dams, 1 offspring -> production 0.5

## ---- UI ----------------------------------------------------------------

test_that("modGeneticDiversityUI returns a shiny.tag object", {
  ui <- modGeneticDiversityUI("test")
  expect_true(inherits(ui, "shiny.tag"))
})

test_that("modGeneticDiversityUI shows the Genetic Diversity heading", {
  ui_html <- as.character(modGeneticDiversityUI("test"))
  expect_true(grepl("Genetic Diversity", ui_html))
})

test_that("modGeneticDiversityUI exposes namespaced heatmap/housing/guidance", {
  ui_html <- as.character(modGeneticDiversityUI("gdNS"))
  expect_true(grepl("gdNS-heatmap", ui_html))
  expect_true(grepl("gdNS-housing", ui_html))
  expect_true(grepl("gdNS-guidance", ui_html))
})

test_that("modGeneticDiversityUI marks the container for E2E readiness", {
  ui_html <- as.character(modGeneticDiversityUI("test"))
  expect_true(grepl("test-moduleContainer", ui_html))
  expect_true(grepl("data-module", ui_html))
  expect_true(grepl("geneticDiversity", ui_html))
  expect_true(grepl("data-ready", ui_html))
})

test_that("modGeneticDiversityUI housing selector offers both housing types", {
  ui_html <- as.character(modGeneticDiversityUI("test"))
  expect_true(grepl("shelter_pens", ui_html))
  expect_true(grepl("corral", ui_html))
})

## ---- Server: return contract ------------------------------------------

test_that("modGeneticDiversityServer returns reactive stats + heatmap", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list(g1, g2) }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      result <- session$getReturned()
      expect_true(is.list(result))
      expect_true("stats" %in% names(result))
      expect_true("heatmap" %in% names(result))
      expect_true(is.function(result$stats))
      expect_true(is.function(result$heatmap))
    }
  )
})

## ---- Server: happy path -----------------------------------------------

test_that("modGeneticDiversityServer assembles a colorIndex stats frame", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list(g1, g2) }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      result <- session$getReturned()
      session$setInputs(housing = "shelter_pens")
      stats <- result$stats()
      expect_s3_class(stats, "data.frame")
      expect_identical(nrow(stats), 2L)
      expect_true("group" %in% names(stats))
      expect_true(all(unlist(stats[-1L]) %in% c(1L, 2L, 3L)))
    }
  )
})

test_that("modGeneticDiversityServer heatmap is a ggplot geom_tile", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("ggplot2")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list(g1, g2) }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      result <- session$getReturned()
      session$setInputs(housing = "shelter_pens")
      p <- result$heatmap()
      expect_s3_class(p, "ggplot")
      layer_classes <- sapply(p$layers, function(l) class(l$geom)[1L])
      expect_true("GeomTile" %in% layer_classes)
    }
  )
})

## ---- Server: housing input --------------------------------------------

test_that("modGeneticDiversityServer defaults housing when input is unset", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list(g1) }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      ## No session$setInputs(housing = ...): input$housing is NULL and the
      ## module must fall back to "shelter_pens" rather than error.
      result <- session$getReturned()
      expect_no_error(result$stats())
      expect_false(is.null(result$stats()))
    }
  )
})

test_that("modGeneticDiversityServer threads the housing input through", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list(gH) }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      ## gH production = 0.5: shelter_pens -> red (1), corral -> yellow (2).
      result <- session$getReturned()
      session$setInputs(housing = "shelter_pens")
      expect_identical(result$stats()$Production, 1L)
      session$setInputs(housing = "corral")
      expect_identical(result$stats()$Production, 2L)
    }
  )
})

## ---- Server: graceful degradation -------------------------------------

test_that("modGeneticDiversityServer shows guidance when no groups formed", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ NULL }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      result <- session$getReturned()
      expect_null(result$stats())
      expect_null(result$heatmap())
      html <- as.character(output$guidance)
      expect_true(any(grepl("Form breeding groups", html)))
    }
  )
})

test_that("modGeneticDiversityServer treats an empty group list as no data", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list() }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      result <- session$getReturned()
      expect_null(result$stats())
    }
  )
})

test_that("modGeneticDiversityServer shows guidance before analysis is run", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list(g1) }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ NULL }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      result <- session$getReturned()
      expect_null(result$stats())
      html <- as.character(output$guidance)
      expect_true(any(grepl("Form breeding groups", html)))
    }
  )
})

test_that("modGeneticDiversityServer waits for the kinship matrix", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list(g1) }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ NULL }),
      currentDate = currentDate
    ),
    {
      result <- session$getReturned()
      expect_null(result$stats())
    }
  )
})

test_that("modGeneticDiversityServer hides guidance once data is present", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modGeneticDiversityServer,
    args = list(
      groups = shiny::reactive({ list(g1, g2) }),
      pedigree = shiny::reactive({ ped }),
      geneticValues = shiny::reactive({ gv }),
      kinshipMatrix = shiny::reactive({ kmat }),
      currentDate = currentDate
    ),
    {
      result <- session$getReturned()
      session$setInputs(housing = "shelter_pens")
      html <- as.character(output$guidance)
      expect_false(any(grepl("Form breeding groups", html)))
    }
  )
})
