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
## Stage 2, piece (b) (S790): the section's mating-symbol placement and
## spacing entries. Two checks: the duplicate-node count the section cites
## for the bundled 375-animal example is the CURRENT count, measured fresh
## from .buildMatingUnitForest() (not a number carried forward from an
## earlier session and never re-checked -- the "22" this piece replaces was
## measured at S573 and had drifted to 113 by this session, Learning 802);
## and no mating-symbol-placement entry overstates its own rule the way the
## S789 male-left entry once did (the position engine's own tests document
## named, disclosed exceptions to exact centering on the real fixture, so
## "each"/"every" wording here is also an overstatement -- promisesEveryPair()
## now flags "each" too, alongside "always/every/all").
##
## Stage 2, piece (c) (S791): the section's connector-routing, collision-
## avoidance and sibling-bar entries. One check: the sibling-bar/connecting-
## bar entry (issue #160) once said "Two rarer related cases are not
## corrected" -- true right after Track 1 shipped (S593), stale since Track 2
## (.resolveEdgeNodeCollisions(), S595) generalized same-row collision repair
## to every straight edge, not just the sibling bar. Measured fresh by
## running the real rectilinear pipeline on the bundled 375-animal example:
## 0 "straight-residual" collisions of any kind remain (only already-
## disclosed "curved-heuristic" duplicate-connector residuals do, covered by
## the section's own separate entry) -- so the claim is checked against real
## output, not carried forward from the issue's own historical comments.
##
## Stage 2, piece (d) (S792): the section's remaining entries -- the crash
## fixes (narrowing to focal animals; a trimmed pedigree that keeps a child
## but drops that child's own record), the isolated-animal entries, the
## example pedigrees and the article, and the layout-origin/kinshipMatrix
## entries. One check: none of piece (d)'s entries narrate a fix or a change
## against a PRE-2.0.0 state -- the diagram feature is entirely absent at the
## v2.0.0 tag (`git cat-file -e v2.0.0:R/makePedigreeMatingLayout.R` fails),
## so a 2.0.0 reader never experienced any "before" these entries describe.
## Every underlying claim was checked against real code/tests first (all
## true, none stale): the crash fixes are still in the code (S630's
## xOf/yOf list fix, S682's dangling-parent __dup_ guard); the isolated-
## individual behavior is pinned by test_findIsolatedIds.R and
## test_makePedigreeMatingLayout.R's all-isolated cases; the
## disconnected-component block separation is S667's shipped code; the
## kinshipMatrix argument exists exactly as described
## (makePedigreeMatingLayout()'s own formals); the example pedigrees'
## "11-14 animals" and "exactly one consanguineous mating" claims are pinned
## by test_examplePedigreeFixtures.R (nRows 11/12/12/14/14; one marked union
## per fixture); the dashed duplicate-connector and vermillion (#D55E00)
## consanguineous-marker colors are in the code
## (R/makePedigreeDiagramData.R:1946-2012, :1973). So this piece is a
## wording-only fix: state each entry's finished behavior, not the fix
## narration. (BACKLOG.md's separate claim of stale cross-references in
## Marker Genetics/Mate Pair was investigated and found not to hold: the
## only "described below"/"above" wording there points at unrelated content
## -- Marker Genetics' Cross-Center tab note and Mate Pair's own prior
## entry -- not at the Pedigree Diagram section; no change needed there.)
##
## NEWS.Rmd is build-ignored, so the real-file tests skip inside an R CMD
## check tarball, like test_effectivePopulationSizeDocs.R.

library(testthat)

## newsTopBlock() and newsEntries() are in helper-newsBlocks.R.

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
  span <- newsSectionSpan(block$lines, heading)
  newsEntries(list(start = block$start + span[1L] - 1L,
                   lines = block$lines[span]))
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

