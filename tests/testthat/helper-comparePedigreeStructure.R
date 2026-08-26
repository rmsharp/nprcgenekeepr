## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Test-harness support for Track C of the kinship2 structural/topological
## comparison (docs/planning/pedigree-diagram-kinship2-structural-comparison-
## plan.md sections 3.4/4.3). These 2 functions have a GENUINE kinship2
## dependency (toKinship2Pedigree() calls kinship2::pedigree() directly) and
## so, per the plan's D-5, must never live in R/ package code. They live
## here rather than at the plan's literal "data-raw/kinship2FidelityValidation.R"
## suggestion because that script has hard top-level requireNamespace()
## stop()s for chromote/htmlwidgets that would break sourcing it from a test
## -- matching the project's own established data-raw/fgSEValidation.R +
## tests/testthat/helper-fgSEValidation.R split instead: harness functions
## live in a testthat helper (auto-loaded for the suite, real per-function
## test coverage); data-raw/kinship2FidelityValidation.R can source this
## file directly when Track D needs these functions for the vignette's own
## regeneration.
##
## Auto-loaded under test_dir()/test_local()/devtools::test() but NOT under
## test_file() -- source on demand (matches helper-fgSEValidation.R's own
## established pattern, test_fgSEValidation.R:26-28).
##
## Calls into R/ are explicitly `nprcgenekeepr:::`-prefixed throughout this
## file -- unlike test_comparePedigreeStructure.R's own bare-name calls to
## .extractKinship2Structure()/.extractNprcStructure() (that file IS their
## paired test file), this helper is an external caller, matching that same
## test file's own explicit-prefix treatment of makePedigreeMatingLayout()
## (defined in a different R/ file it doesn't own either).

## Auto-detects and swaps a reversed sire/dam row (plan D-5) before building
## a kinship2::pedigree() object. kinship2 enforces dadid=male/momid=female;
## nprcgenekeepr's own sire/dam columns carry no such constraint (a mating
## pair is symmetric in nprcgenekeepr -- e.g. the existing Track C fixture's
## own C2 row lists sire="Y" even though Y's sex is female, since
## nprcgenekeepr's mating-unit detection is symmetric in the pair). A row is
## "reversed" only when the sire column's own individual is female AND the
## dam column's own individual is male -- any other sex mismatch (e.g. both
## parents male) is a genuine data error, left for kinship2::pedigree()'s
## own validation to catch and report, never silently "fixed" here.
##
## @param ped a data.frame with id/sire/dam/sex columns (nprcgenekeepr's own
##   pedigree shape).
## @return a kinship2::pedigree() object.
toKinship2Pedigree <- function(ped) {
  if (!requireNamespace("kinship2", quietly = TRUE)) {
    stop("kinship2 must be installed locally to call toKinship2Pedigree() ",
      "(not a package dependency): install.packages(\"kinship2\")")
  }
  sire <- ped$sire
  dam <- ped$dam
  sexById <- stats::setNames(ped$sex, ped$id)
  sireSex <- unname(sexById[sire])
  damSex <- unname(sexById[dam])
  reversed <- !is.na(sire) & !is.na(dam) &
    !is.na(sireSex) & !is.na(damSex) &
    sireSex == "F" & damSex == "M"
  if (any(reversed)) {
    tmp <- sire[reversed]
    sire[reversed] <- dam[reversed]
    dam[reversed] <- tmp
  }
  kinship2::pedigree(id = ped$id, dadid = sire, momid = dam, sex = ped$sex)
}

## Which of pedK2's declared ids kinship2's own align.pedigree() actually
## places on the plot grid (found live 2026-08-26: a fully isolated
## individual -- no parents, never anyone's mate or parent -- is silently
## dropped from the grid even though it is one of pedigree()'s own declared
## `id` entries). `nid` is a matrix of 1-based row indices into pedK2$id (0
## for "not placed"); a duplicated individual (kinship2's own crossing-
## driven duplication, D-1) places the SAME id index at multiple grid
## positions, which unique() collapses back to one entry, same as any other
## individual.
##
## kinship2's own align.pedigree()/autohint() emits a benign internal
## message ("Unexpected result in autohint, please contact developer") on
## some multi-mate/duplicate-individual fixtures (confirmed directly on the
## existing Track C dogleg fixture, scratchpad-verified this session: the
## $nid placement result is still fully correct -- every declared id placed
## exactly once -- despite the warning). Muffled here, at the single call
## site, only after confirming it is exactly this known message; any other
## warning propagates normally.
##
## @param pedK2 a kinship2::pedigree() object (toKinship2Pedigree()'s
##   return value).
## @return character vector of ids, a subset of pedK2$id.
.kinship2DisplayedIds <- function(pedK2) {
  al <- withCallingHandlers(
    kinship2:::align.pedigree(pedK2),
    warning = function(w) {
      if (grepl("Unexpected result in autohint", conditionMessage(w),
                fixed = TRUE)) {
        invokeRestart("muffleWarning")
      }
    }
  )
  placedIdx <- sort(unique(floor(as.vector(al$nid[al$nid > 0]))))
  pedK2$id[placedIdx]
}

