## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Rebuild earlier colony snapshots from a pedigree's birth and exit dates
#'
#' Builds one Genetic-Health Trends snapshot for each past date from the birth
#' and exit dates already in a pedigree, so a trend can be drawn without
#' waiting seasons for recorded snapshots (issue #170). Each row is the same
#' 27-column row \code{\link{createColonySnapshot}} makes and passes
#' \code{\link{checkSnapshotHistory}}, filed under its own membership rule,
#' \code{"reconstructedLiving"}, so rebuilt rows form a line of their own and
#' never mix with recorded ones.
#'
#' \strong{The dates.} Give \code{dates}, or leave it out for a series of
#' \code{by} steps (one year by default) from \code{from} to \code{to}. Unless
#' you give them, the series starts at the first 1 January with at least
#' \code{minAnimals} living animals and ends at the last 1 January on or before
#' the latest birth or exit date in the pedigree. \code{minAnimals} only moves
#' that default start: a date you name, in \code{dates} or as \code{from}, is
#' never refused for having few animals.
#'
#' \strong{Who was alive.} For each date the pedigree is copied and every exit
#' date after that date is blanked, because the demographic effective-size
#' estimators read the exit column as it stands (see
#' \code{\link{calcNeSexRatio}}): without the blanking an animal that was alive
#' on the date but has left since would not count as a living breeder. The
#' population is the real animals alive on the date. An animal is alive from
#' its birth date; one with no birth date is alive from the birth of its first
#' offspring that has a date (it was born before that offspring). It is alive
#' until its exit date. An animal with no exit date counts only when the
#' studbook lists it as living, the test the application applies today (status
#' \code{ALIVE}, or no exit date when the pedigree has no \code{status}
#' column), so an animal whose status is \code{UNKNOWN} never counts. Generated
#' stand-in parents never enter the population. The pedigree is trimmed to that
#' population and its ancestors (\code{\link{trimPedigree}}), analyzed with
#' \code{\link{reportGV}}, and summarized with
#' \code{\link{createColonySnapshot}}. For the date a pedigree was exported,
#' the row equals the snapshot the application records for that pedigree.
#'
#' \strong{What each date rests on.} The \code{support} table says how many
#' animals were counted, how many of them were placed through an offspring, how
#' many more the studbook does not rule out (animals with no birth date that
#' are not counted and had not left), and how much of the parentage is
#' recorded. No threshold refuses a date; read these figures beside the trend.
#' Where few sires are recorded the sex-ratio effective size reads low because
#' of the missing records, not because of the colony.
#'
#' \strong{Dates that fail.} A date that cannot be analyzed (for example one on
#' which fewer than two animals were alive) does not stop the others. It is
#' listed in \code{skipped} with the message of the error, and one warning says
#' how many dates failed. When no date can be built, the function stops and
#' names the dates. A date whose \code{"reconstructedLiving"} row is already in
#' \code{existingHistory} is not rebuilt; it is listed in \code{skipped}
#' without a warning.
#'
#' \strong{Twin pairs.} A \code{twinRelations} table (see
#' \code{\link{checkTwinRelations}}) is used on each date as far as that
#' date's animals allow. Declared identical (\code{"MZ twin"}) animals form
#' groups, as in \code{\link{kinship}}, so the pairs A-B and B-C make the group
#' A, B and C. On a date the groups are cut to the animals in that date's
#' pedigree, which holds the animals alive then and their ancestors; a group
#' left with two or more animals is applied and the others are left out. An
#' animal missing from the pedigree on a date cannot change anyone's kinship
#' that day, so a twin born later, or one who left and has no descendants, no
#' longer makes the date fail. An identifier that is in no pedigree at all is a
#' mistake and stops the function before any date is built.
#'
#' Limits: today's parentage and today's genotypes are used for every date, so
#' a parent identified later is treated as known earlier; the effective sizes
#' follow the definition of a living breeder in
#' \code{\link{calcNeSexRatio}}; and two close dates can differ only by
#' gene-drop sampling.
#'
#' @param ped A quality-controlled pedigree data.frame (see
#' \code{\link{qcStudbook}}) holding at least \code{id}, \code{sire},
#' \code{dam}, \code{sex}, \code{gen}, \code{birth} and \code{exit} (the last
#' two as \code{Date} columns), and a \code{status} column when the studbook
#' has one. Pass the full pedigree, not one already trimmed to a focal list of
#' animals.
#' @param dates The dates to rebuild: \code{Date} values or ISO-8601
#' (YYYY-MM-DD) strings, at least one, with no missing or duplicated value.
#' Leave it out (\code{NULL}) to build the series described by \code{from},
#' \code{to} and \code{by}; it cannot be combined with them.
#' @param guIter Single positive whole number: the number of gene-drop
#' iterations, recorded in each row. Required — there is no default, so the
#' recorded settings cannot silently differ from the ones used.
#' @param guThresh Single positive whole number: the genetic uniqueness
#' threshold, recorded in each row. Required.
#' @param from The first date of the series: a \code{Date} or an ISO-8601
#' string. The default is the first 1 January with at least \code{minAnimals}
#' living animals.
#' @param to The last date of the series, as \code{from}. The default is the
#' last 1 January on or before the latest birth or exit date in \code{ped}.
#' @param by The step of the series: a string for \code{\link[base]{seq.Date}},
#' such as \code{"year"} (the default), \code{"6 months"} or \code{"quarter"}.
#' @param existingHistory A snapshot history to add to (see
#' \code{\link{checkSnapshotHistory}}), or \code{NULL} for none. Its rows are
#' kept as they are, with any extra columns, and a date whose
#' \code{"reconstructedLiving"} row is already there is not rebuilt. A row of
#' another membership rule on the same date does not count as already there.
#' @param minAnimals Single whole number, at least 2 (the least
#' \code{\link{reportGV}} can analyze): the fewest living animals a 1 January
#' needs to start the default series. Default 2.
#' @param updateProgress Function or \code{NULL}. If it is a function, it is
#' called once for each date, after the date has been rebuilt, skipped or has
#' failed, with the arguments \code{n} (the number of dates in the run),
#' \code{value} (how many are done) and \code{detail} (the date as text), to
#' update a \code{shiny::Progress} object. It is not passed on to
#' \code{reportGV}.
#' @param ... Further arguments passed to \code{\link{reportGV}} (for example
#' \code{kinshipOverrides} or \code{twinRelations}, the latter cut to each
#' date as described above).
#' @return A list of three data.frames. \code{history}: the rebuilt snapshots
#' (and the rows of \code{existingHistory}, if given), in date order, in the
#' 27-column snapshot-history schema. \code{support}: one row for each date in
#' the run, with \code{snapshotDate}, \code{nLiving} (the animals counted),
#' \code{nPlacedByOffspring} (of those, the ones with no birth date),
#' \code{nPossiblyAlive}, \code{pctSireKnown} and \code{pctDamKnown} (the
#' percentage of the living animals whose sire or dam is recorded, that is
#' neither blank nor a generated stand-in; \code{NA} when nobody was alive).
#' \code{skipped}: the dates not rebuilt, with \code{snapshotDate} and
#' \code{reason}.
#' @seealso \code{\link{createColonySnapshot}},
#' \code{\link{appendColonySnapshot}}, \code{\link{checkSnapshotHistory}}
#' @export
#' @examples
#' ped <- nprcgenekeepr::qcPed
#' result <- backfillColonySnapshots(ped,
#'   dates = as.Date(c("2005-01-01", "2010-01-01")),
#'   guIter = 10L, guThresh = 1L
#' )
#' result$history[, c("snapshotDate", "membershipRule", "nAnimals")]
#' result$support
#'
#' ## a yearly series, added to the history above: the dates already there
#' ## are not rebuilt
#' series <- backfillColonySnapshots(ped,
#'   from = "2005-01-01", to = "2008-01-01",
#'   guIter = 10L, guThresh = 1L, existingHistory = result$history
#' )
#' series$history[, c("snapshotDate", "nAnimals")]
#' series$skipped
backfillColonySnapshots <- function(ped, dates = NULL,
                                    guIter, # nolint: function_argument_linter
                                    guThresh, # nolint: function_argument_linter
                                    from = NULL, to = NULL, by = "year",
                                    existingHistory = NULL, minAnimals = 2L,
                                    updateProgress = NULL, ...) {
  ## The order follows the design's interface table and a test pins it: dates,
  ## then the two required settings (design B9: no default, so the recorded
  ## provenance cannot silently be wrong), then the series.
  assertBackfillPed(ped, "backfillColonySnapshots(ped)")
  if (missing(guIter)) {
    stop("'guIter' must be supplied: the number of gene-drop iterations ",
      "(there is no default, so the recorded provenance cannot silently be ",
      "wrong).")
  }
  if (missing(guThresh)) {
    stop("'guThresh' must be supplied: the genetic uniqueness threshold ",
      "(there is no default, so the recorded provenance cannot silently be ",
      "wrong).")
  }
  guIter <- validateWholeCount(guIter, "guIter")
  guThresh <- validateWholeCount(guThresh, "guThresh")
  minAnimals <- validateMinAnimals(minAnimals)
  if (!is.null(updateProgress) && !is.function(updateProgress)) {
    stop("'updateProgress' must be a function or NULL.")
  }
  if (!is.null(existingHistory)) {
    existingHistory <- tryCatch(
      checkSnapshotHistory(existingHistory),
      error = function(e) {
        stop("'existingHistory' is not a valid snapshot history: ",
          conditionMessage(e), call. = FALSE)
      }
    )
  }

  reportArgs <- list(...)
  twinRelations <- reportArgs[["twinRelations"]]
  if (!is.null(twinRelations)) {
    assertTwinIdsInPedigree(twinRelations, ped)
  }

  facts <- describeBackfillColony(ped)
  dates <- resolveBackfillDates(facts, dates, from, to, by, !missing(by),
                                minAnimals)
  support <- supportForDates(facts, dates)

  alreadyThere <- rebuiltSnapshotDates(existingHistory)
  rows <- vector("list", length(dates))
  reasons <- character(length(dates))
  already <- logical(length(dates))
  for (i in seq_along(dates)) {
    date <- dates[[i]]
    if (date %in% alreadyThere) {
      already[[i]] <- TRUE
      reasons[[i]] <-
        "already in existingHistory under the reconstructedLiving rule"
    } else {
      outcome <- tryCatch({
        asOf <- ped
        asOf$exit[!is.na(asOf$exit) & asOf$exit > date] <- NA
        asOf$population <- livingOnDate(facts, date)$living
        asOf <- trimToAnalysisPopulation(asOf)
        reportArgs[["twinRelations"]] <-
          restrictTwinRelations(twinRelations, asOf$id)
        geneticValue <- do.call(
          reportGV,
          c(list(asOf, guIter = guIter, guThresh = guThresh, byID = TRUE),
            reportArgs)
        )
        list(row = createColonySnapshot(asOf, geneticValue,
          "reconstructedLiving",
          guIter = guIter, guThresh = guThresh, snapshotDate = date
        ))
      }, error = function(e) list(reason = conditionMessage(e)))
      if (is.null(outcome$reason)) {
        rows[[i]] <- outcome$row
      } else {
        reasons[[i]] <- outcome$reason
      }
    }
    notifyProgress(updateProgress,
      n = length(dates), detail = format(date), value = i
    )
  }

  built <- !vapply(rows, is.null, logical(1L))
  failed <- !built & !already
  if (!any(built) && !any(already)) {
    shown <- utils::head(which(failed), 5L)
    stop("No snapshot could be built. ",
      paste0(format(dates[shown]), ": ", reasons[shown], collapse = " | "),
      if (sum(failed) > length(shown)) {
        paste0(" | and ", sum(failed) - length(shown), " more")
      },
      call. = FALSE)
  }
  newRows <- NULL
  if (any(built)) {
    newRows <- do.call(rbind, rows[built])
    rownames(newRows) <- NULL
  }
  history <- if (is.null(existingHistory)) {
    newRows
  } else if (is.null(newRows)) {
    existingHistory[order(existingHistory$snapshotDate), , drop = FALSE]
  } else {
    for (column in setdiff(names(existingHistory), names(newRows))) {
      newRows[[column]] <- NA
    }
    appendColonySnapshot(existingHistory, newRows)
  }
  rownames(history) <- NULL

  skippedAt <- which(already | failed)
  skipped <- data.frame(
    snapshotDate = dates[skippedAt],
    reason = reasons[skippedAt],
    stringsAsFactors = FALSE
  )
  if (any(failed)) {
    # Its own kind with its counts, so the app can say it in its own words
    warning(warningCondition(
      paste0(sum(failed), " of ", length(dates), " dates could not be ",
        "rebuilt and are listed in 'skipped'."),
      class = "backfillFailedDates",
      nFailed = sum(failed), nDates = length(dates)
    ))
  }
  list(history = history, support = support, skipped = skipped)
}

