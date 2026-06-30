## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Round up the provided integer vector \code{int} according to the
#' \code{modulus}.
#' @return Integer value equal to the nearest multiple of \code{modulus} that
#' is greater than or equal to \code{int}.
#' @param int integer vector
#' @param modulus integer value to use as the divisor.
#' @noRd
makeRoundUp <- function(int, modulus) {
  int + modulus - int %% modulus
}
