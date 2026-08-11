## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Obfuscate a pedigree by aliasing IDs and shifting dates
#'
#' User provides a pedigree object (\code{ped}), the number of characters to be
#' used for alias IDs (\code{size}), and the maximum number of days that the
#' birthdate can be shifted (\code{maxDelta}).
#'
#' @inheritParams reportGV
#' @param size integer value indicating number of characters in alias IDs
#' @param maxDelta integer value indicating maximum number of days that
#' the birthdate can be shifted
#' @param existingIds character vector of existing aliases to avoid duplication.
#' @param map logical if \code{TRUE} a list object is returned with the new
#' pedigree and a named character vector with the names being the original IDs
#' and the values being the new alias values. Defaults to \code{FALSE}.
#' @param linkedDateShift logical, defaults to \code{TRUE}. When \code{TRUE},
#' every Date column of one individual is shifted by the same, single random
#' offset (drawn once per individual), so the gaps between an individual's
#' own dates (e.g. \code{birth}, \code{exit}, \code{death}) are preserved
#' exactly -- avoiding a defect where independently-shifted date columns can
#' invert an individual's recorded date order (e.g. an obfuscated \code{exit}
#' preceding an obfuscated \code{birth}), producing a negative recomputed
#' \code{age} (issue #150 D3). When \code{FALSE}, each Date column is shifted
#' independently via \code{\link{obfuscateDate}} (the original, pre-#150
#' behavior).
#' @return An obfuscated pedigree
#'
#' @importFrom lubridate is.Date ddays
#' @importFrom stats runif
#' @family obfuscation
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- qcStudbook(nprcgenekeepr::pedGood)
#' obfuscatedPed <- obfuscatePed(ped)
#' ped
#' obfuscatedPed
obfuscatePed <- function(ped, size = 6L, maxDelta = 30L,
                         existingIds = character(0L), map = FALSE,
                         linkedDateShift = TRUE) {
  alias <- obfuscateId(ped$id, size = size, existingIds = existingIds)
  ped$sire <- alias[ped$sire]
  ped$dam <- alias[ped$dam]
  ped$id <- alias
  if ("name" %in% names(ped)) {
    ## issue #136 D8: a name is the only genuinely PII-shaped field this
    ## package has ever contemplated -- drop it rather than alias it, so an
    ## obfuscated pedigree never carries scrubbed ids alongside intact real
    ## names.
    ped$name <- NA_character_
  }
  dateCols <- names(ped)[vapply(ped, function(col) any(inherits(col, "Date")),
                                 logical(1L))]
  if (linkedDateShift) {
    ## issue #150 D3: draw exactly ONE random offset per individual (row),
    ## in [-maxDelta, +maxDelta], and add it to every Date column for that
    ## row. This preserves each individual's inter-column date gaps exactly
    ## (birth/exit/death/... all move together) while still moving every
    ## date to an unpredictable absolute position. Any offset in this range
    ## also trivially satisfies obfuscateDate()'s own floor (baseDate -
    ## maxDelta) for every column, so no re-derivation of that floor is
    ## needed here.
    if (length(dateCols) > 0L) {
      n <- nrow(ped)
      md <- maxDelta
      if (length(md) == 1L) {
        md <- rep(md, n)
      }
      offsetDays <- runif(n, -md, md)
      for (col in dateCols) {
        ## Date + ddays(NA) is not what we want when ped[[col]] is NA for a
        ## given row -- Date arithmetic already propagates NA correctly
        ## (Date(NA) + finite duration == NA), so no extra guard is needed.
        ped[[col]] <- as.Date(ped[[col]] + ddays(offsetDays))
      }
    }
  } else {
    ## Original (pre-#150) behavior: each Date column shifted independently.
    for (col in dateCols) {
      ped[[col]] <- obfuscateDate(ped[[col]], maxDelta = maxDelta)
    }
  }
  if (any("age" %in% names(ped)) && any("birth" %in% names(ped)) &&
      any("exit" %in% names(ped)) && all(is.Date(ped$birth))) {
    ped["age"] <- calcAge(ped$birth, ped$exit)
  }
  if (map) {
    list(ped = ped, map = alias)
  } else {
    ped
  }
}