#' The dates a history already holds rebuilt
#'
#' The snapshot dates of the rows of \code{history} under the
#' \code{"reconstructedLiving"} rule, the dates a build does not rebuild. Used
#' by \code{backfillColonySnapshots()} and by the Genetic-Health Trends panel,
#' which says those dates in its own words.
#'
#' @param history \code{NULL} or a snapshot history.
#' @return A \code{Date} vector, empty when \code{history} is \code{NULL}.
#'
#' @noRd
rebuiltSnapshotDates <- function(history) {
  if (is.null(history)) {
    return(as.Date(character(0L)))
  }
  history$snapshotDate[history$membershipRule == "reconstructedLiving"]
}

#' The dates of a rebuilt series
#'
#' Fills in the default \code{from} (the first 1 January with at least
#' \code{minAnimals} living animals) and \code{to} (the last 1 January on or
#' before the latest birth or exit date) and lays out the steps.
#'
#' @param facts The list from \code{describeBackfillColony()}.
#' @param from,to \code{NULL} or a single date (\code{Date} or ISO-8601
#' string).
#' @param by A step string for \code{seq.Date}.
#' @param minAnimals The whole number from \code{backfillColonySnapshots()}.
#' @return A \code{Date} vector in order; stops, naming the argument, when an
#' argument cannot be used.
#'
#' @noRd
buildBackfillDates <- function(facts, from, to, by, minAnimals) {
  if (!is.character(by) || length(by) != 1L || is.na(by)) {
    stop("'by' must be a single step for seq.Date(), such as \"year\" or ",
      "\"6 months\".", call. = FALSE)
  }
  januaryFirst <- function(year) as.Date(sprintf("%04d-01-01", year))
  yearOf <- function(day) {
    as.integer(format(as.Date(day, origin = "1970-01-01"), "%Y"))
  }

  if (!is.null(to)) {
    to <- parseIsoDate(to, "to")
  }
  if (!is.null(from)) {
    from <- parseIsoDate(from, "from")
  }
  recorded <- c(facts$birth, facts$exit)
  recorded <- recorded[!is.na(recorded)]
  if (length(recorded) == 0L) {
    stop("'ped' holds no birth or exit dates, so there is no series to ",
      "build.", call. = FALSE)
  }
  if (is.null(to)) {
    to <- januaryFirst(yearOf(max(recorded)))
  }
  if (is.null(from)) {
    placeable <- facts$placedFrom[!facts$standIn & !is.na(facts$placedFrom)]
    years <- if (length(placeable) > 0L) {
      seq(yearOf(min(placeable)), yearOf(as.numeric(to)))
    } else {
      integer(0L)
    }
    for (year in years) {
      candidate <- januaryFirst(year)
      if (sum(livingOnDate(facts, candidate)$living) >= minAnimals) {
        from <- candidate
        break
      }
    }
    if (is.null(from)) {
      stop("No 1 January up to ", format(to), " has at least ", minAnimals,
        " living animals ('minAnimals').", call. = FALSE)
    }
  }
  if (from > to) {
    stop("'from' (", format(from), ") must not be after 'to' (", format(to),
      ").", call. = FALSE)
  }
  tryCatch(
    seq(from, to, by = by),
    error = function(e) {
      stop("'by' cannot step from ", format(from), " to ", format(to), ": ",
        conditionMessage(e), call. = FALSE)
    }
  )
}

