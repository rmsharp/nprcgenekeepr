## kinship2 Supplement Fidelity Validation -- Tracks A/B/C (Session 566)
##
## Generates the numeric and graphic evidence embedded in
## vignettes/articles/kinship2-fidelity-validation.qmd: for each of the 3
## tracks of the ratified kinship2 supplement full-reproduction plan
## (docs/planning/kinship2-supplement-full-reproduction-plan.md; Track C DONE
## S563, Track A DONE S564, Track B DONE S565), runs the SAME fixture through
## both nprcgenekeepr's new/changed function and the installed kinship2
## 1.9.6.2 directly, side by side -- not just re-quoting the hardcoded
## expected values already committed in tests/testthat/test_kinship.R,
## test_shrinkPedigree.R, and test_makePedigreeMatingLayout.R (though the 3
## fixtures below are reused verbatim from those files, matching their own
## verified-live provenance).
##
## Run from the package root (build-ignored; not part of R CMD check,
## matching data-raw/fgSEValidation.R's own convention):
##   Rscript data-raw/kinship2FidelityValidation.R
##
## Requires kinship2 installed LOCALLY -- NOT a package dependency (matches
## the established Track A/B/C precedent: kinship2 is used interactively for
## live cross-validation only, its results hardcoded into committed tests,
## never a Suggests dependency -- test_kinship.R/test_shrinkPedigree.R never
## call kinship2:: live either). install.packages("kinship2") to reproduce.
## Requires Chrome (chromote, an indirect Suggests dependency via
## shinytest2) to screenshot nprcgenekeepr's visNetwork pedigree diagrams to
## static PNG, matching vignettes/articles/pedigree-diagram-screenshots.R's
## own Chrome dependency.
##
## Writes PNGs to
## vignettes/articles/kinship2-fidelity-validation-img/*.png and prints a
## verification summary to the console. The tables/images embedded in
## vignettes/articles/kinship2-fidelity-validation.qmd are this script's
## printed/saved output, hand-transcribed -- matching fg-se-validation.qmd's
## own convention (see data-raw/fgSEValidation.R's header comment: "the
## table embedded in ... is this script's printed summary").

suppressMessages(pkgload::load_all(".", quiet = TRUE))
if (!requireNamespace("kinship2", quietly = TRUE)) {
  stop("kinship2 must be installed locally to run this script (not a ",
    "package dependency): install.packages(\"kinship2\")")
}
if (!requireNamespace("chromote", quietly = TRUE)) {
  stop("chromote must be installed locally to run this script (an ",
    "indirect Suggests dependency via shinytest2)")
}
if (!requireNamespace("htmlwidgets", quietly = TRUE)) {
  stop("htmlwidgets must be installed locally to run this script (an ",
    "indirect Suggests dependency via visNetwork)")
}

## Track D (plan section 4.4): compareAgainstKinship2()/toKinship2Pedigree()
## are test-harness functions with a genuine kinship2:: dependency, so they
## live in a testthat helper rather than R/ (plan D-5; see that file's own
## header comment for why they aren't inline here instead). Sourced on
## demand -- this script is not run under test_dir()/devtools::test(), so
## the helper's own auto-load-under-test_dir() note does not cover it.
# nolint start: undesirable_function_linter.
source(file.path("tests", "testthat", "helper-comparePedigreeStructure.R"))
# nolint end

## NOT named "..._files" -- that suffix is reserved by Quarto for a
## document's own knitr-generated output directory, and a pre-populated
## directory of that name collides with Quarto's render-time freezer/copy
## logic (confirmed hands-on: WalkError treating a plain PNG as a
## directory). Matches pedigree-diagram-screenshots.R's own plain
## (non-suffixed) SHOT_DIR convention.
outDir <- file.path("vignettes", "articles",
  "kinship2-fidelity-validation-img")
if (!dir.exists(outDir)) dir.create(outDir, recursive = TRUE)

## ---- Shared helpers -------------------------------------------------

