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
#' numeric \code{kinship} column; each row is one off-diagonal pair. Any extra
#' columns are ignored.
#' @return The validated \code{overrides} data.frame with \code{id1} and
#' \code{id2} coerced to character.
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
      toString(required), "; missing: ",
      toString(missingCols), ".")
  }
  overrides$id1 <- as.character(overrides$id1)
  overrides$id2 <- as.character(overrides$id2)

  if (!is.numeric(overrides$kinship)) {
    stop("Kinship overrides 'kinship' column must be numeric.")
  }
  if (anyNA(overrides$kinship)) {
    stop("Kinship overrides 'kinship' column must not contain NA.")
  }
  if (any(overrides$kinship < 0L)) {
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
      toString(gsub("\r", "-", dup, fixed = TRUE)), ".")
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
