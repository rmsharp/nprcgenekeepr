## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Rebuild earlier colony snapshots from a pedigree's birth and exit dates
#'
#' Builds one Genetic-Health Trends snapshot for each past date in
#' \code{dates} from the birth and exit dates already in a pedigree, so a
#' trend can be drawn without waiting seasons for recorded snapshots (issue
#' #170). Each row is the same 27-column row \code{\link{createColonySnapshot}}
#' makes and passes \code{\link{checkSnapshotHistory}}, filed under its own
#' membership rule, \code{"reconstructedLiving"}, so rebuilt rows form a line
#' of their own and never mix with recorded ones.
#'
#' For each date the pedigree is copied and every exit date after that date is
#' blanked, because the demographic effective-size estimators read the exit
#' column as it stands (see \code{\link{calcNeSexRatio}}): without the
#' blanking an animal that was alive on the date but has left since would not
#' count as a living breeder. The population is then the real animals born on
#' or before the date with no exit date left; generated stand-in parents never
#' enter it. The pedigree is trimmed to that population and its ancestors
#' (\code{\link{trimPedigree}}), analyzed with \code{\link{reportGV}}, and
#' summarized with \code{\link{createColonySnapshot}}. For the date a pedigree
#' was exported, the row equals the snapshot the app records for that pedigree.
#'
#' Limits: today's parentage is used for every date, so a parent identified
#' later is treated as known earlier; an animal with no birth date is left out
#' of every population; and a date that cannot be analyzed (for example one
#' on which fewer than two animals were alive) stops the run and names the
#' date.
#'
#' @param ped A quality-controlled pedigree data.frame (see
#' \code{\link{qcStudbook}}) holding at least \code{id}, \code{sire},
#' \code{dam}, \code{sex}, \code{gen}, \code{birth} and \code{exit} (the last
#' two as \code{Date} columns). Pass the full pedigree, not one already
#' trimmed to a focal list of animals.
#' @param dates The dates to rebuild: \code{Date} values or ISO-8601
#' (YYYY-MM-DD) strings, at least one, with no missing or duplicated value.
#' Required.
#' @param guIter Single positive whole number: the number of gene-drop
#' iterations, recorded in each row. Required — there is no default, so the
#' recorded settings cannot silently differ from the ones used.
#' @param guThresh Single positive whole number: the genetic uniqueness
#' threshold, recorded in each row. Required.
#' @param ... Further arguments passed to \code{\link{reportGV}} (for example
#' \code{kinshipOverrides} or \code{twinRelations}).
#' @return A list with one element, \code{history}: a data.frame of the
#' rebuilt snapshots, one row per date in date order, in the 27-column
#' snapshot-history schema.
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
backfillColonySnapshots <- function(ped, dates, guIter, guThresh, ...) {
  if (!is.data.frame(ped)) {
    stop("'ped' must be a pedigree data.frame.")
  }
  assertRequiredColsPresent(
    names(ped),
    c("id", "sire", "dam", "sex", "gen", "birth", "exit"),
    "backfillColonySnapshots(ped)"
  )
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
  if (missing(dates)) {
    stop("'dates' must be supplied: the dates to rebuild snapshots for.")
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
  dates <- sort(dates)

  standIn <- isGeneratedUnknownId(ped$id, ped = ped)
  rows <- lapply(dates, function(date) {
    tryCatch({
      asOf <- ped
      asOf$exit[!is.na(asOf$exit) & asOf$exit > date] <- NA
      asOf$population <- !standIn & !is.na(asOf$birth) &
        asOf$birth <= date & is.na(asOf$exit)
      asOf <- trimToAnalysisPopulation(asOf)
      geneticValue <- reportGV(asOf,
        guIter = guIter, guThresh = guThresh, byID = TRUE, ...
      )
      createColonySnapshot(asOf, geneticValue, "reconstructedLiving",
        guIter = guIter, guThresh = guThresh, snapshotDate = date
      )
    }, error = function(e) {
      stop("Snapshot for ", format(date), " could not be built: ",
        conditionMessage(e), call. = FALSE)
    })
  })
  history <- do.call(rbind, rows)
  rownames(history) <- NULL
  list(history = history)
}