#' Stop when a twin table names an animal that is in no pedigree
#'
#' The one thing \code{kinship()} stopped for on every date that is a real
#' mistake and not a matter of the date: an identifier that is not in the
#' pedigree at all (a typing error). Checked once, before any date.
#'
#' @param twinRelations A data.frame with \code{id1} and \code{id2}.
#' @param ped The pedigree handed to \code{backfillColonySnapshots()}.
#' @return \code{NULL}, invisibly; stops, naming \code{twinRelations} and the
#' identifiers, when any is not in \code{ped$id}.
#'
#' @noRd
assertTwinIdsInPedigree <- function(twinRelations, ped) {
  named <- unique(c(
    as.character(twinRelations$id1), as.character(twinRelations$id2)
  ))
  unknown <- setdiff(named, as.character(ped$id))
  if (length(unknown) > 0L) {
    stop("'twinRelations' names animals that are not in 'ped': ",
      toString(unknown), ".", call. = FALSE)
  }
  invisible(NULL)
}

#' Cut a twin table to the animals of one date's pedigree
#'
#' Declared \code{"MZ twin"} pairs are grouped as \code{kinship()} groups them
#' (A-B and B-C make A, B and C). Each group keeps the members that are in
#' \code{present}; a group left with two or more is returned as pairs joining
#' its first present member to each of the others. Rows of the other twin
#' codes, which \code{kinship()} does not use, are kept when both animals are
#' present.
#'
#' @param twinRelations \code{NULL} or a data.frame with \code{id1},
#' \code{id2} and \code{code}.
#' @param present The identifiers in the pedigree for the date.
#' @return \code{NULL} when no pair is left, otherwise a data.frame with
#' \code{id1}, \code{id2} and \code{code}.
#'
#' @noRd
restrictTwinRelations <- function(twinRelations, present) {
  if (is.null(twinRelations) || nrow(twinRelations) == 0L) {
    return(NULL)
  }
  pairs <- data.frame(
    id1 = as.character(twinRelations$id1),
    id2 = as.character(twinRelations$id2),
    code = as.character(twinRelations$code),
    stringsAsFactors = FALSE
  )
  isMz <- pairs$code == "MZ twin"
  kept <- pairs[!isMz & pairs$id1 %in% present & pairs$id2 %in% present, ,
    drop = FALSE
  ]

  mz <- pairs[isMz, , drop = FALSE]
  ids <- unique(c(mz$id1, mz$id2))
  group <- seq_along(ids)
  repeat {
    merged <- FALSE
    for (i in seq_len(nrow(mz))) {
      a <- match(mz$id1[[i]], ids)
      b <- match(mz$id2[[i]], ids)
      if (group[[a]] != group[[b]]) {
        group[group == max(group[[a]], group[[b]])] <-
          min(group[[a]], group[[b]])
        merged <- TRUE
      }
    }
    if (!merged) {
      break
    }
  }
  for (g in unique(group)) {
    members <- ids[group == g & ids %in% present]
    if (length(members) >= 2L) {
      kept <- rbind(kept, data.frame(
        id1 = members[[1L]], id2 = members[-1L], code = "MZ twin",
        stringsAsFactors = FALSE
      ))
    }
  }
  if (nrow(kept) == 0L) {
    return(NULL)
  }
  rownames(kept) <- NULL
  kept
}

