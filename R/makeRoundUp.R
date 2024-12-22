#' Round up the provided integer vector \code{int} according to the
#' \code{modulus}.
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @param int integer vector
#' @param modulus integer value to use as the divisor.
#' @noRd
makeRoundUp <- function(int, modulus) {
  int + modulus - int %% modulus
}
