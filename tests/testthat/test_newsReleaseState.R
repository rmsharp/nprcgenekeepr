## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Release-note wording guard (S788, stage 1 of the NEWS.Rmd release-state
## sweep; Learning 785, owner ruling S774).
##
## NEWS.Rmd states the package's finished state at release, relative to the
## PRIOR release -- never an in-progress milestone ("first step", "continued",
## "final step", "groundwork", "arrives in a later step"). These tests scan the
## newest version block of NEWS.Rmd (the development block while one exists)
## for those markers, and check the detector itself on synthetic text so a
## guard that scans nothing, or misses a phrase, cannot pass silently.
##
## Later stages of the sweep add their own phrase patterns here, each one
## first as a failing test.
##
## Stage 2, piece (a) (S789): the "## Pedigree Diagram" section's display and
## defaults entries. Four checks scoped to that section tie the notes to what
## the app does: the two display limits (read from R/modPedigree.R), the
## connector style that is the default (read from makePedigreeMatingLayout()),
## the one shading rule, and the male-parent-left rule. Each later piece adds
## its own checks below.
##
## NEWS.Rmd is build-ignored, so the real-file tests skip inside an R CMD
## check tarball, like test_effectivePopulationSizeDocs.R.

library(testthat)

## The newest version block: from the first "# nprcgenekeepr" heading up to
## (not including) the second one. Returns the heading's 1-based line number
## in the file and the block's lines; an empty block if no heading exists.
newsTopBlock <- function(lines) {
  heads <- grep("^# nprcgenekeepr", lines)
  if (length(heads) == 0L) {
    return(list(start = 0L, lines = character(0L)))
  }
  end <- if (length(heads) > 1L) heads[2L] - 1L else length(lines)
  list(start = heads[1L], lines = lines[heads[1L]:end])
}

## The bullet entries of a block. An entry starts at a line beginning "- " and
## runs over the indented lines that follow it; `line` is the file line the
## entry starts on and `text` its wrapped lines joined into one string.
newsEntries <- function(block) {
  ls <- block$lines
  starts <- grep("^- ", ls)
  entries <- lapply(starts, function(i) {
    j <- i
    while (j < length(ls) && grepl("^  \\S", ls[j + 1L])) {
      j <- j + 1L
    }
    text <- paste(trimws(ls[i:j]), collapse = " ")
    data.frame(line = block$start + i - 1L, text = sub("^- ", "", text),
               stringsAsFactors = FALSE)
  })
  if (length(entries) == 0L) {
    return(data.frame(line = integer(0L), text = character(0L),
                      stringsAsFactors = FALSE))
  }
  do.call(rbind, entries)
}

## Markers of an in-progress milestone; matched case-insensitively.
milestonePhrases <- c(
  "continued)" = "continued\\)",
  "first/final/next step" = "\\b(first|final|next) step\\b",
  "later step(s)" = "\\blater steps?\\b",
  "groundwork" = "\\bgroundwork\\b",
  "arrive(s) in" = "\\barrives? in\\b",
  "follows below" = "\\bfollows below\\b",
  "future pass" = "\\bfuture pass\\b",
  "Development continues" = "Development continues",
  "yet" = "\\byet\\b"
)

