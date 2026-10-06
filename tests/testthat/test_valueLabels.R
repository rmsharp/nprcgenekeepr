## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)

# S920: rankSubjects() gives every animal one of three genetic-value labels, and
# five other places compare against them (summary() counts "High Value" and
# "Low Value", the breeding-group value floor drops "Low Value",
# modGeneticValueServer() ranks "Undetermined" last, getGeneticDiversityStats()
# leaves "Undetermined" out) plus getProportionLow(), which counts "Low Value".
# All six read the labels from one internal list, valueLabels, so a label cannot
# change in one place and silently stop matching in the others.

expectedLabels <- c(
  lowValue = "Low Value",
  highValue = "High Value",
  undetermined = "Undetermined"
)
# three labels none of which is a real label and none of which contains "Low"
swappedLabels <- c(lowValue = "Tier L", highValue = "Tier H",
                   undetermined = "Tier U")
# what a value is called once the list holds the swapped labels
relabel <- function(x) unname(swappedLabels[match(x, expectedLabels)])

test_that("valueLabels holds the three labels, named by what they mean", {
  expect_identical(valueLabels, expectedLabels)
})

test_that("rankSubjects() takes its three labels from the list", {
  testthat::local_mocked_bindings(
    valueLabels = swappedLabels,
    .package = "nprcgenekeepr"
  )
  tiers <- list(
    highGu = data.frame(id = c("a1", "a2"), stringsAsFactors = FALSE),
    noParentage = data.frame(id = c("n1", "n2"), stringsAsFactors = FALSE),
    lowVal = data.frame(id = "l1", stringsAsFactors = FALSE)
  )
  out <- rankSubjects(tiers)
  expect_identical(out$highGu$value, c("Tier H", "Tier H"))
  expect_identical(out$noParentage$value, c("Tier U", "Tier U"))
  expect_identical(out$lowVal$value, "Tier L")
})

test_that("summary() counts the High and Low Value individuals by the list's labels", {
  gv <- nprcgenekeepr::qcPedGvReport
  # control, before any swap: the counts the bundled report really has
  expectedTxt <- unclass(summary(gv))
  expect_identical(
    expectedTxt[grepl("Value Individuals:", expectedTxt)],
    c("High Value Individuals: 35", "Low Value Individuals: 121")
  )
  gvSwapped <- gv
  gvSwapped$report$value <- relabel(gv$report$value)
  testthat::local_mocked_bindings(
    valueLabels = swappedLabels,
    .package = "nprcgenekeepr"
  )
  expect_identical(unclass(summary(gvSwapped)), expectedTxt)
})

# four animals of one group: u1 is Low, u2 is High, u3 and u4 are Undetermined
# (the same group test_getGeneticDiversityStats.R uses for its denominator test)
groupIds <- c("u1", "u2", "u3", "u4")
groupPed <- data.frame(
  id = groupIds,
  sire = NA_character_,
  dam = NA_character_,
  sex = c("F", "F", "F", "M"),
  birth = as.Date(c("2008-01-01", "2009-01-01", "2010-01-01", "2005-01-01")),
  exit = as.Date(NA),
  stringsAsFactors = FALSE
)
groupKmat <- matrix(0.25, nrow = 4L, ncol = 4L,
                    dimnames = list(groupIds, groupIds))
diag(groupKmat) <- 0.5
groupValues <- c("Low Value", "High Value", "Undetermined", "Undetermined")
groupDate <- as.Date("2020-07-01")

test_that("getGeneticDiversityStats() leaves out the list's Undetermined label", {
  # control, before any swap: 1 Low of the 2 assessed = 0.5 = yellow (2)
  control <- getGeneticDiversityStats(
    list(groupIds), groupPed,
    data.frame(id = groupIds, value = groupValues, stringsAsFactors = FALSE),
    groupKmat, currentDate = groupDate
  )
  expect_identical(control$Value, 2L)
  testthat::local_mocked_bindings(
    valueLabels = swappedLabels,
    .package = "nprcgenekeepr"
  )
  swapped <- getGeneticDiversityStats(
    list(groupIds), groupPed,
    data.frame(id = groupIds, value = relabel(groupValues),
               stringsAsFactors = FALSE),
    groupKmat, currentDate = groupDate
  )
  expect_identical(swapped$Value, 2L)
})

