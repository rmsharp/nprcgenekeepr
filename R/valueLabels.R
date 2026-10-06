## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Genetic-value labels
#'
#' Single source of truth for the three labels \code{\link{rankSubjects}} gives
#' each animal in the \code{value} column and that the rest of the package
#' compares against: \code{lowValue}, \code{highValue} and \code{undetermined}.
#' Internal helper constant -- every place that assigns or matches a label reads
#' it from here instead of typing it, so a label cannot change in one place and
#' silently stop matching in the others.
#' @noRd
valueLabels <- c(
  lowValue = "Low Value",
  highValue = "High Value",
  undetermined = "Undetermined"
)
