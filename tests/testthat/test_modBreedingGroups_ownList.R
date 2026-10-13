## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

library(testthat)
library(nprcgenekeepr)

## The Breeding Groups tab's third Source choice, "My own list" (S973;
## BACKLOG.md:149, owner-requested S970). The Source box offers "Top ranked"
## and "All available"; a colony manager who already knows which animals to
## consider had no way to say so. "My own list" (value "custom") shows a box,
## "Animal IDs:" (input customAnimalIds), and forms groups from exactly the
## living animals typed or pasted there.
##
## Owner rulings, S973 (every one the recommended option):
##   - a paste box (no file upload);
##   - an id that is not in the pedigree STOPS the run and is named, as a seed
##     id does (R/modBreedingGroups.R:636,670-676): no groups are formed;
##   - an id that is in the pedigree but not alive is LEFT OUT and named, and
##     the groups are formed from the rest;
##   - the ten sentences, word for word (the strings pinned below).
## Decided without a question (it follows the rulings or copies the tab):
## the "Include animals by" box acts as it does for "All available" (Top N
## does nothing, the genetic-value floor still applies); an id typed twice
## counts once; an id that is also in a seed box leaves the pool; unknown ids
## win over dead ids (only the unknown ones are named).
##
## groups() plus unassigned() are the candidate ids that reached
## groupAddAssign() (the same proxy test_modBreedingGroups_livingPool.R uses),
## so their union says which animals were in the pool whatever the stochastic
## group assignment. A blocked run is checked by its empty groups() and its
## notice, not by unassigned().
##
## Blocks that already pass at HEAD are marked "Green-at-HEAD coverage
## (NOT a RED)".

# =============================================================================
# The Source box and the paste box (the page, no server)
# =============================================================================

olUiHtml <- function() {
  gsub("\\s+", " ",
       paste(as.character(modBreedingGroupsUI("bg")), collapse = " "))
}

test_that("the Animal IDs box is a text area with its label and hint, namespaced to the module", {
  html <- olUiHtml()
  from <- regexpr("<textarea id=\"bg-customAnimalIds\"", html, fixed = TRUE)
  expect_gt(as.integer(from), 0L, label = "the Animal IDs text area")
  if (from > 0L) {
    ## the text area and the label that names it
    tag <- substring(html, from, from + 200L)
    expect_match(tag, "placeholder=\"e.g. A1, A2, A3\"", fixed = TRUE)
  }
  expect_equal(occurrences(html,
                           "for=\"bg-customAnimalIds\">Animal IDs:</label>"),
               1L)
})

test_that("the Animal IDs box shows only while My own list is the Source, by an unprefixed condition", {
  html <- olUiHtml()
  conds <- regmatches(
    html, gregexpr("data-display-if=\"[^\"]*\"", html))[[1L]]
  own <- paste0("data-display-if=\"input.animalSource == &#39;custom&#39;\"")
  expect_equal(sum(conds == own), 1L)
  ## ns = ns narrows the client-side scope, so a condition built with ns()
  ## double-prefixes and never matches (Learning 324).
  expect_false(any(grepl("bg-animalSource", conds, fixed = TRUE)))
  ## the text area sits inside that panel: after its condition and before the
  ## next panel's
  panelAt <- as.integer(regexpr(own, html, fixed = TRUE))
  boxAt <- as.integer(regexpr("id=\"bg-customAnimalIds\"", html, fixed = TRUE))
  panels <- as.integer(gregexpr("data-display-if=", html, fixed = TRUE)[[1L]])
  nextPanelAt <- min(c(panels[panels > panelAt], Inf))
  expect_gt(boxAt, panelAt)
  expect_lt(boxAt, nextPanelAt)
})

# =============================================================================
# The module: what My own list forms groups from
# =============================================================================

# Fourteen animals, alternating M / F. A1-A8 are alive; A9-A10 are deceased;
# A11-A12 are shipped; A13-A14 are placeholders (Status UNKNOWN, no exit date).
olPed <- function() {
  status <- c(rep("ALIVE", 8L), "DECEASED", "DECEASED", "SHIPPED", "SHIPPED",
              "UNKNOWN", "UNKNOWN")
  data.frame(
    id = paste0("A", 1:14),
    sire = NA_character_,
    dam = NA_character_,
    sex = rep(c("M", "F"), length.out = 14L),
    birth = as.Date("2015-01-01") - (1:14) * 90L,
    exit = as.Date(c(rep(NA, 8L), rep("2020-06-01", 4L), NA, NA)),
    status = factor(status,
                    levels = c("ALIVE", "DECEASED", "SHIPPED", "UNKNOWN")),
    stringsAsFactors = FALSE
  )
}

# One run of the tab with the given inputs. The notices are recorded (the
# notification call is mocked for the calling test only), and the RNG is
# fixed so a seeded formation is repeatable.
olRun <- function(ped, geneticValues = NULL, ..., env = parent.frame()) {
  notes <- list()
  testthat::local_mocked_bindings(
    showNotification = function(ui, ..., type = "default") {
      notes[[length(notes) + 1L]] <<- list(text = as.character(ui),
                                           type = type)
      invisible("note-id")
    },
    .package = "nprcgenekeepr", .env = env
  )
  out <- NULL
  set.seed(42)
  shiny::testServer(
    modBreedingGroupsServer,
    args = list(
      pedigree = shiny::reactive({ ped }),
      geneticValues = if (is.null(geneticValues)) {
        NULL
      } else {
        shiny::reactive({ geneticValues })
      }
    ),
    {
      session$setInputs(nGroups = 2, maxKinship = 0.25, sexRatio = "none",
                        ...)
      session$setInputs(formGroups = 1)
      result <- session$getReturned()
      out <<- list(
        candidates = sort(c(unlist(result$groups()), result$unassigned())),
        groups = result$groups()
      )
    }
  )
  out$types <- vapply(notes, function(n) n$type, character(1L))
  out$texts <- vapply(notes, function(n) n$text, character(1L))
  out
}

