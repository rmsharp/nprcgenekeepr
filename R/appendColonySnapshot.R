## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Append a colony snapshot to a snapshot history
#'
#' Pure merge for the longitudinal colony snapshot workflow (issue #167):
#' takes a validated snapshot history (or \code{NULL} / a zero-row history for
#' a first snapshot) and one new snapshot row, and returns the merged,
#' date-ordered history. It writes nothing — script users persist the result
#' themselves (e.g. \code{write.csv(..., row.names = FALSE)}), and the Shiny
#' application writes only through a user-initiated download.
#'
#' The new snapshot must carry the same \code{schemaVersion} as the history,
#' and its (\code{snapshotDate}, \code{membershipRule}) pair must not already
#' be present — the pair identifies a snapshot uniquely. The same date under
#' a different membership rule is legal.
#'
#' @param history validated snapshot history data.frame (see
#' \code{\link{checkSnapshotHistory}}), or \code{NULL} / a zero-row history
#' when recording the first snapshot.
#' @param snapshot one-row data.frame holding the new snapshot, in the same
#' schema as the history.
#' @return The merged history, ordered by \code{snapshotDate}.
#' @export
#' @examples
#' history <- checkSnapshotHistory(readSnapshotHistory(system.file(
#'   "extdata", "examples", "example_snapshot_history.csv",
#'   package = "nprcgenekeepr"
#' )))
#' snapshot <- history[3L, ]
#' snapshot$snapshotDate <- as.Date("2026-07-15")
#' appendColonySnapshot(history, snapshot)
appendColonySnapshot <- function(history, snapshot) {
  if (is.null(history) || nrow(history) == 0L) {
    merged <- if (is.null(history)) snapshot else rbind(history, snapshot)
  } else {
    mismatched <- setdiff(
      unique(snapshot$schemaVersion),
      unique(history$schemaVersion)
    )
    if (length(mismatched) > 0L) {
      stop("Snapshot 'schemaVersion' (", toString(mismatched),
        ") does not match the history's schemaVersion (",
        toString(unique(history$schemaVersion)), ").")
    }
    pairKey <- function(rows) {
      paste(as.character(rows$snapshotDate), rows$membershipRule, sep = "\r")
    }
    dupPair <- pairKey(snapshot) %in% pairKey(history)
    if (any(dupPair)) {
      stop("Snapshot history already contains the duplicated (snapshotDate, ",
        "membershipRule) pair: ",
        gsub("\r", " ", pairKey(snapshot)[dupPair][1L], fixed = TRUE), ".")
    }
    merged <- rbind(history, snapshot)
  }
  merged <- merged[order(merged$snapshotDate), , drop = FALSE]
  rownames(merged) <- NULL
  merged
}