test_that("getProportionLow() counts the list's Low Value label and no other", {
  testthat::local_mocked_bindings(
    valueLabels = swappedLabels,
    .package = "nprcgenekeepr"
  )
  # one of two is the list's Low label: 0.5 = yellow (2)
  expect_identical(
    getProportionLow(c("Tier L", "Tier H")),
    list(proportion = 0.5, color = "yellow", colorIndex = 2L)
  )
  # the old labels are no longer Low Value, whatever they contain
  expect_identical(
    getProportionLow(c("Low Value", "High Value")),
    list(proportion = 0, color = "green", colorIndex = 3L)
  )
})

test_that("the breeding-group value floor drops the list's Low Value label", {
  skip_if_not_installed("shiny")
  testthat::local_mocked_bindings(
    valueLabels = swappedLabels,
    .package = "nprcgenekeepr"
  )
  test_ped <- data.frame(
    id = paste0("Animal", 1:8),
    sire = rep(NA, 8),
    dam = rep(NA, 8),
    sex = rep(c("M", "F"), 4),
    stringsAsFactors = FALSE
  )
  # the same eight values test_modBreedingGroups.R uses for its value-floor test
  test_gv <- data.frame(
    id = paste0("Animal", 1:8),
    value = relabel(c("High Value", "High Value", "Low Value", "Low Value",
                      "Undetermined", "Undetermined", "High Value",
                      "Low Value")),
    stringsAsFactors = FALSE
  )

  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ test_ped }),
      geneticValues = shiny::reactive({ test_gv })
    ),
    {
      session$setInputs(
        animalSource = "topRanked",
        inclusionCriterion = "valueFloor",
        nTopAnimals = 2, # deliberately small: must be IGNORED under valueFloor
        nGroups = 1,
        maxKinship = 0.25,
        sexRatio = "none"
      )
      session$setInputs(formGroups = 1)

      result <- session$getReturned()
      allCandidates <- sort(c(unlist(result$groups()), result$unassigned()))

      expect_setequal(
        allCandidates,
        c("Animal1", "Animal2", "Animal5", "Animal6", "Animal7")
      )
    }
  )
})

test_that("modGeneticValueServer() ranks the list's Undetermined animals last", {
  skip_on_cran()
  skip_if_not_installed("shiny")
  testthat::local_mocked_bindings(
    valueLabels = swappedLabels,
    .package = "nprcgenekeepr"
  )
  # 6 founders (both parents unknown, each with offspring) and 12 offspring of
  # known parents, as test_modGeneticValue.R builds for its demotion test
  founders <- data.frame(
    id = paste0("F", 1:6),
    sire = NA_character_,
    dam = NA_character_,
    sex = c(rep("M", 3L), rep("F", 3L)),
    stringsAsFactors = FALSE
  )
  offspring <- data.frame(
    id = paste0("O", 1:12),
    sire = rep(founders$id[founders$sex == "M"], length.out = 12L),
    dam = rep(founders$id[founders$sex == "F"], length.out = 12L),
    sex = rep(c("M", "F"), length.out = 12L),
    stringsAsFactors = FALSE
  )
  test_ped <- rbind(founders, offspring)

  shiny::testServer(
    modGeneticValueServer,
    args = list(
      pedigree = shiny::reactive({ test_ped })
    ),
    {
      session$setInputs(nIterations = 100)
      session$setInputs(runAnalysis = 1)

      results <- gvResults()
      founderIds <- test_ped$id[is.na(test_ped$sire) & is.na(test_ped$dam)]
      nFounders <- length(founderIds)

      # every founder sits in the bottom nFounders ranks, none in the top block
      expect_true(all(results$rank[results$id %in% founderIds] >
        (nrow(results) - nFounders)))
    }
  )
})