test_that("My own list forms groups from exactly the living animals typed", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A1, A3, A5, A6")

  expect_setequal(got$candidates, c("A1", "A3", "A5", "A6"))
  expect_length(got$texts, 0L)
})

test_that("an animal typed twice, across mixed separators, counts once", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A2;A4\tA2\nA6 A4,A8")

  expect_setequal(got$candidates, c("A2", "A4", "A6", "A8"))
  expect_false(any(duplicated(got$candidates)))
})

test_that("a column pasted from a Windows spreadsheet works, line ends and all", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A1\r\nA2\r\nA3\r\nA4\r\n")

  expect_setequal(got$candidates, c("A1", "A2", "A3", "A4"))
  expect_length(got$texts, 0L)
})

test_that("an id that is not in the pedigree stops the run and is named", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A1, ZZ9, A2, QQ1")

  expect_length(got$groups, 0L)
  expect_identical(got$types, "error")
  expect_identical(got$texts,
                   "Candidate animals not in the pedigree: ZZ9, QQ1")
})

test_that("an id differing only in case is not in the pedigree", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "a1, A2")

  expect_length(got$groups, 0L)
  expect_identical(got$texts, "Candidate animals not in the pedigree: a1")
})

test_that("an unknown id and a dead one together: only the unknown one is named, and nothing forms", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A1, ZZ9, A9")

  expect_length(got$groups, 0L)
  expect_identical(got$types, "error")
  expect_identical(got$texts, "Candidate animals not in the pedigree: ZZ9")
})

test_that("animals that are not alive are left out and named, and the rest form groups", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A1, A2, A9, A3, A11")

  expect_setequal(got$candidates, c("A1", "A2", "A3"))
  expect_identical(got$types, "warning")
  expect_identical(got$texts,
                   "Left out because they are not alive: A9, A11")
})

test_that("with nobody on the list alive the tab says so, in the plural", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A9, A10, A11")

  expect_length(got$groups, 0L)
  expect_identical(got$types, "error")
  expect_identical(
    got$texts,
    "None of the 3 animals in this source is alive, so no breeding groups were formed."
  )
})

test_that("with one animal on the list, and it not alive, the tab says so in the singular, however often it is typed", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A9, A9")

  expect_length(got$groups, 0L)
  expect_identical(got$types, "error")
  expect_identical(
    got$texts,
    "The 1 animal in this source is not alive, so no breeding groups were formed."
  )
})

test_that("a blank, separator-only or untouched box stops the run and asks for an id", {
  skip_on_cran()

  ask <- "Type or paste at least one animal ID into the box, then click Form Groups."
  for (typed in list("", "   ", ", ;\n", NULL)) {
    got <- if (is.null(typed)) {
      olRun(olPed(), animalSource = "custom")
    } else {
      olRun(olPed(), animalSource = "custom", customAnimalIds = typed)
    }
    label <- if (is.null(typed)) "an untouched box" else deparse(typed)
    expect_length(got$groups, 0L)
    expect_identical(got$types, "error", info = label)
    expect_identical(got$texts, ask, info = label)
  }
})

test_that("the genetic-value floor still applies to a typed list", {
  skip_on_cran()

  # A5 and A6 pass the floor but are not on the list; A2 is on it and Low Value.
  gv <- data.frame(
    id = paste0("A", 1:6),
    value = c("High Value", "Low Value", "Undetermined", "High Value",
              "High Value", "High Value"),
    stringsAsFactors = FALSE
  )

  got <- olRun(olPed(), geneticValues = gv, animalSource = "custom",
               customAnimalIds = "A1, A2, A3, A4",
               inclusionCriterion = "valueFloor")

  expect_setequal(got$candidates, c("A1", "A3", "A4"))
})

test_that("Top N does not trim a typed list: every living animal typed is used", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A1, A2, A3, A4, A5, A6",
               inclusionCriterion = "topN", nTopAnimals = 5)

  expect_setequal(got$candidates, paste0("A", 1:6))
})

test_that("an animal typed on the list and in a seed box leaves the pool and starts its group", {
  skip_on_cran()

  got <- olRun(olPed(), animalSource = "custom",
               customAnimalIds = "A1, A2, A3, A4, A5, A6",
               seedGroups = TRUE, curGrp1 = "A1")

  expect_setequal(got$candidates, paste0("A", 1:6))
  expect_false(any(duplicated(got$candidates)))
  expect_true("A1" %in% got$groups[[1L]])
})

test_that("a list left in the hidden box is ignored while another Source is chosen", {
  skip_on_cran()

  # Green-at-HEAD coverage (NOT a RED): "All available" never reads the box,
  # so a list typed earlier and then left behind cannot narrow the pool.
  got <- olRun(olPed(), animalSource = "all", customAnimalIds = "A1, A2")

  expect_setequal(got$candidates, paste0("A", 1:8))
})