## screenshot_layout(): render a makePedigreeMatingLayout() result via the
## SAME core visNetwork() call the app itself uses (R/modPedigree.R:611-614
## -- fixed x/y from the layout, physics off), save to a self-contained temp
## HTML file, and screenshot it via chromote (no live Shiny app needed, so
## shinytest2::AppDriver -- which pedigree-diagram-screenshots.R uses -- is
## overkill here; chromote directly is the minimal equivalent).
screenshot_layout <- function(layout, filename, width = 900L, height = 650L) {
  widget <- visNetwork::visNetwork(layout$nodes, layout$edges,
      width = width, height = height) |>
    visNetwork::visPhysics(enabled = FALSE) |>
    visNetwork::visNodes(physics = FALSE) |>
    visNetwork::visEdges(smooth = FALSE)
  tmpHtml <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(widget, tmpHtml, selfcontained = TRUE)
  b <- chromote::ChromoteSession$new()
  on.exit(b$close(), add = TRUE)
  ## Uses $go_to() rather than the separate Page$navigate()+
  ## Page$loadEventFired() calls it replaces: that 2-call sequence is a
  ## documented chromote race (rstudio/chromote#102 and the package's own
  ## "Loading a page reliably" vignette) -- the page can finish loading and
  ## fire its load event BEFORE Page$loadEventFired() registers a listener
  ## for it, so the second call then waits the full timeout_ for an event
  ## that already happened and will never fire again. $go_to() registers
  ## the listener before navigating, eliminating the race -- ported from
  ## PROJECT_LEARNINGS.md Learning 643 / tests/testthat/
  ## helper-live-render-positions.R, which fixed the identical pattern
  ## (found live only on windows-latest CI, invisible locally). $go_to()'s
  ## own `delay` parameter (seconds after the load event fires) replaces
  ## the separate Sys.sleep(1.5) call this used to make.
  b$go_to(paste0("file://", tmpHtml), delay = 1.5)
  b$screenshot(filename = file.path(outDir, filename), selector = "html")
  invisible(NULL)
}

maxAbsDiff <- function(a, b) max(abs(a - b), na.rm = TRUE)

cat("\n============================================================\n")
cat("Track A -- X-chromosome kinship (kinship2 supplement Table S2)\n")
cat("============================================================\n")

## Fixture verbatim from tests/testthat/test_kinship.R (Figure S1 subset,
## kinship2 supplement PDF).
fam1 <- data.frame(
  id   = as.character(1L:10L),
  sire = c(NA, NA, "1", "1", NA, NA, "3", "6", "6", "8"),
  dam  = c(NA, NA, "2", "2", NA, NA, "5", "4", "4", "7"),
  sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M", "F"),
  stringsAsFactors = FALSE
)
fam1$gen <- findGeneration(fam1$id, fam1$sire, fam1$dam)
twinsNprc <- data.frame(id1 = "8", id2 = "9", code = "MZ twin",
  stringsAsFactors = FALSE)

autoNprc <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
  twinRelations = twinsNprc)
xNprc <- kinship(fam1$id, fam1$sire, fam1$dam, fam1$gen,
  chrtype = "x", sex = fam1$sex, twinRelations = twinsNprc)

twinsK2 <- data.frame(id1 = "8", id2 = "9", code = 1L)
fam1PedK2 <- kinship2::pedigree(id = fam1$id, dadid = fam1$sire,
  momid = fam1$dam, sex = fam1$sex, relation = twinsK2)
autoK2 <- kinship2::kinship(fam1PedK2)
xK2 <- kinship2::kinship(fam1PedK2, chrtype = "X")

## Align kinship2's own id order back to fam1's order before differencing --
## pedigree() usually preserves input order for a single-family, parents-
## before-children fixture like this one, but align explicitly rather than
## assume.
ord <- match(fam1$id, rownames(autoK2))
autoK2 <- autoK2[ord, ord]
xK2 <- xK2[ord, ord]

cat("Full 10x10 autosomal matrix, max|nprcgenekeepr - kinship2|:",
  maxAbsDiff(autoNprc, autoK2), "\n")
