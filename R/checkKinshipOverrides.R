#' Validate a kinship overrides table
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Checks the structure and domain of an outside-information kinship override
#' table (issue #13). The table supplies pairwise kinship coefficients
#' (\code{id1}, \code{id2}, \code{kinship}) that
#' \code{\link{applyKinshipOverrides}} writes into a computed kinship matrix,
#' replacing the pedigree-derived value for those pairs. It mirrors
#' \code{\link{checkGenotypeFile}}: it \code{stop()}s on structural or domain
#' errors and returns the (id-coerced) table when the input is acceptable.
#'
#' \code{kinship} is the kinship coefficient \emph{f} (the probability that an
#' allele drawn at random from each of the two animals is identical by descent),
#' \strong{not} the coefficient of relatedness \emph{r} (= 2\emph{f} for
#' non-inbred animals). Supplying \emph{r} -- e.g. 0.5 for half-sibs whose true
#' \emph{f} is 0.125 -- silently corrupts the matrix, so an off-diagonal value
#' above 0.5 (the maximum for a non-inbred pair) draws a warning here. The exact
#' positive-semi-definiteness bound is enforced by
#' \code{\link{applyKinshipOverrides}} once the matrix diagonal is known.
#'
#' @param overrides data.frame with id columns \code{id1} and \code{id2} and a
#' numeric \code{kinship} column; each row is one off-diagonal pair. An optional
#' \code{missingSideFor} column (issue #95 option C) may name, per row, which of
#' \code{id1} / \code{id2} is the one-unknown focal whose MISSING-side
#' relatedness the override stands in for (blank / NA = known-side); each
#' non-blank value must equal that row's \code{id1} or \code{id2}.
#' @return The validated \code{overrides} data.frame with \code{id1} and
#' \code{id2} coerced to character, and an optional \code{missingSideFor}
#' column normalized (NA -> "") when present.
#' @export
#' @examples
#' overrides <- data.frame(
#'   id1 = c("A1", "A3"), id2 = c("A2", "A4"),
#'   kinship = c(0.25, 0.125), stringsAsFactors = FALSE
#' )
#' checkKinshipOverrides(overrides)
checkKinshipOverrides <- function(overrides) {
  required <- c("id1", "id2", "kinship")
  missingCols <- setdiff(required, names(overrides))
  if (length(missingCols) > 0L) {
    stop("Kinship overrides must have columns ",
      paste(required, collapse = ", "), "; missing: ",
      paste(missingCols, collapse = ", "), ".")
  }
  overrides$id1 <- as.character(overrides$id1)
  overrides$id2 <- as.character(overrides$id2)

  if (!is.numeric(overrides$kinship)) {
    stop("Kinship overrides 'kinship' column must be numeric.")
  }
  if (any(is.na(overrides$kinship))) {
    stop("Kinship overrides 'kinship' column must not contain NA.")
  }
  if (any(overrides$kinship < 0)) {
    stop("Kinship overrides 'kinship' values must not be negative.")
  }
  if (any(overrides$id1 == overrides$id2)) {
    stop("Kinship overrides must be off-diagonal: id1 and id2 must differ.")
  }
  ## duplicate unordered pairs are a data error the user must resolve
  lo <- pmin(overrides$id1, overrides$id2)
  hi <- pmax(overrides$id1, overrides$id2)
  key <- paste(lo, hi, sep = "\r")
  if (anyDuplicated(key) > 0L) {
    dup <- unique(key[duplicated(key)])
    stop("Kinship overrides contain duplicated (unordered) pair(s): ",
      paste(gsub("\r", "-", dup), collapse = ", "), ".")
  }
  ## issue #95 option C: an optional missingSideFor column names which of the
  ## row's two ids is the one-unknown focal whose MISSING side this override
  ## stands in for (blank / NA = known-side). Structural check only -- the
  ## semantic "is it really one-unknown" test is the caller's job. The
  ## unordered-pair dedup key is unchanged (C1.2: no two-sides-per-pair).
  if ("missingSideFor" %in% names(overrides)) {
    side <- as.character(overrides$missingSideFor)
    side[is.na(side)] <- ""
    named <- nzchar(side)
    bad <- named & side != overrides$id1 & side != overrides$id2
    if (any(bad)) {
      stop("Kinship overrides 'missingSideFor' must name id1 or id2 of the ",
        "same row (or be blank); offending value(s): ",
        toString(unique(side[bad])), ".")
    }
    overrides$missingSideFor <- side
  }
  ## off-diagonal kinship for a non-inbred pair cannot exceed 0.5 (warn here;
  ## the exact per-pair bound is enforced in applyKinshipOverrides, D6)
  if (any(overrides$kinship > 0.5)) {
    warning("Kinship overrides contain off-diagonal value(s) > 0.5, valid ",
      "only for inbred pairs. Confirm these are kinship coefficients (f), ",
      "not relatedness (r = 2f).")
  }
  overrides
}
