## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Obfuscate dates with a random day offset
#'
#' Get the \code{baseDate} and add a random number of days taken from a
#' uniform distribution bounded by -\code{maxDelta} and \code{maxDelta}.
#' Insure the resulting date is as least as large as the \code{minDate}.
#'
#' @param baseDate vector of Date values with dates to be obfuscated
#' @param minDate optional vector of Date values, the same length as
#' \code{baseDate}, that has the lower bound of resulting obfuscated dates.
#' When missing, the lower bound is each \code{baseDate} minus its
#' \code{maxDelta}, so the bound never binds.
#' @param maxDelta integer vector of length 1 or the same length as
#' \code{baseDate} that is used to create min and max arguments
#' to \code{runif} (\code{runif(n, min = 0, max = 1)})
#' @return A vector of dates that have be obfuscated.
#'
#' @importFrom lubridate ddays
#' @importFrom stats runif
#' @family obfuscation
#' @export
#' @examples
#' library(nprcgenekeepr)
#' someDates <- rep(
#'   as.Date(c("2009-2-16", "2016-2-16"), format = "%Y-%m-%d"),
#'   10
#' )
#' minBirthDate <- rep(as.Date("2009-2-16", format = "%Y-%m-%d"), 20)
#' obfuscateDate(someDates, minBirthDate, 30L)
obfuscateDate <- function(baseDate, minDate, maxDelta = 30L) {
  if (length(maxDelta) == 1L) {
    maxDelta <- rep(maxDelta, length(baseDate))
  }
  if (length(baseDate) != length(maxDelta)) {
    stop("Length of minDate must be 1 or the same as baseDate.")
  }
  if (missing(minDate)) {
    minDate <- baseDate
    for (i in seq_along(baseDate)) {
      minDate[[i]] <- as.Date(baseDate[[i]] - ddays(maxDelta[[i]]))
    }
  }
  if (length(baseDate) != length(minDate)) {
    stop("Length of baseDate and minDate must be the same.")
  }

  obfuscatedDates <- baseDate
  for (i in seq_along(baseDate)) {
    if (is.na(baseDate[[i]])) {
      obfuscatedDate <- NA
    } else {
      repeat {
        obfuscatedDate <- as.Date(baseDate[[i]] + ddays(runif(
          1L, -maxDelta[i],
          maxDelta[i]
        )))
        if (obfuscatedDate >= minDate[[i]]) {
          break
        }
      }
    }
    obfuscatedDates[[i]] <- obfuscatedDate
  }
  obfuscatedDates
}