cat("Full 10x10 X-linked matrix, max|nprcgenekeepr - kinship2|:  ",
  maxAbsDiff(xNprc, xK2), "\n")
cat("identical(autosomal, autosomal):", isTRUE(all.equal(autoNprc, autoK2)),
  "\n")
cat("identical(X-linked, X-linked):  ", isTRUE(all.equal(xNprc, xK2)), "\n")

heat <- function(mat, title) {
  image(seq_len(10L), seq_len(10L), t(mat[10L:1L, ]), axes = FALSE,
    xlab = "", ylab = "", main = title,
    col = hcl.colors(20L, "Blues", rev = TRUE))
  axis(1L, at = seq_len(10L), labels = colnames(mat), cex.axis = 0.7)
  axis(2L, at = seq_len(10L), labels = rev(rownames(mat)), cex.axis = 0.7,
    las = 1L)
}
png(file.path(outDir, "trackA-kinship-heatmaps.png"),
  width = 1000L, height = 1000L, res = 130L)
withr::with_par(list(mfrow = c(2L, 2L), mar = c(3L, 3L, 3L, 1L)), {
  heat(autoNprc, "nprcgenekeepr::kinship() -- autosomal")
  heat(autoK2, "kinship2::kinship() -- autosomal")
  heat(xNprc, "nprcgenekeepr::kinship(chrtype='x') -- X")
  heat(xK2, "kinship2::kinship(chrtype='X') -- X")
})
dev.off()
cat("wrote trackA-kinship-heatmaps.png\n")

cat("\n============================================================\n")
cat("Track B -- shrinkPedigree() vs kinship2::pedigree.shrink()\n")
cat("============================================================\n")

## Composite fixture verbatim from tests/testthat/test_shrinkPedigree.R
## (exercises every removal phase in one pedigree).
pedB <- data.frame(
  id   = c("P1", "P2", "P3", "P4", "P5", "P6",
           "C1", "C2", "C3", "C4", "C4a",
           "G3", "M1", "L1", "L2", "L3"),
  sire = c(NA, NA, NA, NA, NA, NA,
           "P1", "P1", "P1", "P3", "C4",
           NA, "P1", "M1", "M1", "M1"),
  dam  = c(NA, NA, NA, NA, NA, NA,
           "P2", "P2", "P2", "P4", "P6",
           NA, "P2", "G3", "G3", "G3"),
  ## sex is NOT part of test_shrinkPedigree.R's own fixture (shrinkPedigree()
  ## does not use it) -- added here only so kinship2::pedigree() can build a
  ## comparable object. Fixed to match every inherited sire/dam role in
  ## pedB's own sire/dam columns above (P1/P3/C4/M1 appear as sire => M;
  ## P2/P4/P6/G3 appear as dam => F); the remaining ids never appear as
  ## either, so their sex is unconstrained by the fixture and picked
  ## arbitrarily.
  sex  = c("M", "F", "M", "F", "F", "F",
           "F", "M", "F", "M", "F",
           "F", "M", "F", "M", "M"),
  stringsAsFactors = FALSE
)
genotypedB <- c(P1 = TRUE, P2 = TRUE, P3 = FALSE, P4 = FALSE, P5 = TRUE,
  P6 = TRUE, C1 = TRUE, C2 = FALSE, C3 = TRUE, C4 = TRUE, C4a = TRUE,
  G3 = FALSE, M1 = TRUE, L1 = TRUE, L2 = TRUE, L3 = TRUE)[pedB$id]
affectedB <- c(P1 = NA, P2 = NA, P3 = NA, P4 = NA, P5 = NA, P6 = NA,
  C1 = FALSE, C2 = NA, C3 = TRUE, C4 = TRUE, C4a = TRUE, G3 = NA,
  M1 = TRUE, L1 = NA, L2 = FALSE, L3 = TRUE)[pedB$id]

resultNprc <- shrinkPedigree(pedB, genotypedB, affected = affectedB,
  maxBits = 1L)

