## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Compare two colony snapshots metric by metric
#'
#' Computes per-metric deltas between two snapshots of a longitudinal colony
#' snapshot history (issue #167). The two snapshots must belong to the same
#' membership-rule series: a snapshot is identified by its
#' (\code{snapshotDate}, \code{membershipRule}) pair, and trend comparisons
#' are only meaningful like with like. The result carries one row per
#' numeric schema column — the 18 metric columns plus the 3 composition
#' counts (\code{nAnimals}, \code{nMales}, \code{nFemales}), whose deltas
#' make membership churn between the two snapshots visible.
#'
#' The \code{comparabilityFlag} column surfaces provenance differences
#' between the two snapshots rather than refusing them: it is
#' \code{NA_character_} when the snapshots are comparable and otherwise
#' names each differing provenance field with both values. A
#' \code{guIter} difference flags the gene-drop-derived metrics
#' (\code{fg}, \code{fgSE}, \code{neGD}, and the \code{gu} aggregates); a
#' \code{guThresh} difference flags only the \code{gu} aggregates (the
#' threshold reaches only the genome-uniqueness computation); a
#' \code{packageVersion} difference flags every row.
#'
#' @param history data.frame holding the snapshot history in the 27-column
#' version-1 schema; validated internally with
#' \code{\link{checkSnapshotHistory}}.
#' @param from character or \code{Date}; the \code{snapshotDate} of the
#' baseline snapshot.
#' @param to character or \code{Date}; the \code{snapshotDate} of the
#' comparison snapshot.
#' @param membershipRule character; the membership-rule series the two
#' dates belong to. The default \code{NULL} resolves automatically when the
#' history holds a single rule and \code{stop()}s, naming the rules
#' present, when it holds several.
#' @return A data.frame with columns \code{metric}, \code{from}, \code{to},
#' \code{delta} (\code{to - from}), and \code{comparabilityFlag}, one row
#' per numeric schema column in schema order.
#' @export
#' @examples
#' history <- checkSnapshotHistory(readSnapshotHistory(system.file("extdata",
#'   "examples", "example_snapshot_history.csv",
#'   package = "nprcgenekeepr"
#' )))
#' deltas <- calcSnapshotDeltas(history,
#'   from = "2025-01-15", to = "2025-07-15",
#'   membershipRule = "wholePedigree"
#' )
calcSnapshotDeltas <- function(history, from, to, membershipRule = NULL) {
  history <- checkSnapshotHistory(history)
  rules <- unique(history$membershipRule)
  if (is.null(membershipRule)) {
    if (length(rules) > 1L) {
      stop("Snapshot history holds several membershipRule values (",
        toString(rules), "); pass 'membershipRule' to pick the series ",
        "to compare.")
    }
    membershipRule <- rules
  }
  if (!membershipRule %in% rules) {
    stop("Snapshot history holds no '", membershipRule,
      "' snapshots; rules present: ", toString(rules), ".")
  }
  from <- as.Date(as.character(from), format = "%Y-%m-%d")
  to <- as.Date(as.character(to), format = "%Y-%m-%d")
  if (is.na(from) || is.na(to)) {
    stop("'from' and 'to' must be ISO-8601 (YYYY-MM-DD) dates.")
  }
  if (from == to) {
    stop("'from' and 'to' must name two different snapshots.")
  }
  series <- history[history$membershipRule == membershipRule, , drop = FALSE]
  fromRow <- series[series$snapshotDate == from, , drop = FALSE]
  if (nrow(fromRow) == 0L) {
    stop("No '", membershipRule, "' snapshot exists on ", format(from), ".")
  }
  toRow <- series[series$snapshotDate == to, , drop = FALSE]
  if (nrow(toRow) == 0L) {
    stop("No '", membershipRule, "' snapshot exists on ", format(to), ".")
  }
  metrics <- c(
    "nAnimals", "nMales", "nFemales",
    "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
    "nMaleFounders", "nFemaleFounders", "nFounders",
    "meanIndivMeanKin", "medianIndivMeanKin", "skewnessIndivMeanKin",
    "kurtosisIndivMeanKin", "meanGu", "medianGu", "meanGuSE",
    "skewnessGu", "kurtosisGu"
  )
  fromValues <- unlist(fromRow[1L, metrics], use.names = FALSE)
  toValues <- unlist(toRow[1L, metrics], use.names = FALSE)
  data.frame(
    metric = metrics,
    from = as.numeric(fromValues),
    to = as.numeric(toValues),
    delta = as.numeric(toValues) - as.numeric(fromValues),
    comparabilityFlag = snapshotComparabilityFlags(fromRow, toRow, metrics),
    stringsAsFactors = FALSE
  )
}

#' Per-metric D4 comparability flags between two snapshot rows
#'
#' \code{guIter} sizes the gene drop whose alleles feed both
#' \code{calcFEFG()} (\code{fg}, \code{fgSE}, and \code{neGD} via
#' \code{calcGeneDiversity(FG)}) and \code{calcGU()}; \code{guThresh}
#' reaches only \code{calcGU()}; a \code{packageVersion} change can move
#' any metric.
#'
#' @param fromRow one-row data.frame; the baseline snapshot.
#' @param toRow one-row data.frame; the comparison snapshot.
#' @param metrics character vector of metric names being compared.
#' @return character vector along \code{metrics}: \code{NA_character_}
#' where comparable, otherwise the differing provenance fields with both
#' values.
#' @noRd
snapshotComparabilityFlags <- function(fromRow, toRow, metrics) {
  guIterAffected <- c(
    "fg", "fgSE", "neGD",
    "meanGu", "medianGu", "meanGuSE", "skewnessGu", "kurtosisGu"
  )
  guThreshAffected <- c(
    "meanGu", "medianGu", "meanGuSE", "skewnessGu", "kurtosisGu"
  )
  guIterReason <- if (fromRow$guIter != toRow$guIter) {
    paste0("guIter differs: ", fromRow$guIter, " vs ", toRow$guIter)
  }
  guThreshReason <- if (fromRow$guThresh != toRow$guThresh) {
    paste0("guThresh differs: ", fromRow$guThresh, " vs ", toRow$guThresh)
  }
  packageReason <- if (!identical(fromRow$packageVersion,
                                  toRow$packageVersion)) {
    paste0("packageVersion differs: ", fromRow$packageVersion, " vs ",
      toRow$packageVersion)
  }
  vapply(metrics, function(metric) {
    reasons <- character(0L)
    if (!is.null(guIterReason) && metric %in% guIterAffected) {
      reasons <- c(reasons, guIterReason)
    }
    if (!is.null(guThreshReason) && metric %in% guThreshAffected) {
      reasons <- c(reasons, guThreshReason)
    }
    if (!is.null(packageReason)) {
      reasons <- c(reasons, packageReason)
    }
    if (length(reasons) == 0L) {
      NA_character_
    } else {
      paste(reasons, collapse = "; ")
    }
  }, character(1L), USE.NAMES = FALSE)
}
