## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Compute the symmetric axis scale for the pyramid plot
#'
#' Get the maximum of the absolute values of the negative (males) and positive
#' (female) animal counts and then round that up to the nearest multiple of the
#' modulus greater than or equal to the maximum value.
#'
#' @param bins integer vector with numbers of individuals in each bin
#' @param axModulus integer value used in the modulus function to determine
#' the interval between possible maxAx values.
#'
#' @return Integer value equal to the nearest multiple of \code{axModulus} that
#' is greater than or equal to the maximum of the absolute values of the
#' negative (males) and positive (female) animal counts.
#' @noRd
getMaxAx <- function(bins, axModulus) {
  makeRoundUp(max(max(bins$male), max(bins$female)), axModulus)
}