pedBK2 <- kinship2::pedigree(id = pedB$id, dadid = pedB$sire,
  momid = pedB$dam, sex = pedB$sex)
ordB <- match(pedB$id, pedBK2$id)
resultK2 <- kinship2::pedigree.shrink(pedBK2,
  avail = as.integer(genotypedB)[ordB],
  affected = as.integer(affectedB)[ordB], maxBits = 1L)

cat("nprcgenekeepr surviving ids: ",
  toString(sort(resultNprc$ped$id)), "\n")
cat("kinship2 surviving ids:      ",
  toString(sort(resultK2$pedObj$id)), "\n")
cat("Same surviving set:", setequal(resultNprc$ped$id, resultK2$pedObj$id),
  "\n")
cat("nprcgenekeepr bitSize trajectory:",
  paste(resultNprc$bitSize, collapse = " -> "), "\n")
cat("kinship2 bitSize trajectory:     ",
  paste(resultK2$bitSize, collapse = " -> "), "\n")

png(file.path(outDir, "trackB-kinship2-full.png"), width = 900L,
  height = 700L, res = 130L)
plot(pedBK2)
title("kinship2::pedigree() -- full (16 subjects)")
dev.off()
png(file.path(outDir, "trackB-kinship2-shrunk.png"), width = 900L,
  height = 700L, res = 130L)
plot(resultK2$pedObj)
title("kinship2::pedigree.shrink()$pedObj -- shrunk (8 subjects)")
dev.off()
cat("wrote trackB-kinship2-full.png, trackB-kinship2-shrunk.png\n")

pedB$gen <- findGeneration(pedB$id, pedB$sire, pedB$dam)
resultNprc$ped$gen <- findGeneration(resultNprc$ped$id, resultNprc$ped$sire,
  resultNprc$ped$dam)
layoutFullB <- makePedigreeMatingLayout(pedB)
layoutShrunkB <- makePedigreeMatingLayout(resultNprc$ped)
screenshot_layout(layoutFullB, "trackB-nprc-full.png")
screenshot_layout(layoutShrunkB, "trackB-nprc-shrunk.png")
cat("wrote trackB-nprc-full.png, trackB-nprc-shrunk.png\n")

cat("\n============================================================\n")
cat("Track C -- consanguineous-marker propagation (rectilinear dogleg)\n")
cat("============================================================\n")

## Fixture verbatim from tests/testthat/test_makePedigreeMatingLayout.R
## (Track C's own dogleg-propagation fixture, S563).
pedC <- data.frame(
  id   = c("P1", "P2", "A", "Y", "X", "W", "C1", "C2", "GC"),
  sire = c(NA, NA, "P1", "P1", NA, NA, "A", "Y", "A"),
  dam  = c(NA, NA, "P2", "P2", NA, NA, "X", "W", "Y"),
  sex  = c("M", "F", "M", "F", "F", "M", "F", "M", "M"),
  gen  = c(0L, 0L, 1L, 1L, 3L, 1L, 4L, 2L, 2L),
  stringsAsFactors = FALSE
)
## kinship2::pedigree() strictly validates dadid = male / momid = female;
## nprcgenekeepr's own sire/dam columns carry no such constraint (the
## original test fixture lists sire = "Y" for C2 even though Y's own sex is
## "F", since nprcgenekeepr's mating-unit detection is symmetric in the
## pair, not sex-role-sensitive). Swap C2's 2 parent-column values (same 2
## parents, same family structure -- Y x W is unaffected as a pair) for the
## kinship2-side object only; pedC itself (used for every nprcgenekeepr call
## below) is left exactly as the committed test fixture has it.
pedCK2Df <- pedC
c2Row <- pedCK2Df$id == "C2"
tmp <- pedCK2Df$sire[c2Row]
pedCK2Df$sire[c2Row] <- pedCK2Df$dam[c2Row]
pedCK2Df$dam[c2Row] <- tmp
pedCK2 <- kinship2::pedigree(id = pedCK2Df$id, dadid = pedCK2Df$sire,
  momid = pedCK2Df$dam, sex = pedCK2Df$sex)
