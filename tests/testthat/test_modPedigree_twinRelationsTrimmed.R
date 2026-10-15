## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S997 (docs-audit part 2, flag CC1 of
## docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md): a twin-pairs
## file loaded on the Pedigree Browser is checked against the focal-trimmed,
## unknown-hidden view, so ONE pair with an animal outside the view (the trim
## box ticked, a focal animal that leaves one twin out) fails the check for
## EVERY pair: a red error names the id, the whole file becomes NULL, no
## connector is drawn and Summary Statistics, Breeding Groups and Genetic
## Value get no twin correction. Measured S997 in the real app on the bundled
## 375-animal example (focal E06FRB and 7U5NJD, trim on, 44 animals in view):
## the error named BRI2MW, HV7LZ3 and 677E7M and the DZ pair that sits wholly
## in the view was dropped with the rest.
##
## The owner ruled at the S997 PRE-RED question: keep the pairs that fit, say
## nothing. The file is checked against the whole studbook the module
## received; each place that uses the pairs is handed only those whose two
## animals it holds (the diagram the view, the other tabs the analysis
## pedigree, which the Display Unknown IDs box does not narrow). An id that is
## not in the studbook at all, or a pair that does not fit, still rejects the
## whole file with an error notification.
##
## Why each place must be handed only its own pairs (probed S997): the
## diagram builder and kinship() both stop with "All twinRelations id1/id2
## values must be present in id" on a pair with an animal they do not hold.
##
## The fixture: two sibling sets and two placeholder ids. With the focal
## animals S1 and G1 and the trim on, the view is F1, F2, S1, G1, T1 and T2:
## S2 is outside (the S1/S2 pair is half in) and T1/T2 is wholly in.

trimTwinPed <- function() {
  data.frame(
    id = c("F1", "F2", "S1", "S2", "S3", "G1", "G2", "T1", "T2",
           "U0001", "U0002"),
    sire = c(NA, NA, "F1", "F1", "F1", NA, NA, "G1", "G1", NA, NA),
    dam = c(NA, NA, "F2", "F2", "F2", NA, NA, "G2", "G2", NA, NA),
    sex = c("M", "F", "F", "F", "M", "M", "F", "F", "M", "F", "F"),
    stringsAsFactors = FALSE
  )
}

## The data.frame shiny's fileInput hands the server for an uploaded file.
trimFileInfo <- function(path) {
  data.frame(
    name = basename(path), size = 1L, type = "text/csv",
    datapath = path, stringsAsFactors = FALSE
  )
}

## The twin connector edges of a layout: the only edges with a label.
trimConnectorRows <- function(edges) {
  edges[!is.na(edges$label) & edges$label %in% c("MZ", "DZ", "?"), ]
}

## One run of the module: the pairs file (its lines after the header), the
## trim box, the focal animals (none when ""), the Display Unknown IDs box;
## the Show Twin Connectors toggle is on. Returns the view's ids, the value
## the other tabs get (twinRelations()), the layout's connector rows and the
## texts of the error notifications shown (the showNotification mold of
## test_modMatePair_ancestryOverrides.R: mock the package's imported binding).
runTrimTwins <- function(pairLines, trim, focal = "",
                         displayUnknownIds = TRUE) {
  csv <- tempfile(fileext = ".csv")
  on.exit(unlink(csv), add = TRUE)
  writeLines(c("id1,id2,code", pairLines), csv)
  notes <- list()
  out <- NULL
  testthat::local_mocked_bindings(
    showNotification = function(ui, ..., type = "default") {
      notes[[length(notes) + 1L]] <<- list(text = as.character(ui),
                                           type = type)
      invisible("note-id")
    },
    .package = "nprcgenekeepr"
  )
  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive(trimTwinPed())),
    {
      inputs <- list(displayUnknownIds = displayUnknownIds,
                     trimPedigree = trim, clearFocalAnimals = FALSE)
      if (nzchar(focal)) {
        inputs <- c(inputs, list(focalAnimalIds = focal,
                                 updateFocalAnimals = 1L))
      }
      do.call(session$setInputs, inputs)
      session$setInputs(twinRelationsFile = trimFileInfo(csv),
                        pedigreeShowTwinConnectors = TRUE)
      session$flushReact()
      out <<- list(
        view = pedigreeData()$id,
        twins = session$getReturned()$twinRelations(),
        connectors = trimConnectorRows(
          suppressMessages(diagramLayout())$edges
        )
      )
    }
  )
  errs <- Filter(function(n) identical(n$type, "error"), notes)
  out$errors <- vapply(errs, function(n) n$text, character(1L))
  out
}

bothPairs <- c("S1,S2,MZ twin", "T1,T2,DZ twin")

## -- The fixture (green: the blocks below rely on it) ------------------------

