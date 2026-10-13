## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Read the animal IDs typed or pasted into a box
#'
#' The one rule for a box of pasted animal IDs, such as the Breeding Groups
#' "Animal IDs:" box. IDs are separated by a space, comma, semicolon, tab or
#' new line; the space around an ID (and the carriage return a Windows
#' spreadsheet leaves at a line end) is trimmed, and nothing empty is kept.
#' The order typed is kept and a repeated ID stays repeated, so the caller
#' decides whether a repeat matters.
#'
#' @param raw A single string as typed, or \code{NULL} for a box that was
#' never touched.
#' @return A character vector of IDs, \code{character(0)} for a missing,
#' empty or blank box, never \code{NA}.
#' @noRd
parseIdList <- function(raw) {
  if (is.null(raw) || is.na(raw) || !nzchar(trimws(raw))) {
    return(character(0L))
  }
  ids <- trimws(unlist(strsplit(raw, "[ ,;\t\n]")))
  ids[nzchar(ids)]
}