## One row per (entry line, phrase) match.
findMilestones <- function(entries, phrases = milestonePhrases) {
  hits <- lapply(seq_len(nrow(entries)), function(i) {
    matched <- names(phrases)[vapply(phrases, grepl, logical(1L),
                                     x = entries$text[i], ignore.case = TRUE)]
    if (length(matched) == 0L) return(NULL)
    data.frame(line = entries$line[i], phrase = matched,
               stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, hits)
  if (is.null(out)) {
    return(data.frame(line = integer(0L), phrase = character(0L),
                      stringsAsFactors = FALSE))
  }
  out
}

asEntry <- function(text, line = 1L) {
  data.frame(line = line, text = text, stringsAsFactors = FALSE)
}

## The entries of one "## <heading>" section of a block: from that heading up
## to (not including) the next "## " heading, with file line numbers as in
## newsEntries(). An empty data frame if the heading is absent.
newsSectionEntries <- function(block, heading) {
  ls <- block$lines
  from <- which(ls == paste0("## ", heading))
  if (length(from) == 0L) {
    return(newsEntries(list(start = 0L, lines = character(0L))))
  }
  from <- from[1L]
  later <- grep("^## ", ls)
  later <- later[later > from]
  to <- if (length(later) > 0L) later[1L] - 1L else length(ls)
  newsEntries(list(start = block$start + from - 1L, lines = ls[from:to]))
}

## The connector style ("Rectilinear" or "Direct") that each sentence with the
## word "default" makes the default: the style named just before the word, else
## the first style named after it. Sentences without the word, or naming no
## style, are skipped.
defaultStyles <- function(text) {
  styles <- c("Rectilinear", "Direct")
  sentences <- unlist(strsplit(text, "(?<=\\.)\\s+(?=[A-Z])", perl = TRUE))
  found <- character(0L)
  for (s in sentences) {
    d <- regexpr("\\bdefaults?\\b", s, ignore.case = TRUE, perl = TRUE)[[1L]]
    if (d < 0L) next
    pos <- unlist(lapply(styles, function(nm) {
      p <- gregexpr(paste0("\\b", nm, "\\b"), s, perl = TRUE)[[1L]]
      if (p[[1L]] < 0L) return(NULL)
      stats::setNames(as.integer(p), rep(nm, length(p)))
    }))
    if (length(pos) == 0L) next
    before <- pos[pos < d]
    found <- c(found, if (length(before) > 0L) {
      names(before)[which.max(before)]
    } else {
      names(pos)[which.min(pos)]
    })
  }
  found
}

## The integer a source line "<name> <- <n>L" assigns; NA if there is none.
readCap <- function(lines, name) {
  hit <- grep(paste0("^\\s*", name, "\\s*<-\\s*[0-9]+L"), lines, value = TRUE)
  if (length(hit) == 0L) return(NA_integer_)
  as.integer(sub(".*<-\\s*([0-9]+)L.*", "\\1", hit[1L]))
}

## The two display limits the app sets, read from its source; skips when the
## source is not present in this build.
diagramCaps <- function() {
  src <- testthat::test_path("..", "..", "R", "modPedigree.R")
  skip_if_not(file.exists(src), "R/modPedigree.R not present in this build")
  lines <- readLines(src, warn = FALSE)
  c(direct = readCap(lines, "pedigreeDiagramMaxNodes"),
    rectilinear = readCap(lines, "pedigreeDiagramMaxNodesRectilinear"))
}

## The bullet entries of the newest NEWS.Rmd block's "## Pedigree Diagram"
## section; skips when NEWS.Rmd is not present in this build.
diagramSectionEntries <- function() {
  path <- testthat::test_path("..", "..", "NEWS.Rmd")
  skip_if_not(file.exists(path), "NEWS.Rmd not present in this build")
  newsSectionEntries(newsTopBlock(readLines(path, warn = FALSE)),
                     "Pedigree Diagram")
}

test_that("newsTopBlock() returns only the newest version block", {
  lines <- c("---", "title: NEWS", "---",
             "# nprcgenekeepr 3.0.0.9000 (development version)", "",
             "## Section", "- A new thing.",
             "# nprcgenekeepr 3.0.0 (20260101)", "- The first step older.",
             "# nprcgenekeepr 2.0.0 (20250101)", "- Oldest.")
  block <- newsTopBlock(lines)
  expect_identical(block$start, 4L)
  expect_identical(block$lines, lines[4:7])
})

test_that("newsTopBlock() copes with one heading and with none", {
  one <- c("intro", "# nprcgenekeepr 1.0 (20200101)", "- Only block.")
  expect_identical(newsTopBlock(one)$start, 2L)
  expect_identical(newsTopBlock(one)$lines, one[2:3])
  none <- newsTopBlock(c("no", "headings"))
  expect_identical(none$start, 0L)
  expect_length(none$lines, 0L)
  expect_identical(nrow(newsEntries(none)), 0L)
})

test_that("newsEntries() joins wrapped lines and reports the start line", {
  block <- list(start = 10L,
                lines = c("## Section", "- One entry that wraps",
                          "  onto a second line.", "- Second entry.", "",
                          "Prose that is not a bullet.", "- Third."))
  entries <- newsEntries(block)
  expect_identical(entries$line, c(11L, 13L, 16L))
  expect_identical(entries$text,
                   c("One entry that wraps onto a second line.",
                     "Second entry.", "Third."))
})

test_that("the detector fires on every in-progress milestone phrase", {
  positives <- c(
    "continued)" = paste("Ancestry rules are now enforced (issue #168,",
                         "continued): hand a rules file to group formation."),
    "first/final/next step" =
      "This is the first step toward MHC haplotype frequency reporting.",
    "first/final/next step" =
      "The guardrails are now complete (issue #168, final step): a new tab.",
    "first/final/next step" =
      "Viewing trends in the app arrives in the next step of this work.",
    "later step(s)" =
      "Enforcement during group formation arrives in later steps of this work.",
    "later step(s)" = "It will use the rules in a later step of this work.",
    "groundwork" =
      "A running history file: the groundwork for seeing trends over time.",
    "arrive(s) in" = "The in-app violations view arrive in a later release.",
    "follows below" = "\"Rectilinear\" support follows below.",
    "future pass" =
      "Two rarer cases remain open, disclosed follow-ups for a future pass.",
    "Development continues" = "Development continues here on top of it.",
    "yet" = "Script-callable only; no Shiny screen yet."
  )
  for (i in seq_along(positives)) {
    hits <- findMilestones(asEntry(positives[[i]]))
    expect_true(names(positives)[i] %in% hits$phrase,
                info = paste0("'", names(positives)[i], "' missed in: ",
                              positives[[i]]))
  }
})

test_that("the detector ignores letter case", {
  hits <- findMilestones(asEntry("Groundwork for ancestry guardrails."))
  expect_identical(hits$phrase, "groundwork")
})

test_that("the detector stays silent on release-state wording", {
  controls <- c(
    "Colony managers can now see genetic-health trends directly in the app.",
    "A step-by-step guide walks through each pedigree.",
    "Continued fractions are not used.",
    "The yeti dataset is unrelated.",
    "Ancestry rules are enforced during group formation, in every mode."
  )
  for (txt in controls) {
    expect_identical(nrow(findMilestones(asEntry(txt))), 0L, info = txt)
  }
})

test_that("findMilestones() reports each entry's line and every phrase", {
  entries <- rbind(asEntry("Clean release-state wording.", 20L),
                   asEntry("Groundwork now; arrives in a later step.", 30L))
  hits <- findMilestones(entries)
  expect_identical(hits$line, c(30L, 30L, 30L))
  expect_setequal(hits$phrase,
                  c("groundwork", "arrive(s) in", "later step(s)"))
})

test_that("the newest NEWS.Rmd block has no in-progress milestone phrases", {
  path <- testthat::test_path("..", "..", "NEWS.Rmd")
  skip_if_not(file.exists(path), "NEWS.Rmd not present in this build")
  block <- newsTopBlock(readLines(path, warn = FALSE))
  entries <- newsEntries(block)
  ## A guard that scanned nothing would pass for the wrong reason.
  expect_gt(nrow(entries), 0L)
  hits <- findMilestones(entries)
  found <- sprintf(":%d %s", hits$line, hits$phrase)
  expect_identical(found, character(0L),
                   info = paste("NEWS.Rmd line and phrase:",
                                paste(found, collapse = "; ")))
})

test_that("newsSectionEntries() returns only the named section's entries", {
  block <- list(start = 10L,
                lines = c("# nprcgenekeepr 3.0.0.9000", "## Alpha",
                          "- Alpha one.", "- Alpha two", "  wraps.",
                          "## Beta", "- Beta one.", "## Gamma", "- Gamma."))
  alpha <- newsSectionEntries(block, "Alpha")
  expect_identical(alpha$line, c(12L, 13L))
  expect_identical(alpha$text, c("Alpha one.", "Alpha two wraps."))
  beta <- newsSectionEntries(block, "Beta")
  expect_identical(beta$line, 16L)
  expect_identical(beta$text, "Beta one.")
})

test_that("newsSectionEntries() reads to the end of the last section", {
  block <- list(start = 1L,
                lines = c("## First", "- One.", "## Last", "- Two.",
                          "- Three."))
  last <- newsSectionEntries(block, "Last")
  expect_identical(last$line, c(4L, 5L))
  expect_identical(last$text, c("Two.", "Three."))
})

test_that("newsSectionEntries() is empty for a missing heading", {
  block <- list(start = 1L, lines = c("## Alpha", "- One."))
  expect_identical(nrow(newsSectionEntries(block, "Missing")), 0L)
  ## A heading that only prefixes another does not match.
  expect_identical(nrow(newsSectionEntries(block, "Alph")), 0L)
})

test_that("defaultStyles() attaches the default to the style named nearest", {
  ## Named after the word: the first style after it.
  expect_identical(
    defaultStyles(paste("The tab uses a default \"Direct\" style and an",
                        "alternative \"Rectilinear (kinship2-style)\" style.")),
    "Direct")
  expect_identical(
    defaultStyles("The default is Rectilinear; Direct draws straight lines."),
    "Rectilinear")
  ## Named before the word: the last style before it, even with another after.
  expect_identical(
    defaultStyles(paste("Choose \"Rectilinear (kinship2-style)\" right-angle",
                        "connectors (the default) or straight-line \"Direct\"",
                        "connectors.")),
    "Rectilinear")
  expect_identical(
    defaultStyles("Rectilinear or Direct, the default, draws straight lines."),
    "Direct")
})

test_that("defaultStyles() works one sentence at a time and skips the rest", {
  ## The second sentence has the word but no style name: skipped.
  expect_identical(
    defaultStyles(paste("Direct draws straight lines. Animals default to",
                        "open symbols.")),
    character(0L))
  ## Two sentences, two answers.
  expect_identical(
    defaultStyles(paste("The default is Rectilinear. Under the default,",
                        "Direct is off.")),
    c("Rectilinear", "Direct"))
  expect_identical(defaultStyles("Rectilinear and Direct are styles."),
                   character(0L))
  expect_identical(defaultStyles("No style and no such word."), character(0L))
})

test_that("defaultStyles() does not match a style name inside a longer word", {
  expect_identical(defaultStyles("The default is Directly stated."),
                   character(0L))
})

test_that("readCap() reads the constant and not a longer name or a comment", {
  src <- c("    pedigreeDiagramMaxNodes <- 750L",
           "    pedigreeDiagramMaxNodesRectilinear <- 400L",
           "    # pedigreeDiagramMaxNodes <- 999L")
  expect_identical(readCap(src, "pedigreeDiagramMaxNodes"), 750L)
  expect_identical(readCap(src, "pedigreeDiagramMaxNodesRectilinear"), 400L)
  expect_identical(readCap(src, "pedigreeDiagramMaxNodesMissing"),
                   NA_integer_)
})

test_that("the Pedigree Diagram section states the display limits once", {
  caps <- diagramCaps()
  ## The constants were found in the source (a check that read nothing would
  ## otherwise pass for the wrong reason).
  expect_false(anyNA(caps))
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  named <- grepl(paste0("\\b(", caps[["direct"]], "|", caps[["rectilinear"]],
                        ")\\b"), entries$text)
  expect_equal(sum(named), 1L,
               info = paste("entries naming a limit start at lines:",
                            paste(entries$line[named], collapse = ", ")))
  ## Each limit is followed by the style it belongs to.
  for (i in which(named)) {
    expect_true(
      grepl(sprintf("\\b%d\\b[^0-9]{0,60}\\bRectilinear\\b",
                    caps[["rectilinear"]]), entries$text[i], perl = TRUE),
      info = sprintf("line %d: %d animals must be followed by Rectilinear",
                     entries$line[i], caps[["rectilinear"]]))
    expect_true(
      grepl(sprintf("\\b%d\\b[^0-9]{0,60}\\bDirect\\b", caps[["direct"]]),
            entries$text[i], perl = TRUE),
      info = sprintf("line %d: %d animals must be followed by Direct",
                     entries$line[i], caps[["direct"]]))
  }
})

test_that("the Pedigree Diagram section names the code's default style", {
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  codeDefault <- eval(formals(makePedigreeMatingLayout)$edgeStyle)[1L]
  attached <- lapply(entries$text, defaultStyles)
  ## A check that found no default statement at all would pass for the wrong
  ## reason.
  expect_gt(length(unlist(attached)), 0L)
  wrong <- vapply(attached, function(a) {
    any(tolower(a) != codeDefault)
  }, logical(1L))
  expect_identical(entries$line[wrong], integer(0L),
                   info = paste("entries making a style other than",
                                codeDefault, "the default start at lines:",
                                paste(entries$line[wrong], collapse = ", ")))
})

test_that("the Pedigree Diagram section describes shading as one rule", {
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  shading <- grepl("shad(e|ed|ing)\\b|\\b(un)?filled\\b", entries$text,
                   ignore.case = TRUE)
  expect_equal(sum(shading), 1L,
               info = paste("entries about shading start at lines:",
                            paste(entries$line[shading], collapse = ", ")))
  ## The rule is stated as it is, not as a change from an earlier behavior.
  narrated <- grepl("rather than (filled|shaded)", entries$text,
                    ignore.case = TRUE)
  expect_identical(entries$line[narrated], integer(0L),
                   info = paste("entries narrating a shading change start at",
                                "lines:", paste(entries$line[narrated],
                                                collapse = ", ")))
})

test_that("the Pedigree Diagram section says male-left is always applied", {
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  maleLeft <- grepl("male parent on the left", entries$text,
                    ignore.case = TRUE)
  expect_equal(sum(maleLeft), 1L)
  ## The layout has no setting for it, so the entry must not offer one.
  for (i in which(maleLeft)) {
    expect_false(grepl("by default", entries$text[i], ignore.case = TRUE),
                 info = sprintf("line %d says by default", entries$line[i]))
    expect_true(grepl("\\balways\\b", entries$text[i], ignore.case = TRUE),
                info = sprintf("line %d does not say always", entries$line[i]))
  }
})

test_that("NEWS.Rmd describes issue #168 (ancestry guardrails) in one entry", {
  path <- testthat::test_path("..", "..", "NEWS.Rmd")
  skip_if_not(file.exists(path), "NEWS.Rmd not present in this build")
  entries <- newsEntries(newsTopBlock(readLines(path, warn = FALSE)))
  mentions <- entries$line[grepl("#168", entries$text, fixed = TRUE)]
  expect_equal(length(mentions), 1L,
               info = paste("entries mentioning #168 start at lines:",
                            paste(mentions, collapse = ", ")))
})