test_that("the trimmed view holds T1 and T2 and leaves S2 outside", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  run <- runTrimTwins(bothPairs, trim = TRUE, focal = "S1,G1")
  expect_setequal(run$view, c("F1", "F2", "S1", "G1", "T1", "T2"))
})

## -- The pair in view is kept (RED) ------------------------------------------

test_that("with S2 outside the trimmed view, the pair in view still reaches
           the other tabs", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  run <- runTrimTwins(bothPairs, trim = TRUE, focal = "S1,G1")
  expect_true(is.data.frame(run$twins))
  expect_identical(run$twins$id1, "T1")
  expect_identical(run$twins$id2, "T2")
  expect_identical(run$twins$code, "DZ twin")
})

test_that("with S2 outside the trimmed view, the diagram draws the
           connector of the pair in view", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  run <- runTrimTwins(bothPairs, trim = TRUE, focal = "S1,G1")
  expect_identical(nrow(run$connectors), 1L)
  expect_setequal(c(run$connectors$from, run$connectors$to), c("T1", "T2"))
  expect_identical(run$connectors$label, "DZ")
})

test_that("a pair with one animal outside the trimmed view is not an error", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  run <- runTrimTwins(bothPairs, trim = TRUE, focal = "S1,G1")
  expect_length(run$errors, 0L)
})

test_that("with no pair wholly in the trimmed view the other tabs get NULL,
           the diagram has no connector and nothing is an error", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  ## Focal F1: the view is F1, S1, S2 and S3, so T1/T2 is outside.
  run <- runTrimTwins("T1,T2,DZ twin", trim = TRUE, focal = "F1")
  expect_setequal(run$view, c("F1", "S1", "S2", "S3"))
  expect_null(run$twins)
  expect_identical(nrow(run$connectors), 0L)
  expect_length(run$errors, 0L)
})

## -- The other tabs keep what the Display Unknown IDs box hides (RED) --------

test_that("a pair of placeholder ids the view hides still reaches the other
           tabs, and is left out of the diagram", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  run <- runTrimTwins(c("S1,S2,MZ twin", "U0001,U0002,UZ twin"),
                      trim = FALSE, displayUnknownIds = FALSE)
  expect_false(any(c("U0001", "U0002") %in% run$view))
  expect_length(run$errors, 0L)
  expect_identical(nrow(run$twins), 2L)
  expect_setequal(as.character(c(run$twins$id1, run$twins$id2)),
                  c("S1", "S2", "U0001", "U0002"))
  expect_identical(nrow(run$connectors), 1L)
  expect_setequal(c(run$connectors$from, run$connectors$to), c("S1", "S2"))
})

## -- What still rejects the whole file (green by design) ---------------------

test_that("an id that is not in the studbook at all still rejects the whole
           file with an error naming it", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  run <- runTrimTwins(c("S1,S2,MZ twin", "S1,X9,DZ twin"), trim = FALSE)
  expect_null(run$twins)
  expect_identical(nrow(run$connectors), 0L)
  expect_length(run$errors, 1L)
  expect_match(run$errors,
               "Twin relation id(s) not found in the pedigree: X9",
               fixed = TRUE)
})

test_that("a pair that does not fit still rejects the whole file", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  ## S1 and T1 are not full sibs, so a DZ pair of them is not consistent.
  run <- runTrimTwins(c("S1,S2,MZ twin", "S1,T1,DZ twin"), trim = FALSE)
  expect_null(run$twins)
  expect_identical(nrow(run$connectors), 0L)
  expect_length(run$errors, 1L)
  expect_match(run$errors, "must share both sire and dam", fixed = TRUE)
})

test_that("with the trim off every pair in the file is kept", {
  skip_if_not_installed("shiny")
  skip_if_not_installed("visNetwork")
  run <- runTrimTwins(bothPairs, trim = FALSE)
  expect_length(run$errors, 0L)
  expect_identical(nrow(run$twins), 2L)
  expect_identical(nrow(run$connectors), 2L)
})

## -- The help says it (RED) --------------------------------------------------

## The twinRelations item of modPedigreeServer's help, in the man page and the
## roxygen block. The owner approved the sentence at the S997 PRE-RED
## question.
twinHelpPlaces <- helpPlaces("modPedigreeServer", "modPedigree.R")

twinHelpNow <- c(
  "Checked against the whole studbook, not the trimmed view:",
  paste(
    "a valid pair with an animal outside analysisPedigree (a focal-animal",
    "trim) is left out of this value, with no message."
  )
)
twinHelpGone <- c(
  "It is validated against the filtered pedigree (focal trim applied,",
  "one id outside that pedigree fails the validation"
)

for (place in names(twinHelpPlaces)) {
  test_that(paste0("the ", place, " of modPedigreeServer says the twin file ",
                   "is checked against the whole studbook"), {
    skipUnlessHelpInSourceTree(twinHelpPlaces)
    expectWording(twinHelpPlaces[[place]](), now = twinHelpNow,
                  gone = twinHelpGone)
  })
}
