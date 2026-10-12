## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## S967 (BACKLOG.md docs-audit part 2; S966 audit Finding 3): the help for
## groupAddAssign() said that, with more than one group, the function "finds
## the set of groups with the largest average size". The code ranks a trial by
## the size of its smallest group (`min(lengths(groupMembers))`,
## R/groupAddAssign.R), so a 10-and-9 split scores 9, not 9.5. The owner
## approved one sentence, the same in both places (the roxygen block and the
## regenerated man page): "... it finds the set of groups with the largest
## minimum group size (the score is the size of the smallest group)." The
## phrase is the one the in-app guide already uses (gvAndBgDesc.html).
##
## The help assertions are scoped to the one paragraph that describes what the
## function finds, so a mention elsewhere on the page (the next paragraph says
## "finding the largest") cannot make them pass by accident (Learning 89).
## They read the generated man/*.Rd and the R source (source/dev context;
## under an installed package neither directory exists and they skip).

manPath <- function() {
  testthat::test_path("..", "..", "man", "groupAddAssign.Rd")
}

sourcePath <- function() {
  testthat::test_path("..", "..", "R", "groupAddAssign.R")
}

skipUnlessHelpFiles <- function() {
  testthat::skip_if(
    !file.exists(manPath()) || !file.exists(sourcePath()),
    "man/*.Rd or R/*.R not available (installed package)"
  )
}

collapseSpace <- function(x) trimws(gsub("\\s+", " ", x))

findsParagraph <- "groupAddAssign finds"

## The paragraph of the man page's \details section that matches `pattern`,
## white space collapsed; NA_character_ when there is none.
manParagraph <- function(pattern = findsParagraph) {
  parsed <- tools::parse_Rd(manPath())
  tags <- vapply(parsed, function(x) attr(x, "Rd_tag"), character(1L))
  section <- which(tags == "\\details")
  if (length(section) == 0L) {
    return(NA_character_)
  }
  text <- paste(unlist(parsed[[section[1L]]]), collapse = "")
  paragraphs <- strsplit(text, "\n[ \t]*\n")[[1L]]
  hit <- paragraphs[grepl(pattern, paragraphs)]
  if (length(hit) == 0L) NA_character_ else collapseSpace(hit[1L])
}

## The roxygen paragraph in R/groupAddAssign.R that matches `pattern`, with
## the `#'` prefix and the \code{} markup removed and white space collapsed
## (the man page keeps the code text without the markup); NA_character_ when
## there is none. A line that is not roxygen ends a paragraph, so two blocks
## never merge.
roxygenParagraph <- function(pattern = findsParagraph) {
  lines <- readLines(sourcePath(), warn = FALSE)
  text <- ifelse(startsWith(lines, "#'"), sub("^#' ?", "", lines), "")
  blank <- trimws(text) == ""
  paragraphs <- vapply(
    split(text[!blank], cumsum(blank)[!blank]),
    paste, character(1L),
    collapse = " "
  )
  paragraphs <- gsub("\\\\code\\{([^}]*)\\}", "\\1", paragraphs)
  hit <- unname(paragraphs[grepl(pattern, paragraphs)])
  if (length(hit) == 0L) NA_character_ else collapseSpace(hit[1L])
}

newGroupSentence <- "the set of groups with the largest minimum group size"
newScoreSentence <- "(the score is the size of the smallest group)"

## The two places that carry the sentence, as readers; each is called inside a
## test, after skipUnlessHelpFiles().
helpPlaces <- list(
  "man page" = manParagraph,
  "roxygen block" = roxygenParagraph
)

## Sanity checks on the two readers (green at HEAD). They prove the RED
## failures below are about the help text, not about readers that find nothing.
test_that("both readers return the paragraph that says what groupAddAssign finds", {
  skipUnlessHelpFiles()
  for (read in helpPlaces) {
    text <- read()
    expect_false(is.na(text))
    expect_match(text, "finds the largest group that can be formed", fixed = TRUE)
    expect_match(text, "more than 1 group is desired", fixed = TRUE)
  }
})

test_that("both readers return NA when no paragraph matches", {
  skipUnlessHelpFiles()
  for (read in helpPlaces) {
    expect_true(is.na(read("no paragraph says this")))
  }
})

## The failing tests (RED at HEAD): both places still say "largest average
## size".
for (place in names(helpPlaces)) {
  test_that(paste0("the ", place, " names the largest minimum group size and the score"), {
    skipUnlessHelpFiles()
    text <- helpPlaces[[place]]()
    expect_false(is.na(text))
    expect_match(text, newGroupSentence, fixed = TRUE, info = text)
    expect_match(text, newScoreSentence, fixed = TRUE, info = text)
  })
}

test_that("neither the man page nor the roxygen block says average", {
  skipUnlessHelpFiles()
  for (read in helpPlaces) {
    text <- read()
    expect_false(is.na(text))
    expect_false(grepl("average", text, ignore.case = TRUE), info = text)
  }
})

## Contract locks (green at HEAD, not the RED drivers).
## The man page is generated from the roxygen block, so a stale page (the
## sentence edited, devtools::document() not run) fails here.
test_that("the man page paragraph is the roxygen paragraph", {
  skipUnlessHelpFiles()
  expect_identical(manParagraph(), roxygenParagraph())
})

## The help sentence is only true while the score is the smallest group's
## size. With two groups, a 10-and-9 split must score 9 (an average would give
## 9.5); the guard expectation proves the fixture does produce uneven groups,
## so the lock cannot pass on equal groups alone.
test_that("groupAddAssign scores a candidate by its smallest group", {
  qcBreeders <- nprcgenekeepr::qcBreeders
  pedWithGenotype <- nprcgenekeepr::pedWithGenotype
  pedWithGenotypeReport <- nprcgenekeepr::pedWithGenotypeReport
  skip_if_not(exists("qcBreeders"))
  skip_if_not(exists("pedWithGenotype"))
  skip_if_not(exists("pedWithGenotypeReport"))
  result <- withr::with_seed(
    10L,
    groupAddAssign(
      candidates = qcBreeders,
      kmat = pedWithGenotypeReport$kinship,
      ped = pedWithGenotype,
      currentGroups = character(0L),
      ignore = NULL,
      minAge = 1L,
      numGp = 2L,
      harem = FALSE,
      sexRatio = 0L,
      withKin = FALSE,
      iter = 30L
    )
  )
  sizes <- lapply(result$candidates, function(cand) lengths(cand$group[1L:2L]))
  expect_gt(length(sizes), 0L)
  expect_true(any(vapply(sizes, function(s) length(unique(s)) > 1L, logical(1L))))
  for (i in seq_along(sizes)) {
    expect_identical(
      as.numeric(result$candidates[[i]]$score), as.numeric(min(sizes[[i]])),
      info = paste("candidate", i, "sizes", paste(sizes[[i]], collapse = " "))
    )
  }
})