## Whether a sentence promises something for every pair ("always", "every",
## "all", or "each" used as a leading universal quantifier: "each mated
## pair"), as opposed to "in most cases"/"many". "each" is matched only when
## followed by a word, not by punctuation, so a per-pair COUNT ("one mate
## each,") is not mistaken for a promise.
promisesEveryPair <- function(text) {
  grepl("\\b(always|every|all)\\b", text, ignore.case = TRUE) |
    grepl("\\beach\\s+\\w", text, ignore.case = TRUE)
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

## The number of individuals whose mating symbol anchors more than one mating
## unit (so at least one extra "duplicate" node is drawn for them elsewhere in
## the diagram), via .buildMatingUnitForest() directly -- the layout engine's
## own accounting of duplicate nodes, never a hardcoded or recalled figure
## (piece (a)'s Learning 802: verify a claim against real output, not memory).
matingUnitDuplicateCount <- function(ped) {
  length(unique(.buildMatingUnitForest(ped)$duplicates$realId))
}

## The number of Track 2 (.resolveEdgeNodeCollisions()) residuals that are
## still an uncorrected STRAIGHT same-row edge/node collision -- as opposed to
## a "curved-heuristic" residual (an already-disclosed duplicate-connector
## arc, covered by the section's own separate entry). Runs the real
## rectilinear pipeline end to end via the same internal functions
## test_addRectilinearWaypoints.R exercises, never a hardcoded or recalled
## figure (piece (c)'s Learning: a claim from an issue's historical comments
## can go stale once a LATER, more general fix supersedes it, same class as
## piece (a)'s male-left roxygen and piece (b)'s stale duplicate count).
straightResidualCount <- function(ped) {
  layout <- makePedigreeMatingLayout(ped, edgeStyle = "direct")
  forest <- .buildMatingUnitForest(ped)
  pos <- .positionMatingUnitForest(ped, forest)
  waypoints <- .addRectilinearWaypoints(layout$nodes, layout$edges, forest,
                                        pos)
  resolved <- .resolveEdgeNodeCollisions(waypoints$nodes, waypoints$edges)
  sum(resolved$residuals$kind == "straight-residual")
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

## A nested bullet's wrapped line is indented four spaces. Stopping at it would
## hide the rest of that bullet from every check that reads entries (S1099).
test_that("newsEntries() keeps a nested bullet's wrapped lines in its entry", {
  block <- list(start = 1L,
                lines = c("- Parent", "  - Child that wraps",
                          "    onto a second line.", "  - Another child.",
                          "- Next."))
  entries <- newsEntries(block)
  expect_identical(entries$line, c(1L, 5L))
  expect_identical(entries$text,
                   c(paste("Parent - Child that wraps onto a second line.",
                           "- Another child."),
                     "Next."))
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

test_that("defaultStyles() attaches it to the style just before, else after", {
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

test_that("promisesEveryPair() flags an unqualified promise only", {
  for (txt in c("The male parent is always drawn on the left.",
                "Every mated pair puts the male parent on the left.",
                "All pairs are drawn male-left.",
                "Each mated pair is drawn on the side nearest the children.")) {
    expect_true(promisesEveryPair(txt), info = txt)
  }
  for (txt in c("The male parent is drawn on the left in most cases.",
                "A parent with several mates is placed to fit the family.",
                "Pairs can appear either way round.",
                "Many mated pairs are drawn on the side nearest the children.",
                paste("For most simple mated pairs (one mate each, no other",
                     "family complications), the gap is clear."))) {
    expect_false(promisesEveryPair(txt), info = txt)
  }
})

test_that("matingUnitDuplicateCount() counts distinct multi-anchor
           individuals, not duplicate nodes -- the GA204Z/8LKBV9 loop fixture
           (also used in test_positionMatingUnitForest.R) has exactly one
           duplicate node, all for the same individual, 8LKBV9", {
  ped <- data.frame(
    id = c("5A6DFT", "8DKELJ", "G8EBU9", "8P17E3",
           "8LKBV9", "FJIB3R", "9VGCCV", "GA204Z"),
    sire = c(NA, NA, NA, NA, "5A6DFT", "8LKBV9", "8LKBV9", "8LKBV9"),
    dam = c(NA, NA, NA, NA, "8DKELJ", "G8EBU9", "8P17E3", "FJIB3R"),
    sex = c("M", "F", "F", "F", "M", "F", "F", "M"),
    gen = c(0L, 0L, 0L, 0L, 1L, 2L, 2L, 3L),
    stringsAsFactors = FALSE
  )
  expect_identical(matingUnitDuplicateCount(ped), 1L)
})

## The Diagram's description is general (owner ruling S1101: a new feature gets
## no help-page detail), so the five tests below check what the section says
## rather than require it to say it.
test_that("the Pedigree Diagram section states the display limits at most once,
           each with its style", {
  caps <- diagramCaps()
  ## The constants were found in the source (a check that read nothing would
  ## otherwise pass for the wrong reason).
  expect_false(anyNA(caps))
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  named <- grepl(paste0("\\b(", caps[["direct"]], "|", caps[["rectilinear"]],
                        ")\\b"), entries$text)
  expect_lte(sum(named), 1L)
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

test_that("the Pedigree Diagram section makes no other style the default", {
  ## The reader finds a default statement when there is one.
  expect_identical(defaultStyles("The Direct style is the default."), "Direct")
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  codeDefault <- eval(formals(makePedigreeMatingLayout)$edgeStyle)[1L]
  attached <- lapply(entries$text, defaultStyles)
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

test_that("the Pedigree Diagram section does not overstate male-left", {
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  maleLeft <- grepl("male parent on the left", entries$text,
                    ignore.case = TRUE)
  expect_lte(sum(maleLeft), 1L)
  ## The layout has no setting for it (the parameter was removed), so the
  ## entry must not offer one ("by default").
  expect_false("orderBySex" %in% names(formals(makePedigreeMatingLayout)))
  for (i in which(maleLeft)) {
    expect_false(grepl("by default", entries$text[i], ignore.case = TRUE),
                 info = sprintf("line %d says by default", entries$line[i]))
    ## Real layouts do not always achieve it: a parent with several mates is
    ## placed to fit the family (measured S789, Rectilinear style: 29 of 231
    ## mixed-sex matings on the bundled rhesusPedigree and 1 of 6 on smallPed
    ## have the male on the right; 227 of 257 across the bundled pedigrees
    ## have him on the left). The entry must not promise every pair.
    expect_false(promisesEveryPair(entries$text[i]),
                 info = sprintf("line %d promises every pair", entries$line[i]))
  }
})

test_that("a mating-symbol duplicate-node count the Pedigree Diagram section
           cites for the bundled 375-animal example is the CURRENT one, not a
           stale historical measurement", {
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  hits <- grepl("duplicate node", entries$text, ignore.case = TRUE) &
    grepl("bundled", entries$text, ignore.case = TRUE)
  expect_lte(sum(hits), 1L)
  if (!any(hits)) return(invisible(NULL))
  src <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                     package = "nprcgenekeepr")
  skip_if_not(nzchar(src), "obfuscated_rhesus_mhc_ped.csv not present in this build")
  ped <- read.csv(src, stringsAsFactors = FALSE)
  n <- matingUnitDuplicateCount(ped)
  ## The count was actually measured (a check that read 0 individuals would
  ## otherwise pass for the wrong reason).
  expect_gt(n, 0L)
  expect_true(grepl(paste0("\\b", n, "\\b"), entries$text[hits]),
              info = sprintf(
                "line %d does not cite the current count (%d): %s",
                entries$line[hits], n, entries$text[hits]))
})

test_that("the Pedigree Diagram section does not overstate mating-symbol
           placement or spacing (the position engine's own tests document
           named, disclosed exceptions to exact centering on the real
           fixture, so an unqualified 'each pair'/'every symbol' promise is
           an overstatement, the same class of finding as S789's male-left
           entry)", {
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  placement <- grepl("mating (symbol|dot)", entries$text, ignore.case = TRUE) |
    grepl("drawn on the side of the family", entries$text, ignore.case = TRUE)
  for (i in which(placement)) {
    expect_false(promisesEveryPair(entries$text[i]),
                 info = sprintf("line %d promises every pair: %s",
                                entries$line[i], entries$text[i]))
  }
})

test_that("the Pedigree Diagram section's sibling-bar/connecting-bar entry
           (issue #160) does not claim a rarer related case remains
           uncorrected -- measured fresh on the bundled 375-animal example,
           Track 2's general same-row repair framework now leaves 0
           uncorrected straight-edge collisions of any kind (only the
           already-disclosed curved-connector residuals remain, covered by
           the section's own separate entry)", {
  src <- system.file("extdata", "examples", "obfuscated_rhesus_mhc_ped.csv",
                     package = "nprcgenekeepr")
  skip_if_not(nzchar(src), "obfuscated_rhesus_mhc_ped.csv not present in this build")
  ped <- read.csv(src, stringsAsFactors = FALSE)
  n <- straightResidualCount(ped)
  ## The count was actually measured (a check that silently read NA would
  ## otherwise pass for the wrong reason).
  expect_false(is.na(n))
  expect_equal(n, 0L)

  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  stale <- grepl("not corrected", entries$text, ignore.case = TRUE)
  expect_identical(entries$line[stale], integer(0L),
                   info = paste("entries claiming something is not",
                                "corrected start at lines:",
                                paste(entries$line[stale], collapse = ", ")))
})

## The exact release-state-narration phrases piece (d) removes from the
## Pedigree Diagram section's remaining entries -- each copied verbatim from
## NEWS.Rmd's current text, so the test fails for the right reason (the
## phrase is really there) before GREEN, and cannot silently match nothing.
pieceDNarrationPhrases <- c(
  "can now be handed",
  "behaves exactly as before",
  "Fixed a crash in the Diagram tab",
  "now always displays correctly",
  "is now checked directly by code, not just by eye",
  "no longer shows an individual as a disconnected",
  "no longer crashes the diagram",
  "it now tells you so",
  "is now drawn as its own block",
  "Previously two unrelated families",
  "Fixed an error in the Diagram tab",
  "diagram now draws normally",
  "The package now includes five small example pedigrees",
  "The Pedigree Diagram article on the package website now walks through"
)

test_that("the Pedigree Diagram section's piece (d) entries (crash fixes,
           isolated-animal entries, example pedigrees and article,
           layout-origin/kinshipMatrix, unrelated-families block) state the
           finished behavior, not a change from a pre-2.0.0 state the
           diagram feature never had", {
  entries <- diagramSectionEntries()
  expect_gt(nrow(entries), 0L)
  text <- paste(entries$text, collapse = " ")
  for (phrase in pieceDNarrationPhrases) {
    expect_false(grepl(phrase, text, fixed = TRUE),
                 info = sprintf("still present: %s", phrase))
  }
})

## A new feature gets a general description; its detail belongs on the help
## pages and in the guide (owner ruling S1101: "If the items are about new
## features, we only need to generally describe the features and not provide
## help-page detail."). Each phrase is copied from its section's text before
## the S1101 cut, so the test failed on real text at RED and cannot match
## nothing by a typo. Detail about a change to something 2.0.0 had stays.
newFeatureDetail <- list(
  "Input" = "A placeholder value other than",
  "Pedigree Diagram" = c(
    "orderBySex", "kinshipMatrix", "regional settings", "400 animals",
    "affected2", "up to four", "113 individuals", "male parent on the left",
    "shortens the curved connectors", "no row of their own", "11-14 animals",
    "brother-sister"
  ),
  "Kinship & Pedigree Calculations" = c(
    "whichever tab is opened first", "must share both recorded parents",
    "columns id1, id2, code"
  ),
  "Breeding Group Formation" = c(
    "Candidates to retain", "2 block, 2 flag", "without ancestry information",
    "maxExhaustiveCandidates", "above 20 eligible animals"
  ),
  "Mate Pair Analysis" = c(
    "overriddenRules", "Download Audit Manifest", "any other sex",
    "nothing changes"
  ),
  "Marker Genetics" = c(
    "maxExclusions", "allele1", "A blank allele", "chromosome name left blank",
    "the only pairs it lists", "more than two alleles",
    "optimized for large panels", "same words as the Potential Parents",
    "the common case where", "Hudson's Fst", "not in the genotype file"
  ),
  "MHC Haplotype Reporting" = c(
    "frequency 0.01", "four decimal places", "a trailing ?",
    "stops on an id"
  ),
  "Cross-Center Identity Matching" = c(
    "uses an id the table already", "only one of the two centers"
  ),
  "Longitudinal Monitoring" = c(
    "how many animals each date rests on", "stated animal-membership rule",
    "says which way each measure"
  )
)

test_that("new features keep their help-page detail out of the newest block", {
  for (file in c("NEWS.Rmd", "NEWS.md")) {
    lines <- sourceLines(file)
    for (home in names(newFeatureDetail)) {
      text <- plainText(newsSectionLines(lines, home))
      ## A section the reader cannot find would pass for the wrong reason.
      expect_gt(nchar(text), 0L, label = paste(file, home))
      for (phrase in newFeatureDetail[[home]]) {
        expect_false(grepl(phrase, text, fixed = TRUE),
                     info = paste(file, home, "still says:", phrase))
      }
    }
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

## The colour of an undefined Inbreeding cell (S937, BACKLOG.md:49). The
## Genetic Diversity dashboard scores a group whose Inbreeding metric is
## undefined (no breeding-age females) red, never gray: the assembler maps the
## undefined result to 1 (red), pinned by test_getGeneticDiversityStats.R
## ("undefined Inbreeding (no breeding-age females) scores red"), the same
## rule had been in the code since before 2.0.0, and the function's help and
## the colony-manager guide both say red. A Production entry in NEWS.Rmd said
## the new gray Production cell was "gray, as the Inbreeding cell already
## was". The two checkers below are tested on made-up sentences first, so the
## checks on the real file cannot pass by finding nothing.

## The sentences of one entry text; a sentence ends at a full stop followed by
## a space.
newsSentences <- function(text) {
  unlist(strsplit(text, "(?<=\\.)\\s+", perl = TRUE))
}

## The sentences that name the Inbreeding cell and call it gray (or "grey").
grayInbreedingSentences <- function(text) {
  s <- newsSentences(text)
  s[grepl("\\bInbreeding cells?\\b", s) &
      grepl("\\bgr[ae]y\\b", s, ignore.case = TRUE)]
}

## The sentences that say an undefined Inbreeding cell is red: they name the
## Inbreeding cell, say "red", and say "undefined" or "no breeding-age
## females".
redUndefinedInbreedingSentences <- function(text) {
  s <- newsSentences(text)
  s[grepl("\\bInbreeding cells?\\b", s) & grepl("\\bred\\b", s) &
      grepl("\\bundefined\\b|\\bno breeding-age females\\b", s)]
}

test_that("the Inbreeding-colour checkers fire on the wording they look for", {
  old <- paste("Production cannot be calculated for such a group, so its",
               "cell is now gray, as the Inbreeding cell already was.")
  expect_equal(length(grayInbreedingSentences(old)), 1L)
  expect_equal(length(grayInbreedingSentences(
    "The Inbreeding cell is Grey.")), 1L)
  ## Only the sentence that calls the Inbreeding cell gray is returned.
  expect_equal(grayInbreedingSentences(
    "The Value cell is red. The Inbreeding cell is gray. The rest is green."),
    "The Inbreeding cell is gray.")
  expect_equal(length(redUndefinedInbreedingSentences(
    "An undefined Inbreeding cell is red.")), 1L)
  expect_equal(length(redUndefinedInbreedingSentences(
    "The Inbreeding cell of a group with no breeding-age females is red.")),
    1L)
})

test_that("the Inbreeding-colour checkers stay silent on other wording", {
  expect_equal(length(grayInbreedingSentences(
    "An undefined Inbreeding cell is red.")), 0L)
  ## A gray Production cell is not a gray Inbreeding cell.
  expect_equal(length(grayInbreedingSentences(
    "Production cannot be calculated for such a group, so its cell is gray.")),
    0L)
  ## Gray in one sentence and the Inbreeding cell in the next.
  expect_equal(length(grayInbreedingSentences(
    "A group with no assessed value is gray. The Inbreeding cell is red.")),
    0L)
  ## Red without the Inbreeding cell, or without saying it is undefined.
  expect_equal(length(redUndefinedInbreedingSentences(
    "An undefined Production cell is red.")), 0L)
  expect_equal(length(redUndefinedInbreedingSentences(
    "The Inbreeding cell turns red when kinship is high.")), 0L)
  ## "red" inside another word does not count.
  expect_equal(length(redUndefinedInbreedingSentences(
    "An undefined Inbreeding cell is considered.")), 0L)
})

test_that("NEWS.Rmd never calls the Inbreeding cell gray", {
  path <- testthat::test_path("..", "..", "NEWS.Rmd")
  skip_if_not(file.exists(path), "NEWS.Rmd not present in this build")
  entries <- newsEntries(newsTopBlock(readLines(path, warn = FALSE)))
  expect_gt(nrow(entries), 0L)
  for (i in seq_len(nrow(entries))) {
    expect_equal(length(grayInbreedingSentences(entries$text[i])), 0L,
                 info = sprintf(
                   "the entry that starts at line %d calls the Inbreeding cell gray",
                   entries$line[i]))
  }
})

test_that("NEWS.Rmd says an undefined Inbreeding cell is red", {
  path <- testthat::test_path("..", "..", "NEWS.Rmd")
  skip_if_not(file.exists(path), "NEWS.Rmd not present in this build")
  entries <- newsEntries(newsTopBlock(readLines(path, warn = FALSE)))
  expect_gt(nrow(entries), 0L)
  said <- vapply(entries$text, function(x) {
    length(redUndefinedInbreedingSentences(x))
  }, integer(1L))
  expect_equal(sum(said), 1L,
               info = paste("entries that say an undefined Inbreeding cell",
                            "is red start at lines:",
                            paste(entries$line[said > 0L], collapse = ", ")))
})
