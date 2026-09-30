## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# Unticking "Display Unknown IDs" only filters the Pedigree Browser table
# (BACKLOG item found S806, owner decision S814, option 1). Before, the
# filtered pedigree was what every tab received, so with the box unticked the
# children of a hidden stand-in still named it as sire or dam and the Genetic
# Value analysis stopped with "sire and dam must have had alleles assigned".
# modPedigreeServer() now also returns `analysisPedigree`: the pedigree the
# other tabs analyze. It is the full pedigree (the focal-animal trim still
# applies, since that is a deliberate narrowing), whatever the box says.
library(testthat)

## U1234 is a real sire marked FALSE; U0001 is a made-up stand-in marked TRUE
## and is K2's sire, so hiding it leaves K2 naming a parent that is not in the
## table; Xq9 is a stand-in whose id does not look like one, K3's sire; U0002
## is an unmarked row that looks like a stand-in.
makeDownstreamPed <- function() {
  data.frame(
    id = c("U1234", "U0001", "Xq9", "U0002", "D1", "K1", "K2", "K3"),
    sire = c(NA, NA, NA, NA, NA, "U1234", "U0001", "Xq9"),
    dam = c(NA, NA, NA, NA, NA, "D1", "D1", "D1"),
    sex = c("M", "M", "M", "M", "F", "F", "M", "F"),
    birth = as.Date("2000-01-01") + c(0, 0, 0, 0, 0, 900, 950, 1000),
    placeholder = c(FALSE, TRUE, TRUE, NA, FALSE, FALSE, FALSE, FALSE),
    stringsAsFactors = FALSE
  )
}

## Both pedigrees the module hands back, for one setting of the boxes.
pedigreesFor <- function(ped, displayUnknownIds, trim = FALSE, focal = "") {
  got <- new.env()
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive(ped)),
    {
      session$setInputs(displayUnknownIds = displayUnknownIds,
                        trimPedigree = trim,
                        clearFocalAnimals = FALSE,
                        focalAnimalIds = focal)
      session$setInputs(updateFocalAnimals = 1)
      returned <- session$getReturned()
      got$names <- names(returned)
      got$shown <- returned$pedigree()
      got$analysis <- if (is.null(returned$analysisPedigree)) {
        NULL
      } else {
        returned$analysisPedigree()
      }
    }
  )
  as.list(got)
}

namesParents <- function(ped) {
  parents <- c(ped$sire, ped$dam)
  unique(parents[!is.na(parents)])
}

test_that("modPedigreeServer returns an analysisPedigree reactive", {
  skip_if_not_installed("shiny")
  got <- pedigreesFor(makeDownstreamPed(), displayUnknownIds = FALSE)
  expect_true("analysisPedigree" %in% got$names)
})

test_that("with the box unticked the analysis pedigree still has every row", {
  skip_if_not_installed("shiny")
  ped <- makeDownstreamPed()
  got <- pedigreesFor(ped, displayUnknownIds = FALSE)
  expect_s3_class(got$analysis, "data.frame")
  expect_setequal(got$analysis$id, ped$id)
})

test_that("with the box unticked no child in the analysis pedigree names a missing parent", {
  skip_if_not_installed("shiny")
  got <- pedigreesFor(makeDownstreamPed(), displayUnknownIds = FALSE)
  expect_s3_class(got$analysis, "data.frame")
  expect_true(all(namesParents(got$analysis) %in% got$analysis$id))
})

test_that("the table is still filtered when the box is unticked (guard)", {
  skip_if_not_installed("shiny")
  got <- pedigreesFor(makeDownstreamPed(), displayUnknownIds = FALSE)
  expect_setequal(got$shown$id, c("U1234", "D1", "K1", "K2", "K3"))
})

test_that("the analysis pedigree is the same whether the box is ticked or not", {
  skip_if_not_installed("shiny")
  ped <- makeDownstreamPed()
  ticked <- pedigreesFor(ped, displayUnknownIds = TRUE)
  unticked <- pedigreesFor(ped, displayUnknownIds = FALSE)
  expect_s3_class(unticked$analysis, "data.frame")
  expect_identical(unticked$analysis, ticked$analysis)
})

test_that("with the box ticked the analysis pedigree equals the table", {
  skip_if_not_installed("shiny")
  got <- pedigreesFor(makeDownstreamPed(), displayUnknownIds = TRUE)
  expect_s3_class(got$analysis, "data.frame")
  expect_identical(got$analysis, got$shown)
})

test_that("the focal-animal trim still narrows the analysis pedigree, and keeps a stand-in ancestor", {
  skip_if_not_installed("shiny")
  got <- pedigreesFor(makeDownstreamPed(), displayUnknownIds = FALSE,
                      trim = TRUE, focal = "K2")
  expect_s3_class(got$analysis, "data.frame")
  ## K2's ancestors are its sire (the stand-in U0001) and its dam D1
  expect_setequal(got$analysis$id, c("K2", "U0001", "D1"))
  expect_true(all(namesParents(got$analysis) %in% got$analysis$id))
})

test_that("the table's own trim is unchanged: the stand-in is hidden before the trim (guard)", {
  skip_if_not_installed("shiny")
  got <- pedigreesFor(makeDownstreamPed(), displayUnknownIds = FALSE,
                      trim = TRUE, focal = "K2")
  expect_false("U0001" %in% got$shown$id)
  expect_true(all(c("K2", "D1") %in% got$shown$id))
})
