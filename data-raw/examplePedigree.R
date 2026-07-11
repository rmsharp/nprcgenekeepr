## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Adds a `fromCenter` (colony-origin) column to the bundled `examplePedigree`
#' data object (BACKLOG.md item, discovered S348 during Document 2's
#' screenshot capture; fixed S353). Without it, `getPotentialParents()` --
#' and the Shiny app's Potential Parents tab -- always degrade to an empty
#' result on `examplePedigree`, which is the single example dataset threaded
#' through every tab of the Colony Manager Guide walkthrough, so the
#' walkthrough could never show what a populated result looks like.
#'
#' `fromCenter` is derived, not fabricated, from two fields `examplePedigree`
#' already carries and already documents (`R/data.R`): `origin` ("the name of
#' the facility that the individual was imported from if other than local")
#' and `recordStatus` (`"original"` vs `"added"` placeholder second-parent
#' rows created during pedigree completion). An animal is marked
#' colony-born (`TRUE`) only when its origin is blank AND its record is
#' `"original"` -- i.e., a real, non-synthetic row with no recorded import
#' facility. Imported animals (non-blank `origin`) and synthetic placeholder
#' rows (`recordStatus == "added"`, which always carry `origin == NA`) are
#' marked `FALSE`: their true colony-origin status is not confirmed, not
#' merely unrecorded.
#'
#' Verified (S353): produces 2267 TRUE / 1427 FALSE, no NA, and
#' `getPotentialParents()` returns 1587 populated candidates against the
#' full example pedigree at minSireAge = minDamAge = 2,
#' maxGestationalPeriod = 210L -- confirming this is a genuine, non-degenerate
#' demonstration, not just a technically-present column. Idempotent:
#' re-running on an already-fixed object recomputes the same values.
#'
#' Run from the package root:
#'   Rscript data-raw/examplePedigree.R

## Load the current shipped object.
load(file.path("data", "examplePedigree.RData"))

examplePedigree$fromCenter <- (
  !is.na(examplePedigree$origin) & !nzchar(examplePedigree$origin) &
    examplePedigree$recordStatus == "original"
)

save(examplePedigree, file = file.path("data", "examplePedigree.RData"),
     compress = "xz")
