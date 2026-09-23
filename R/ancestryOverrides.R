## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Ancestry guardrails -- override + audit-manifest primitives (issue #168
# Slice 3, plan sec 5 / D4). Script-callable internals behind the Slice 4
# confirm gate: an override is per-rule and per-run, needs a stated reason,
# and never makes a rule's violations silently disappear; the manifest is
# the run's downloadable audit record (the .buildDeidentificationManifest
# mold, R/modDeidentifiedExport.R).

# The owner-ratified confirm-gate wording. Shown in the Slice 4 override
# modal and copied verbatim into every manifest row; change it only through
# owner ratification.
.ancestryOverrideWarningText <- paste(
  "Overriding this ancestry rule lets group formation place animals",
  "together that the rule would otherwise keep apart, for this run only.",
  "The rule stays in your rules file, and every pairing it matches is",
  "still reported, marked \"overridden\". Your stated reason is saved in",
  "the downloadable audit manifest. Confirming that this override fits",
  "your colony's genetic-management and research commitments is your",
  "responsibility, not this tool's."
)

#' Canonical key for an unordered pair of ancestry levels
#'
#' Must stay identical to the \code{rule} strings
#' \code{\link{reportAncestryViolations}} emits (sorted \code{"LO-HI"}), so
#' manifest pair counts match the report's rows.
#'
#' @param a,b character vectors of uppercase ancestry levels.
#' @return character vector of \code{"LEVEL-LEVEL"} keys.
#' @noRd
.ancestryPairKey <- function(a, b) {
  paste(pmin(a, b), pmax(a, b), sep = "-")
}

#' Validate the ancestry-rule overrides for one formation run
#'
#' Each override names one \code{block} rule present in \code{rules}
#' (unordered, case-insensitive match) and carries a non-empty free-text
#' reason (D4). Flag rules never block formation, so an override of one
#' would record a decision that changes nothing -- it is rejected.
#'
#' @param overrides \code{NULL}, or a data frame with columns
#' \code{ancestry1}, \code{ancestry2}, and \code{reason}. \code{NULL} or
#' zero rows means no overrides.
#' @param rules ancestry rules table; validated via
#' \code{\link{checkAncestryRules}}.
#' @return data.frame with exactly the columns \code{ancestry1},
#' \code{ancestry2} (uppercase character) and \code{reason} (trimmed
#' character); zero rows when there are no overrides.
#' @noRd
.checkAncestryOverrides <- function(overrides, rules) {
  rules <- checkAncestryRules(rules)
  empty <- data.frame(
    ancestry1 = character(0L), ancestry2 = character(0L),
    reason = character(0L), stringsAsFactors = FALSE
  )
  if (is.null(overrides)) {
    return(empty)
  }
  required <- c("ancestry1", "ancestry2", "reason")
  missingCols <- setdiff(required, names(overrides))
  if (length(missingCols) > 0L) {
    stop("nprcgenekeepr: overrides must have columns ",
      toString(required), "; missing: ", toString(missingCols), ".",
      call. = FALSE
    )
  }
  if (nrow(overrides) == 0L) {
    return(empty)
  }
  a1 <- toupper(trimws(as.character(overrides$ancestry1)))
  a2 <- toupper(trimws(as.character(overrides$ancestry2)))
  reason <- trimws(as.character(overrides$reason))
  if (anyNA(reason) || !all(nzchar(reason))) {
    stop("nprcgenekeepr: every override needs a non-empty reason.",
      call. = FALSE
    )
  }
  key <- .ancestryPairKey(a1, a2)
  ruleKey <- .ancestryPairKey(rules$ancestry1, rules$ancestry2)
  missingRules <- setdiff(key, ruleKey)
  if (length(missingRules) > 0L) {
    stop("nprcgenekeepr: overrides name rule(s) not present in rules: ",
      toString(missingRules), ".",
      call. = FALSE
    )
  }
  flagRules <- key[rules$severity[match(key, ruleKey)] == "flag"]
  if (length(flagRules) > 0L) {
    stop("nprcgenekeepr: only block rules can be overridden; flag ",
      "rule(s) never block formation: ", toString(flagRules), ".",
      call. = FALSE
    )
  }
  if (anyDuplicated(key) > 0L) {
    stop("nprcgenekeepr: overrides contain duplicated (unordered) ",
      "rule(s): ", toString(unique(key[duplicated(key)])), ".",
      call. = FALSE
    )
  }
  data.frame(
    ancestry1 = a1, ancestry2 = a2, reason = reason,
    stringsAsFactors = FALSE
  )
}

