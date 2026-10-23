## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Count what each date of a rebuilt series rests on, before building it
#'
#' Returns the \code{support} table that \code{\link{backfillColonySnapshots}}
#' reports for the same dates, without the gene drop, so the counts are there
#' in a moment and a start year can be chosen knowingly before minutes of
#' analysis are spent (issue #170). The Genetic-Health Trends tab shows this
#' same table before its "Build earlier snapshots" button is used.
#'
#' The dates are laid out exactly as \code{backfillColonySnapshots} lays them
#' out: give \code{dates}, or leave it out for a series of \code{by} steps (one
#' year by default) from \code{from} to \code{to}. Unless you give them, the
#' series starts at the first 1 January with at least \code{minAnimals} living
#' animals and ends at the last 1 January on or before the latest birth or exit
#' date in the pedigree. \code{minAnimals} only moves that default start: a
#' date you name, in \code{dates} or as \code{from}, is never refused for
#' having few animals.
#'
#' An animal is counted on a date by the rules of
#' \code{\link{backfillColonySnapshots}}: alive from its birth date, or, with
#' no birth date, from the birth of its first offspring that has a date, until
#' its exit date; an animal with no exit date counts only when the studbook
#' lists it as living. No threshold refuses a date; read the counts beside the
#' trend.
#'
#' @param ped A quality-controlled pedigree data.frame (see
#' \code{\link{qcStudbook}}) holding at least \code{id}, \code{sire},
#' \code{dam}, \code{sex}, \code{gen}, \code{birth} and \code{exit} (the last
#' two as \code{Date} columns), and a \code{status} column when the studbook
#' has one. Pass the full pedigree, not one already trimmed to a focal list of
#' animals.
#' @param dates The dates to count: \code{Date} values or ISO-8601
#' (YYYY-MM-DD) strings, at least one, with no missing or duplicated value.
#' Leave it out (\code{NULL}) to use the series described by \code{from},
#' \code{to} and \code{by}; it cannot be combined with them.
#' @param from The first date of the series: a \code{Date} or an ISO-8601
#' string. The default is the first 1 January with at least \code{minAnimals}
#' living animals.
#' @param to The last date of the series, as \code{from}. The default is the
#' last 1 January on or before the latest birth or exit date in \code{ped}.
#' @param by The step of the series: a string for \code{\link[base]{seq.Date}},
#' such as \code{"year"} (the default), \code{"6 months"} or \code{"quarter"}.
#' @param minAnimals Single whole number, at least 2: the fewest living animals
#' a 1 January needs to start the default series. Default 2.
#' @return A data.frame with one row for each date, in date order, and the
#' columns of the \code{support} table of \code{\link{backfillColonySnapshots}}:
#' \code{snapshotDate}, \code{nLiving} (the animals counted),
#' \code{nPlacedByOffspring} (of those, the ones with no birth date),
#' \code{nPossiblyAlive} (animals with no birth date that are not counted and
#' had not left), \code{pctSireKnown} and \code{pctDamKnown} (the percentage of
#' the living animals whose sire or dam is recorded, that is neither blank nor
#' a generated stand-in; \code{NA} when nobody was alive).
#' @seealso \code{\link{backfillColonySnapshots}}
#' @export
#' @examples
#' ped <- nprcgenekeepr::qcPed
#' previewBackfillSupport(ped,
#'   dates = as.Date(c("2005-01-01", "2010-01-01"))
#' )
#'
#' ## the default series, and a later start when the early years rest on little
#' head(previewBackfillSupport(ped), 3L)
#' head(previewBackfillSupport(ped, minAnimals = 30L), 3L)
previewBackfillSupport <- function(ped, dates = NULL, from = NULL, to = NULL,
                                   by = "year", minAnimals = 2L) {
  if (!is.data.frame(ped)) {
    stop("'ped' must be a pedigree data.frame.")
  }
  assertRequiredColsPresent(
    names(ped),
    c("id", "sire", "dam", "sex", "gen", "birth", "exit"),
    "previewBackfillSupport(ped)"
  )
  minAnimals <- validateWholeCount(minAnimals, "minAnimals")
  if (minAnimals < 2L) {
    stop("'minAnimals' must be at least 2: a snapshot needs two animals.")
  }

  facts <- describeBackfillColony(ped)
  if (is.null(dates)) {
    dates <- buildBackfillDates(facts, from, to, by, minAnimals)
  } else {
    if (!is.null(from) || !is.null(to) || !missing(by)) {
      stop("'dates' cannot be combined with 'from', 'to' or 'by': give ",
        "either the dates or a series.")
    }
    dates <- as.Date(as.character(dates), format = "%Y-%m-%d")
    if (length(dates) == 0L || anyNA(dates)) {
      stop("'dates' must be one or more ISO-8601 (YYYY-MM-DD) dates, none ",
        "missing.")
    }
    if (anyDuplicated(dates) > 0L) {
      stop("'dates' must not contain duplicate dates.")
    }
    dates <- sort(dates)
  }

  support <- do.call(rbind, lapply(seq_along(dates), function(i) {
    supportOnDate(facts, dates[[i]])
  }))
  rownames(support) <- NULL
  support
}
