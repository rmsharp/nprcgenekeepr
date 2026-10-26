## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S994 (BACKLOG.md docs-audit part 2; the housekeeping list of the S991
## report, docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md,
## Recommendation 3): seven places say something the code does not do. The
## owner approved one sentence per place at the S994 PRE-RED question
## (all seven as proposed, the pyramid line spelled `darkblue`):
##
##   N1  the Genetic Diversity help says a missing birth date makes the
##       reactives error; since S928 the module shows a note instead.
##   CD1 the Age-Sex Pyramid's height help line is styled `color: darblue`,
##       which no browser knows.
##   CD2 a comment in modSummaryStats.R says the app passes
##       kinshipMatrix=NULL; appServer passes sharedKinshipMatrix.
##   CC1 a comment in modPedigree.R says a twin pair with a member trimmed out
##       of view is "ignored"; the call stops and the whole sidecar becomes
##       NULL (the help already says so). S997 then changed the code itself
##       (the pairs that fit are kept); this file's CC1 guard follows the
##       comment.
##   CD4 ten Summary Statistics export popovers say the file goes "to the user
##       selected directory"; they are download buttons, so the browser
##       decides.
##   CA5 two alerts say confirming "unlocks" downloads / exports; no download
##       handler reads the confirmation.
##
## Nothing here changes what the app does, except CD1's color. Each place is
## read as the app shows it where it can be (the rendered UI, the rendered
## alert) and as the source says it where it cannot (a comment). The two
## comment blocks have a guard that the false sentence is gone and the true
## one stands; a comment cannot be tested any other way.

## sourceLines(), plainText(), expectWording(), helpPlaces() and
## skipUnlessHelpInSourceTree() are in helper-pageText.R.

## The comment lines of one R file as one line of text: the leading `#` and
## backticks dropped, line breaks collapsed, so a sentence a comment wraps over
## several lines can be matched whole.
commentText <- function(file) {
  lines <- sourceLines("R", file)
  lines <- sub("^\\s*#+\\s?", "", lines[grepl("^\\s*#", lines)])
  gsub("\\s+", " ", gsub("`", "", paste(lines, collapse = " ")))
}

## What an alert shows: tags dropped, `&amp;` read as `&`, white space
## collapsed.
alertText <- function(html) {
  trimws(gsub("&amp;", "&", plainText(html, html = TRUE), fixed = TRUE))
}

## -- Readers (green at HEAD): the RED failures below are about the wording,
## -- not about readers that find nothing --------------------------------------

test_that("the readers find the seven places this file pins", {
  places <- helpPlaces("modGeneticDiversityServer", "modGeneticDiversity.R")
  skipUnlessHelpInSourceTree(places)
  for (read in places) {
    expect_match(read(), "covering every member of every group;", fixed = TRUE)
  }
  expect_match(commentText("modSummaryStats.R"),
               "Calculate kinship from pedigree if not provided", fixed = TRUE)
  expect_match(commentText("modPedigree.R"),
               "checkTwinRelations() only ever stop()s", fixed = TRUE)

  popoverHtml <- as.character(modSummaryStatsUI("x"))
  expect_equal(occurrences(popoverHtml, "shinyBS.addTooltip("), 12L)
  expect_match(as.character(modPyramidUI("x")), "Increase height", fixed = TRUE)
})

## -- N1 ----------------------------------------------------------------------

n1HelpPlaces <- helpPlaces("modGeneticDiversityServer", "modGeneticDiversity.R")

n1Now <- paste(
  "Errors raised inside getGeneticDiversityStats (a group member missing from",
  "the kinship matrix) are not caught, so the reactives error instead of",
  "returning NULL."
)
n1Gone <- "or a group member with a missing birth date"

for (place in names(n1HelpPlaces)) {
  test_that(paste0("the ", place, " of modGeneticDiversityServer no longer ",
                   "says a missing birth date errors the reactives"), {
    skipUnlessHelpInSourceTree(n1HelpPlaces)
    expectWording(n1HelpPlaces[[place]](), now = n1Now, gone = n1Gone)
  })
}

## -- CD1 ---------------------------------------------------------------------

test_that("the Age-Sex Pyramid's height help line is styled with a real color", {
  html <- as.character(modPyramidUI("x"))
  hit <- regmatches(html, regexec('style="([^"]*)">Increase height', html))[[1L]]
  expect_length(hit, 2L)
  color <- trimws(regmatches(
    hit[2L], regexec("(?:^|;)\\s*color:\\s*([^;]+)", hit[2L], perl = TRUE)
  )[[1L]][2L])
  expect_equal(color, "darkblue")
  expect_no_error(grDevices::col2rgb(color))
})

## -- CD2 and CC1 (comments) --------------------------------------------------

## Phase 9b of the performance and memory campaign (S1064): appServer passes
## its kinship provider, kinshipFor, instead of the shared matrix, so the S994
## sentence went false; the owner chose the replacement at the S1064 PRE-RED
## question ("Proposed sentence").
test_that("the Summary Statistics kinship comment says what appServer passes", {
  expectWording(
    commentText("modSummaryStats.R"),
    now = paste(
      "(the fallback recompute; the app passes its kinship provider,",
      "kinshipFor, so this runs only when neither kinship source gives a",
      "matrix)"
    ),
    gone = c(
      paste("the path the app always takes since appServer passes",
            "kinshipMatrix=NULL"),
      paste("(the fallback recompute; the app passes its shared full-pedigree",
            "matrix, so this runs only when that reactive gives no matrix)")
    )
  )
})

