## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Add placeholder IDs for unknown parents
#'
#' This must be run prior to \code{addParents} since the IDs made herein are
#' used by \code{addParents}
#'
#' The generated placeholder IDs default to the form \code{Unnnn} (a leading
#' "U" plus a zero-padded integer), so they are alphanumeric and never contain a
#' period ("."), honoring the ID rule enforced at data input by
#' \code{\link{qcStudbook}}. The format is configurable via
#' \code{\link{setAutoIdFormat}} (default \code{"U\%04d"}). A candidate ID
#' that is already in the pedigree is skipped, so a placeholder never
#' duplicates the ID of a real animal.
#'
#' @inheritParams trimPedigree
#' @param format \code{sprintf} template for the generated placeholder IDs;
#' defaults to \code{\link{getAutoIdFormat}()} (\code{"U\%04d"}).
#' @return The updated pedigree with partial parentage removed.
#'
#' @export
#' @examples
#' pedTwo <- data.frame(
#'   id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
#'   sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
#'   dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
#'   sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
#'   stringsAsFactors = FALSE
#' )
#' newPed <- addUIds(pedTwo)
#' newPed[newPed$id == "s1", ]
#' pedThree <-
#'   data.frame(
#'     id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
#'     sire = c("s0", "s0", "s4", NA, "s1", "s1", "s2", "s2"),
#'     dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
#'     sex = c("M", "F", "M", "F", "F", "F", "F", "M"),
#'     stringsAsFactors = FALSE
#'   )
#' newPed <- addUIds(pedThree)
#' newPed[newPed$id == "s1", ]
addUIds <- function(ped, format = getAutoIdFormat()) {
  s <- which(is.na(ped$sire) & !is.na(ped$dam))
  d <- which(!is.na(ped$sire) & is.na(ped$dam))
  existingIds <- ped$id
  nextStart <- 1L

  if (!identical(s, integer(0L))) {
    minted <- mintAvailableIds(length(s), format, existingIds, nextStart)
    ped[s, "sire"] <- minted$ids
    existingIds <- c(existingIds, minted$ids)
    nextStart <- minted$nextStart
  }

  if (!identical(d, integer(0L))) {
    minted <- mintAvailableIds(length(d), format, existingIds, nextStart)
    ped[d, "dam"] <- minted$ids
  }

  ped
}

#' Mint the next n available auto-generated ids
#'
#' Generates candidate ids from a running counter, skipping any that already
#' exist in \code{existingIds} (a real id must never be duplicated by a minted
#' one), and accumulates newly-minted ids into that check so a single batch
#' never collides with itself.
#'
#' @param n number of ids to mint.
#' @param format auto-ID \code{sprintf} format.
#' @param existingIds character vector of ids already in use.
#' @param startAt the first counter value to try.
#' @return A list with \code{ids} (the minted ids) and \code{nextStart} (the
#' next counter value to try, for a subsequent call).
#' @noRd
mintAvailableIds <- function(n, format, existingIds, startAt = 1L) {
  ids <- character(n)
  counter <- startAt
  i <- 1L
  while (i <= n) {
    candidate <- sprintf(format, counter)
    counter <- counter + 1L
    if (candidate %in% existingIds) next
    ids[i] <- candidate
    existingIds <- c(existingIds, candidate)
    i <- i + 1L
  }
  list(ids = ids, nextStart = counter)
}