## Orchestrates the full cross-package comparison (plan section 3.4): builds
## both sides' structural extraction from the SAME nprcgenekeepr-format
## pedigree data.frame and diffs them via .comparePedigreeStructures()
## (Track C's own R/ deliverable, plan section 3.3). kinship2Struct's
## individuals is the actually-DISPLAYED subset (.kinship2DisplayedIds()),
## not merely pedK2's own declared id list -- found live 2026-08-26, see
## .kinship2DisplayedIds()'s own comment above.
##
## @param ped a data.frame with id/sire/dam/sex/gen columns.
## @return .comparePedigreeStructures()'s own return value.
compareAgainstKinship2 <- function(ped) {
  pedK2 <- toKinship2Pedigree(ped)
  kinship2Struct <- nprcgenekeepr:::.extractKinship2Structure(
    pedK2, displayedIds = .kinship2DisplayedIds(pedK2))
  nprcLayout <- nprcgenekeepr:::makePedigreeMatingLayout(ped,
    edgeStyle = "direct")
  nprcStruct <- nprcgenekeepr:::.extractNprcStructure(nprcLayout)
  nprcgenekeepr:::.comparePedigreeStructures(kinship2Struct, nprcStruct)
}

## Formats compareAgainstKinship2()'s own return value into a human-readable
## discrepancy report, or NULL (invisibly) when cmp$identical is TRUE.
## Extracted from data-raw/kinship2FidelityValidation.R's own local
## reportDiscrepancy() (found live 2026-08-26: that copy was never updated
## when .comparePedigreeStructures() gained individualsOnlyInA/
## individualsOnlyInB, so re-running the script on the article's own Track B
## full fixture printed "!! DISCREPANCY -- Track B full !!" with nothing
## underneath, silently omitting the one detail -- individualsOnlyInB: "P5"
## -- the identical = FALSE verdict is actually based on). Living here
## rather than in the data-raw/ script (which is explicitly excluded from R
## CMD check, and so was never exercised by any test) gives this reporting
## logic real, ongoing test coverage. Returns a character string, not a
## cat() side effect, specifically so its CONTENT is assertable -- the
## original's cat()-only form could not be tested at all, which is how the
## individuals-diff omission went unnoticed in the first place.
##
## @param label a short string identifying which comparison this is (e.g.
##   "Track B full"), included verbatim in the report.
## @param cmp compareAgainstKinship2()'s own return value.
## @return a single character string describing every populated diff field,
##   or NULL (invisibly) when cmp$identical is TRUE.
.formatStructuralDiscrepancy <- function(label, cmp) {
  if (isTRUE(cmp$identical)) {
    return(invisible(NULL))
  }
  lines <- sprintf("!! DISCREPANCY -- %s !!", label)
  if (nrow(cmp$parentChildOnlyInA) > 0L) {
    lines <- c(lines, "parent-child edges only in kinship2:",
      utils::capture.output(print(cmp$parentChildOnlyInA)))
  }
  if (nrow(cmp$parentChildOnlyInB) > 0L) {
    lines <- c(lines, "parent-child edges only in nprcgenekeepr:",
      utils::capture.output(print(cmp$parentChildOnlyInB)))
  }
  if (nrow(cmp$matePairsOnlyInA) > 0L) {
    lines <- c(lines, "mate pairs only in kinship2:",
      utils::capture.output(print(cmp$matePairsOnlyInA)))
  }
  if (nrow(cmp$matePairsOnlyInB) > 0L) {
    lines <- c(lines, "mate pairs only in nprcgenekeepr:",
      utils::capture.output(print(cmp$matePairsOnlyInB)))
  }
  if (length(cmp$individualsOnlyInA) > 0L) {
    lines <- c(lines, "individuals only in kinship2:",
      toString(cmp$individualsOnlyInA))
  }
  if (length(cmp$individualsOnlyInB) > 0L) {
    lines <- c(lines, "individuals only in nprcgenekeepr:",
      toString(cmp$individualsOnlyInB))
  }
  paste(lines, collapse = "\n")
}