## S997 changed what CC1's comment describes: the S994 sentence ("a pair with
## a member trimmed out of view fails validation ... the whole sidecar becomes
## NULL") was true of the code and is now false of it, because the owner ruled
## the pairs that fit are kept (test_modPedigree_twinRelationsTrimmed.R). The
## guard follows the comment.
test_that("the twinRelationsData comment says the file is checked against the
           whole studbook", {
  expectWording(
    commentText("modPedigree.R"),
    now = c(
      paste(
        "Validated against studbook(), the whole pedigree the module",
        "received, not the focal-trimmed view, so a twin pair with an animal",
        "outside the view is still a valid pair."
      ),
      paste(
        "Each use gets only the pairs whose two animals it holds: the",
        "diagram the view, the other tabs the analysis pedigree."
      )
    ),
    gone = c("is correctly treated as unknown/ignored",
             "hidden-but-still-tracked",
             "Validated against pedigreeData()",
             "fails validation: an error notification names the id")
  )
})

## The sentence the new comment makes about the validator (green at HEAD): one
## id outside the pedigree stops the call for every pair, even a valid one.
test_that("checkTwinRelations stops for every pair when one id is outside", {
  ped <- data.frame(
    id = c("F1", "F2", "S1", "S2", "S3", "S4"),
    sire = c(NA, NA, "F1", "F1", "F1", "F1"),
    dam = c(NA, NA, "F2", "F2", "F2", "F2"),
    sex = c("M", "F", "F", "F", "F", "F"),
    stringsAsFactors = FALSE
  )
  pairs <- data.frame(id1 = c("S1", "S3"), id2 = c("S2", "S4"),
                      code = "MZ twin", stringsAsFactors = FALSE)
  expect_no_error(checkTwinRelations(ped, pairs))
  expect_error(checkTwinRelations(ped[ped$id != "S4", ], pairs),
               "Twin relation id(s) not found in the pedigree: S4",
               fixed = TRUE)
})

## -- CD4 ---------------------------------------------------------------------

## The ten export popovers that said "to the user selected directory", by the
## button each belongs to. Only the tail changed; the other grammar is as it
## was. The two relationship popovers beside them never named a directory and
## stay as they are.
csvTail <- "CSV file your browser saves to its download folder."
pngTail <- "PNG file your browser saves to its download folder."
exportPopovers <- c(
  downloadKinship = paste("This exports the kinship matrix to a", csvTail),
  downloadMaleFounders = paste(
    "This exports the male founder pedigree records to a", csvTail
  ),
  downloadFemaleFounders = paste(
    "This exports the female founder pedigree records to a", csvTail
  ),
  downloadFirstOrder = paste(
    "This exports all first-order relations to a", csvTail
  ),
  downloadMkHist = paste(
    "This exports the Mean Kinship Coefficient histogram as a", pngTail
  ),
  downloadZscoreHist = paste(
    "This exports the Mean Kinship Z-score histogram as a", pngTail
  ),
  downloadGuHist = paste(
    "This exports the Genome Uniqueness histogram as", pngTail
  ),
  downloadMkBox = paste(
    "This exports Mean Kinship Coefficient box plot as", pngTail
  ),
  downloadZscoreBox = paste(
    "This exports the Mean Kinship Z-score box plot as a", pngTail
  ),
  downloadGuBox = paste("This exports Genome Uniqueness box plot as a", pngTail)
)

## The text of every popover in the Summary Statistics UI, named by the
## button's id without the module prefix.
popoverTexts <- function() {
  html <- as.character(modSummaryStatsUI("x"))
  calls <- regmatches(html, gregexpr(
    "shinyBS\\.addTooltip\\('x-[^']+', 'popover', \\{'content': '[^']*'", html
  ))[[1L]]
  stats::setNames(
    sub(".*'content': '([^']*)'$", "\\1", calls),
    sub("^shinyBS\\.addTooltip\\('x-([^']+)'.*$", "\\1", calls)
  )
}

test_that("the ten Summary Statistics export popovers say the browser saves", {
  texts <- popoverTexts()
  expect_setequal(names(texts)[names(texts) %in% names(exportPopovers)],
                  names(exportPopovers))
  for (id in names(exportPopovers)) {
    expect_equal(unname(texts[id]), unname(exportPopovers[id]), info = id)
  }
  expect_false(any(grepl("selected directory", texts, fixed = TRUE)))
})

## -- CA5 ---------------------------------------------------------------------

test_that("the Deidentified Export alert does not promise to unlock downloads", {
  ped <- qcStudbook(nprcgenekeepr::pedGood)
  shiny::testServer(modDeidentifiedExportServer,
                    args = list(pedigree = shiny::reactive(ped)), {
    expect_equal(
      alertText(output$exportGateUI$html),
      paste("Confirm the export on the Configure & Preview tab before you",
            "share these files.")
    )
  })
})

test_that("the Cross-Center merge alert does not promise to unlock exports", {
  shiny::testServer(modCrossCenterIdentityServer, args = list(), {
    expect_equal(
      alertText(output$exportGateUI$html),
      "Confirm the merge on the Preview tab before you share these exports."
    )
  })
})
