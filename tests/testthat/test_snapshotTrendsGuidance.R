## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md:237 (S1070; owner-requested S1069, picked at the S1070 Phase 0
## picker): no document said what a colony manager can learn from the
## Genetic-Health trend. Owner rulings (S1070): one text in one file,
## inst/extdata/ui_guidance/snapshot_trends.html, shown both in a box under
## the trend chart on the Trends sub-tab and in the colony manager's guide
## after step 4 ("App box + guide, one text"); it answers which way each panel
## moves, when a change is real and what a past trend can answer (not a target
## from the literature); the owner approved the sentences below as written.
##
## What the sentences rest on (S1070): the panel titles are the metric column
## names (R/plotSnapshotTrends.R facets by them); the band is one standard
## error on each side and only fg and meanGu have one; a provenance change is
## drawn with another point shape and named in the caption; fe, the founder
## counts, the effective sizes and the kinship aggregates are deterministic;
## the app and the rebuild both trim to the population and its ancestors
## (trimToAnalysisPopulation(), removeUninformative = FALSE), so the founder
## counts are the known founders there; an unrelated import with no offspring
## left fe at 2.909 on lacy1989Ped and raised it to 3.390 once it had one.

## sourceLines(), plainText(), chunkCode() and expectNames() are in
## helper-pageText.R.
guidancePageLines <- function() {
  path <- system.file("extdata", "ui_guidance", "snapshot_trends.html",
                      package = "nprcgenekeepr")
  if (!nzchar(path)) {
    return(character(0L))
  }
  readLines(path, warn = FALSE)
}

sectionLabels <- c(
  "Which way each panel moves", "When a change is real",
  "What a past trend can answer"
)

approvedSentences <- c(
  "Each panel is one measure, titled with its column name in the snapshot history.",
  paste("Each color is one membership rule; the dashed line is snapshots",
        "rebuilt from studbook dates."),
  paste("fe, fg and neGD (founder equivalents, founder genome equivalents and",
        "gene diversity): higher means more of the founders' diversity is still",
        "in the colony."),
  paste("fe falls when the founders' contributions grow more unequal; fg and",
        "neGD also fall when founder alleles are lost by chance."),
  "neGD is a share between 0 and 1, not a number of animals.",
  paste("nFounders, nMaleFounders and nFemaleFounders: the known founders",
        "(animals with no recorded parents) among the analyzed animals and",
        "their ancestors."),
  paste("They rise when such an animal joins, an import for example; in a",
        "series of living animals they also fall when a founder and all its",
        "descendants have left."),
  paste("neSexRatio and neVariance (the sex-ratio and variance effective",
        "sizes, counted over the living breeders): higher means less diversity",
        "is lost each generation."),
  paste("neSexRatio falls when breeding relies on few animals of one sex;",
        "neVariance falls when a few breeders produce most of the offspring."),
  "Read each as an index, not a head count.",
  paste("meanIndivMeanKin and medianIndivMeanKin: the colony's average and",
        "median of each animal's mean kinship."),
  paste("A rise means the animals are, on average, more closely related to",
        "the rest of the colony."),
  "meanGu and medianGu (genome uniqueness): neither direction is better.",
  paste("They fall when a rare founder allele is lost, and also when breeding",
        "spreads it into more animals, so a fall alone is not a loss; fg and",
        "neGD show loss."),
  paste("The skewness and kurtosis panels: the shape of the spread across",
        "animals, not a measure of health."),
  paste("Positive skewness means a few animals with unusually high values",
        "stretch the upper tail."),
  paste("fgSE and meanGuSE: how precise fg and meanGu are, not how healthy",
        "the colony is."),
  "They shrink when more gene-drop iterations are run.",
  paste("The grey band around fg and meanGu spans one standard error on each",
        "side of each point."),
  "A change smaller than the bands can come from the random sampling alone.",
  paste("fe, the founder counts, the effective sizes and the mean-kinship",
        "panels have no band because they are calculated without random",
        "sampling: a change in them is a change in the records."),
  paste("The other genome-uniqueness panels have no band but come from the",
        "same sampling as meanGu."),
  paste("A point drawn with a different shape was taken with different",
        "settings (the number of gene-drop iterations, the rare-allele",
        "threshold or the package version) than the point before it, and the",
        "caption names the change; a jump there may come from the settings,",
        "not the colony."),
  paste("How fast founder diversity is being lost: the slope of fg and neGD",
        "across the years."),
  paste("Whether an import or a change in breeding shows: an unrelated import",
        "with no recorded parents lowers mean kinship and raises the founder",
        "counts as soon as it is in the population, and raises fe and fg once",
        "it has offspring there."),
  paste("A change in breeding practice shows as a change of slope from that",
        "year on, for example a fall in neSexRatio when fewer sires are used."),
  paste("A baseline: rebuilt years let today's snapshot of the living animals",
        "be read against the colony's past instead of alone.")
)