#' Check the pedigree handed to a backfill function
#'
#' Shared by \code{backfillColonySnapshots()} and
#' \code{previewBackfillSupport()}, which take the same pedigree.
#'
#' @param ped The pedigree argument.
#' @param where The call, for the message about missing columns.
#' @return \code{NULL}, invisibly; stops when \code{ped} is not a data.frame or
#' lacks a required column.
#'
#' @noRd
assertBackfillPed <- function(ped, where) {
  if (!is.data.frame(ped)) {
    stop("'ped' must be a pedigree data.frame.")
  }
  assertRequiredColsPresent(
    names(ped),
    c("id", "sire", "dam", "sex", "gen", "birth", "exit"),
    where
  )
}

#' Check the \code{minAnimals} argument of a backfill function
#'
#' @param minAnimals The argument.
#' @return A single whole number of at least 2; stops, naming
#' \code{minAnimals}, otherwise.
#'
#' @noRd
validateMinAnimals <- function(minAnimals) {
  minAnimals <- validateWholeCount(minAnimals, "minAnimals")
  if (minAnimals < 2L) {
    stop("'minAnimals' must be at least 2: a snapshot needs two animals.")
  }
  minAnimals
}

#' The dates of a backfill call
#'
#' Either the explicit \code{dates} (read, checked and put in order) or the
#' series \code{buildBackfillDates()} lays out from \code{from}, \code{to} and
#' \code{by}. Shared by \code{backfillColonySnapshots()} and
#' \code{previewBackfillSupport()}, so a preview always shows the dates a build
#' would use.
#'
#' @param facts The list from \code{describeBackfillColony()}.
#' @param dates,from,to,by,minAnimals The arguments of the calling function.
#' @param byGiven \code{TRUE} when the caller was given \code{by} (it has a
#' default, so \code{missing(by)} is only known there).
#' @return A \code{Date} vector in order; stops, naming the argument, when an
#' argument cannot be used.
#'
#' @noRd
resolveBackfillDates <- function(facts, dates, from, to, by, byGiven,
                                 minAnimals) {
  if (is.null(dates)) {
    return(buildBackfillDates(facts, from, to, by, minAnimals))
  }
  if (!is.null(from) || !is.null(to) || byGiven) {
    stop("'dates' cannot be combined with 'from', 'to' or 'by': give ",
      "either the dates or a series.")
  }
  ## a Date round-trips through as.character() as YYYY-MM-DD, so one
  ## coercion path serves both accepted input types
  dates <- as.Date(as.character(dates), format = "%Y-%m-%d")
  if (length(dates) == 0L || anyNA(dates)) {
    stop("'dates' must be one or more ISO-8601 (YYYY-MM-DD) dates, none ",
      "missing.")
  }
  if (anyDuplicated(dates) > 0L) {
    stop("'dates' must not contain duplicate dates.")
  }
  sort(dates)
}

#' The support table for a set of dates
#'
#' @param facts The list from \code{describeBackfillColony()}.
#' @param dates The \code{Date}s, in order.
#' @return A data.frame with one row per date (see
#' \code{supportOnDate()}).
#'
#' @noRd
supportForDates <- function(facts, dates) {
  do.call(rbind, lapply(seq_along(dates), function(i) {
    supportOnDate(facts, dates[[i]])
  }))
}
