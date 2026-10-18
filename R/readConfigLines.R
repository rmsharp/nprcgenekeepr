## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read the lines of an nprcgenekeepr configuration file, minus comments
#'
#' Drops every full-line comment (a line whose first non-blank character is
#' \code{#}) so a commented-out \code{key = value} example line is not parsed
#' as an active setting: \code{getTokenList} collapses all lines and does not
#' itself strip \code{#} comments. The shipped example config documents the
#' optional keys as commented lines a user uncomments to activate. A comment
#' that follows a setting on the same line is not removed.
#'
#' @param configFile path to an existing configuration file.
#' @return Character vector of the lines that are not full-line comments.
#' @noRd
readConfigLines <- function(configFile) {
  lines <- readLines(configFile, skipNul = TRUE)
  lines[!grepl("^\\s*#", lines)]
}
