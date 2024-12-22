#' Get the maximum of the absolute values of the negative (males) and positive
#' (female) animal counts.
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' This is used to scale the pyramid plot symmetrically.
#'
#' @param bins integer vector with numbers of individuals in each bin
#' @param axModulus integer value used in the modulus function to determine
#' the interval between possible maxAx values.
#'
#' @noRd
getMaxAx <- function(bins, axModulus) {
  makeRoundUp(max(max(bins$male), max(bins$female)), axModulus)
}
