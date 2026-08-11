## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# De-Identified Pedigree Export -- Slice 1 (issue #150)
# Core, script-callable helper only. The Shiny module (modDeidentifiedExportUI/
# modDeidentifiedExportServer) ships in Slice 2 --
# docs/planning/issue150-deidentified-pedigree-export-plan.md sec 5.

#' Build the de-identified export's transformation manifest (D4)
#'
#' A "non-sensitive ... auditable" record of how a de-identified pedigree
#' export was produced: export timestamp, package version, the exact
#' \code{\link{obfuscatePed}} parameters used, the exported row count, and a
#' copy of the confirm-gate warning text shown to the curator. Deliberately
#' \strong{never} includes the id map (kept separate and locally-downloaded
#' per D5) or any raw pre-obfuscation value -- mirrors
#' \code{.buildCrossCenterMergeProvenance}'s shape
#' (\code{R/modCrossCenterIdentity.R}).
#'
#' @param pedRows the exported (already de-identified) pedigree data.frame --
#' only its row count is used.
#' @param size,maxDelta,linkedDateShift the \code{\link{obfuscatePed}}
#' parameters used to produce \code{pedRows}.
#' @param warningText the D6 institutional-responsibility warning text shown
#' at the confirm gate.
#' @return A one-row data.frame with columns \code{timestamp},
#' \code{packageVersion}, \code{size}, \code{maxDelta},
#' \code{linkedDateShift}, \code{nRows}, \code{warningText}.
#' @noRd
.buildDeidentificationManifest <- function(pedRows, size, maxDelta,
                                            linkedDateShift, warningText) {
  data.frame(
    timestamp = format(Sys.time()),
    packageVersion = getVersion(date = FALSE),
    size = size,
    maxDelta = maxDelta,
    linkedDateShift = linkedDateShift,
    nRows = nrow(pedRows),
    warningText = warningText,
    stringsAsFactors = FALSE
  )
}
