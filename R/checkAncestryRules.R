## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Validate an ancestry compatibility rules table
#'
#' Checks the structure and domain of a center-configurable ancestry
#' compatibility rules table (issue #168). Each row is one unordered pair of
#' standardized ancestry levels plus a severity: \code{block} rules exclude
#' the pairing during breeding-group formation, \code{flag} rules annotate it
#' afterward. It mirrors \code{\link{checkKinshipOverrides}}: it \code{stop()}s
#' on structural or domain errors and returns the coerced table when the input
#' is acceptable. An empty table (zero rules) is valid.
#'
#' Ancestry levels must come from \code{\link{convertAncestry}}'s standardized
#' vocabulary: CHINESE, INDIAN, HYBRID, JAPANESE, OTHER, UNKNOWN. Levels are
#' coerced to uppercase and \code{severity} to lowercase before validation, so
#' a hand-edited file's casing never matters. A rule may pair a level with
#' itself (e.g. HYBRID with HYBRID); duplicated unordered pairs are a data
#' error the user must resolve. Because \code{\link{convertAncestry}} maps a
#' blank ancestry to UNKNOWN but any unrecognized text -- including a literal
#' re-standardized \code{"UNKNOWN"} string -- to OTHER, a table that names one
#' of UNKNOWN/OTHER without the other draws a warning here: a center wanting
#' conservative treatment of animals without usable ancestry information
#' almost always wants both.
#'
#' @param rules data.frame with columns \code{ancestry1} and \code{ancestry2}
#' (standardized ancestry levels) and \code{severity} (\code{"block"} or
#' \code{"flag"}); each row is one unordered level pair. Any extra columns
#' are ignored.
#' @return The validated \code{rules} data.frame with \code{ancestry1} and
#' \code{ancestry2} coerced to uppercase character and \code{severity} to
#' lowercase character.
#' @export
#' @examples
#' rules <- data.frame(
#'   ancestry1 = c("INDIAN", "INDIAN"),
#'   ancestry2 = c("CHINESE", "HYBRID"),
#'   severity = c("block", "flag"), stringsAsFactors = FALSE
#' )
#' checkAncestryRules(rules)
checkAncestryRules <- function(rules) {
  required <- c("ancestry1", "ancestry2", "severity")
  missingCols <- setdiff(required, names(rules))
  if (length(missingCols) > 0L) {
    stop("Ancestry rules must have columns ",
      toString(required), "; missing: ",
      toString(missingCols), ".")
  }
  rules$ancestry1 <- toupper(trimws(as.character(rules$ancestry1)))
  rules$ancestry2 <- toupper(trimws(as.character(rules$ancestry2)))
  rules$severity <- tolower(trimws(as.character(rules$severity)))

  if (anyNA(rules$ancestry1) || anyNA(rules$ancestry2) ||
      anyNA(rules$severity)) {
    stop("Ancestry rules must not contain NA values.")
  }
  ## the standardized vocabulary is convertAncestry()'s factor levels
  levelsAll <- c("CHINESE", "INDIAN", "HYBRID", "JAPANESE", "OTHER",
                 "UNKNOWN")
  badLevels <- setdiff(unique(c(rules$ancestry1, rules$ancestry2)),
                       levelsAll)
  if (length(badLevels) > 0L) {
    stop("Ancestry rules contain level(s) outside the standardized ",
      "vocabulary (", toString(levelsAll), "): ",
      toString(badLevels), ".")
  }
  badSeverity <- setdiff(unique(rules$severity), c("block", "flag"))
  if (length(badSeverity) > 0L) {
    stop("Ancestry rules 'severity' values must be 'block' or 'flag'; ",
      "found: ", toString(badSeverity), ".")
  }
  ## duplicate unordered pairs are a data error the user must resolve
  ## (self-pairs are legal rules, so only the duplication is rejected)
  lo <- pmin(rules$ancestry1, rules$ancestry2)
  hi <- pmax(rules$ancestry1, rules$ancestry2)
  key <- paste(lo, hi, sep = "\r")
  if (anyDuplicated(key) > 0L) {
    dup <- unique(key[duplicated(key)])
    stop("Ancestry rules contain duplicated (unordered) pair(s): ",
      toString(gsub("\r", "-", dup, fixed = TRUE)), ".")
  }
  ## D6: UNKNOWN and OTHER are operationally one "no usable information"
  ## class (convertAncestry() is not idempotent), so naming exactly one is
  ## almost always an oversight -- warn, never stop.
  named <- unique(c(rules$ancestry1, rules$ancestry2))
  if ("UNKNOWN" %in% named && !"OTHER" %in% named) {
    warning("Ancestry rules name UNKNOWN but not OTHER. Unrecognized ",
      "ancestry text standardizes to OTHER (a blank standardizes to ",
      "UNKNOWN), so rules for animals without usable ancestry ",
      "information usually need both levels.")
  } else if ("OTHER" %in% named && !"UNKNOWN" %in% named) {
    warning("Ancestry rules name OTHER but not UNKNOWN. A blank ancestry ",
      "standardizes to UNKNOWN (unrecognized text standardizes to ",
      "OTHER), so rules for animals without usable ancestry ",
      "information usually need both levels.")
  }
  rules
}