png(file.path(outDir, "trackC-kinship2.png"), width = 900L, height = 700L,
  res = 130L)
plot(pedCK2)
title("kinship2::pedigree() -- A x Y consanguineous (doubled line)")
dev.off()
cat("wrote trackC-kinship2.png\n")

layoutDirectC <- makePedigreeMatingLayout(pedC, edgeStyle = "direct")
layoutRectC <- makePedigreeMatingLayout(pedC, edgeStyle = "rectilinear")
screenshot_layout(layoutDirectC, "trackC-nprc-direct.png")
screenshot_layout(layoutRectC, "trackC-nprc-rectilinear.png")
cat("wrote trackC-nprc-direct.png, trackC-nprc-rectilinear.png\n")

## Guard explicitly against NA: most edges have color = NA (unmarked), and
## `NA == "#D55E00"` is NA, not FALSE -- naive `[cond, ]` indexing would keep
## an all-NA row per NA edge instead of dropping it (confirmed hands-on: an
## earlier %in%-based version silently inflated the count from 2/3 to 14/10
## this exact way; %in% has the same defect for an NA left-hand side).
isMarked <- function(edges) {
  !is.na(edges$color) & edges$color == "#D55E00"
}
consangEdgesDirect <- layoutDirectC$edges[isMarked(layoutDirectC$edges), ]
consangEdgesRect <- layoutRectC$edges[isMarked(layoutRectC$edges), ]
cat("direct-style marked edges:     ", nrow(consangEdgesDirect), "\n")
cat("rectilinear-style marked edges:", nrow(consangEdgesRect), "\n")

cat("\n============================================================\n")
cat("Track D -- structural comparison against kinship2 (plan section 4.4)\n")
cat("============================================================\n")

## compareAgainstKinship2() (tests/testthat/helper-comparePedigreeStructure.R,
## sourced above) runs THIS article's own Track B/C fixtures through
## .extractKinship2Structure()/.extractNprcStructure()/
## .comparePedigreeStructures() (Track C, R/comparePedigreeStructure.R) --
## the first time any code has diffed these plots' underlying structure
## against kinship2's own pedigree object, rather than placing 2
## independently-rendered images side by side and asserting a visual match.
cmpBFull <- compareAgainstKinship2(pedB)
cmpBShrunk <- compareAgainstKinship2(resultNprc$ped)
cmpC <- compareAgainstKinship2(pedC)

cat("Track B full (16 subjects)   structurally identical to kinship2:",
  cmpBFull$identical, "\n")
cat("Track B shrunk (8 subjects)  structurally identical to kinship2:",
  cmpBShrunk$identical, "\n")
cat("Track C (9 subjects, dogleg) structurally identical to kinship2:",
  cmpC$identical, "\n")

## If any comparison finds a real discrepancy, print it in full rather than
## just the boolean -- a diff staying uncaught here would otherwise be
## silently swallowed by the summary cat() calls above.
## .formatStructuralDiscrepancy() (tests/testthat/helper-
## comparePedigreeStructure.R, sourced above) replaces this script's own
## former local reportDiscrepancy() copy (found live 2026-08-26: that copy
## was never updated when individualsOnlyInA/individualsOnlyInB were added
## to compareAgainstKinship2()'s return shape, so it silently omitted the
## one detail -- individualsOnlyInB: "P5" -- the Track B full identical =
## FALSE verdict is actually based on; this script has no test coverage of
## its own, being explicitly excluded from R CMD check, so the gap went
## unnoticed until an owner-directed live rerun caught it).
reportDiscrepancy <- function(label, cmp) {
  report <- .formatStructuralDiscrepancy(label, cmp)
  if (!is.null(report)) cat("\n", report, "\n", sep = "")
}
reportDiscrepancy("Track B full", cmpBFull)
reportDiscrepancy("Track B shrunk", cmpBShrunk)
reportDiscrepancy("Track C", cmpC)

cat("\nDone. Images written to", outDir, "\n")