## The rendered markup of one sub-tab of modSnapshotTrendsUI(): from its
## tab-pane div to the next one (or the end).
tabPaneHtml <- function(html, title) {
  at <- regexpr(paste0('<div class="tab-pane" data-value="', title, '"'),
                html, fixed = TRUE)
  if (at < 0L) {
    return("")
  }
  starts <- gregexpr('<div class="tab-pane"', html, fixed = TRUE)[[1L]]
  after <- starts[starts > at]
  substr(html, at, if (length(after) > 0L) after[1L] - 1L else nchar(html))
}

test_that("the trend guidance page holds the approved text", {
  text <- plainText(guidancePageLines(), html = TRUE)

  expectNames(text, c(sectionLabels, approvedSentences),
              where = "snapshot_trends.html:")
})

test_that("every panel the trend chart draws by default is explained", {
  ## a panel added to trendDefaultMetrics must get its own line on the page
  text <- plainText(guidancePageLines(), html = TRUE)
  sharedLine <- grepl("The skewness and kurtosis panels", text, fixed = TRUE)

  for (metric in trendDefaultMetrics) {
    named <- grepl(paste0("(?<![A-Za-z])", metric, "(?![A-Za-z])"), text,
                   perl = TRUE)
    if (grepl("^(skewness|kurtosis)", metric)) named <- named || sharedLine
    expect_true(named, info = metric)
  }
})

test_that("the Trends sub-tab shows the guidance under the chart", {
  html <- as.character(modSnapshotTrendsUI("test"))
  pane <- tabPaneHtml(html, "Trends")
  paneText <- plainText(pane, html = TRUE)

  expect_true(grepl("test-trendPlot", pane, fixed = TRUE))
  expectNames(paneText, c("Reading the trend", sectionLabels, approvedSentences),
              where = "Trends sub-tab:")
  ## the box sits below the chart
  plotAt <- regexpr("test-trendPlot", pane, fixed = TRUE)[[1L]]
  headingAt <- regexpr("Reading the trend", pane, fixed = TRUE)[[1L]]
  expect_true(plotAt > 0L && headingAt > plotAt)
})

test_that("the app box and the guide both read the one file, no copy", {
  guide <- sourceLines("vignettes", "articles", "colony-manager-guide.qmd")
  module <- plainSource("R", "modSnapshotTrends.R")

  step4 <- grep("^4\\. \\*\\*Build Earlier Snapshots\\.\\*\\*", guide)
  heading <- which(guide == "#### Reading the trend")
  conclusion <- grep("^## Conclusion", guide)
  expect_length(heading, 1L)
  expect_true(length(heading) == 1L && heading > step4 && heading < conclusion)

  chunk <- chunkCode(guide, "trend-guidance")
  expect_false(is.null(chunk))
  chunkStart <- grep("^#\\| label: trend-guidance$", guide)
  expect_true(length(chunkStart) == 1L && length(heading) == 1L &&
                chunkStart > heading && chunkStart < conclusion)
  chunkText <- paste(chunk, collapse = " ")
  expectNames(chunkText, c("snapshot_trends.html", "includeHTML"),
              where = "guide chunk:")
  expectNames(module, "snapshot_trends.html", where = "R/modSnapshotTrends.R:")

  guideText <- plainText(guide)
  for (sentence in approvedSentences) {
    expect_false(grepl(sentence, guideText, fixed = TRUE), info = sentence)
    expect_false(grepl(sentence, module, fixed = TRUE), info = sentence)
  }
})