#' The ancestry rules enforced for one formation run
#'
#' Downgrades each overridden rule to \code{flag}: blocking stops for this
#' run, but the rule's levels stay named, so the D6 UNKNOWN/OTHER check in
#' \code{\link{checkAncestryRules}} sees the same vocabulary it saw before
#' the override. Pass the result to \code{groupAddAssign(ancestryRules =)};
#' report with the ORIGINAL rules plus \code{overriddenRules}, so the
#' overridden rule's pairs appear with status \code{"overridden"}.
#'
#' @param rules ancestry rules table; validated via
#' \code{\link{checkAncestryRules}}.
#' @param overrides overrides as accepted by \code{.checkAncestryOverrides}.
#' @return The validated \code{rules} with each overridden rule's
#' \code{severity} set to \code{"flag"}; unchanged when there are no
#' overrides.
#' @noRd
.effectiveAncestryRules <- function(rules, overrides) {
  rules <- checkAncestryRules(rules)
  overrides <- .checkAncestryOverrides(overrides, rules)
  if (nrow(overrides) == 0L) {
    return(rules)
  }
  ruleKey <- .ancestryPairKey(rules$ancestry1, rules$ancestry2)
  overrideKey <- .ancestryPairKey(overrides$ancestry1, overrides$ancestry2)
  rules$severity[ruleKey %in% overrideKey] <- "flag"
  rules
}

#' Build the ancestry-override audit manifest for one formation run (D4)
#'
#' One row per rule in \code{rules} -- the rule is the unit a curator
#' overrides -- recording the rule as written, whether it was overridden
#' and why, and how many within-group pairs it matched. Run-level fields
#' (timestamp, package version, the animal census by ancestry level, the
#' override summary, and a verbatim copy of the confirm-gate warning) are
#' repeated on every row, so each row of the downloaded CSV stands alone.
#'
#' @param rules ancestry rules table in effect (as written, before any
#' override); validated via \code{\link{checkAncestryRules}}.
#' @param overrides overrides as accepted by \code{.checkAncestryOverrides}.
#' @param report the list returned by \code{\link{reportAncestryViolations}}
#' for the run's formed groups.
#' @param warningText the confirm-gate warning text shown to the curator.
#' @return A data.frame with columns \code{timestamp},
#' \code{packageVersion}, \code{ancestry1}, \code{ancestry2},
#' \code{severity}, \code{overridden}, \code{reason} (\code{NA} unless
#' overridden), \code{nPairs}, \code{nChinese}, \code{nIndian},
#' \code{nHybrid}, \code{nJapanese}, \code{nOther}, \code{nUnknown},
#' \code{nUncovered} (animals at levels no rule names),
#' \code{overrideSummary}, and \code{warningText}.
#' @noRd
.buildAncestryOverrideManifest <- function(rules, overrides, report,
                                           warningText) {
  rules <- checkAncestryRules(rules)
  if (nrow(rules) == 0L) {
    stop("nprcgenekeepr: no rules in effect; an ancestry override ",
      "manifest has nothing to record.",
      call. = FALSE
    )
  }
  overrides <- .checkAncestryOverrides(overrides, rules)
  if (!is.list(report) ||
    !all(c("violations", "coverage") %in% names(report))) {
    stop("nprcgenekeepr: report must be the list returned by ",
      "reportAncestryViolations(), with elements 'violations' and ",
      "'coverage'.",
      call. = FALSE
    )
  }
  if (!is.character(warningText) || length(warningText) != 1L ||
    is.na(warningText) || !nzchar(warningText)) {
    stop("nprcgenekeepr: warningText must be the non-empty confirm-gate ",
      "warning text.",
      call. = FALSE
    )
  }

  ruleKey <- .ancestryPairKey(rules$ancestry1, rules$ancestry2)
  overrideKey <- .ancestryPairKey(overrides$ancestry1, overrides$ancestry2)
  nPairs <- unname(vapply(
    ruleKey, function(k) sum(report$violations$rule == k), integer(1L)
  ))
  coverage <- report$coverage
  census <- function(level) {
    as.integer(sum(coverage$n[coverage$ancestry == level]))
  }
  overrideSummary <- if (nrow(overrides) == 0L) {
    "No rules were overridden for this run."
  } else {
    sprintf(
      "%d of %d rules overridden for this run.",
      nrow(overrides), nrow(rules)
    )
  }

  data.frame(
    timestamp = format(Sys.time()),
    packageVersion = getVersion(date = FALSE),
    ancestry1 = rules$ancestry1,
    ancestry2 = rules$ancestry2,
    severity = rules$severity,
    overridden = ruleKey %in% overrideKey,
    reason = overrides$reason[match(ruleKey, overrideKey)],
    nPairs = nPairs,
    nChinese = census("CHINESE"),
    nIndian = census("INDIAN"),
    nHybrid = census("HYBRID"),
    nJapanese = census("JAPANESE"),
    nOther = census("OTHER"),
    nUnknown = census("UNKNOWN"),
    nUncovered = as.integer(sum(coverage$n[!coverage$covered])),
    overrideSummary = overrideSummary,
    warningText = warningText,
    stringsAsFactors = FALSE
  )
}
