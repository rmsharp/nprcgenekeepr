## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Create a colony snapshot row from a genetic value report
#'
#' Turns one \code{\link{reportGV}} result into a one-row data.frame in the
#' 27-column snapshot-history schema (issue #167, schema version 1), ready
#' for \code{\link{appendColonySnapshot}}. Every metric field is a value the
#' \code{nprcgenekeeprGV} object already carries, or a Summary Statistics
#' aggregate (\code{mean}/\code{median}/\code{\link{calcSkewness}}/
#' \code{\link{calcKurtosis}}, \code{NA} removed) of its per-animal
#' \code{indivMeanKin}/\code{gu}/\code{guSE} report columns, stored at full
#' precision — no estimator is recomputed or duplicated.
#'
#' \code{guIter} and \code{guThresh} are required because the
#' \code{reportGV} return object does not carry them, and they are
#' comparability provenance the snapshot must record truthfully: pass
#' exactly the values the \code{reportGV} call used (its defaults are
#' \code{1000L} and \code{1L}).
#'
#' The claimed \code{membershipRule} is verified against \code{ped} and the
#' report, and a contradiction stops:
#' \describe{
#' \item{\code{"wholePedigree"}}{the report covers exactly the animals in
#' \code{ped}.}
#' \item{\code{"focalPopulation"}}{\code{ped} carries the logical
#' \code{population} column (see \code{\link{setPopulation}}) and the report
#' covers exactly \code{ped$id[ped$population]}. Pass the same
#' population-designated pedigree the \code{reportGV} call analyzed.}
#' }
#'
#' @param ped The pedigree data.frame the \code{reportGV} analysis was run
#' on, carrying at least an \code{id} column (plus the logical
#' \code{population} column when \code{membershipRule} is
#' \code{"focalPopulation"}).
#' @param geneticValue An object of class \code{nprcgenekeeprGV} as returned
#' by \code{\link{reportGV}}.
#' @param membershipRule Single string naming how the analysis population
#' was assembled; one of \code{"wholePedigree"} or \code{"focalPopulation"}.
#' @param guIter Single positive whole number: the \code{guIter} value the
#' \code{reportGV} call used. Required — there is no default.
#' @param guThresh Single positive whole number: the \code{guThresh} value
#' the \code{reportGV} call used. Required — there is no default.
#' @param snapshotDate The snapshot's date: a \code{Date} or an ISO-8601
#' (YYYY-MM-DD) string. Defaults to \code{Sys.Date()}.
#' @return A one-row data.frame in the 27-column snapshot-history schema;
#' it passes \code{\link{checkSnapshotHistory}} unchanged.
#' @export
#' @examples
#' ped <- nprcgenekeepr::qcPed
#' gv <- reportGV(ped, guIter = 10L)
#' snapshot <- createColonySnapshot(ped, gv, "wholePedigree",
#'   guIter = 10L, guThresh = 1L
#' )
#' history <- appendColonySnapshot(NULL, snapshot)
createColonySnapshot <- function(ped, geneticValue, membershipRule,
                                 guIter, guThresh,
                                 snapshotDate = Sys.Date()) {
  if (!is.data.frame(ped) || is.null(ped$id)) {
    stop("'ped' must be a pedigree data.frame with an 'id' column.")
  }
  if (!inherits(geneticValue, "nprcgenekeeprGV")) {
    stop("'geneticValue' must be an object of class 'nprcgenekeeprGV' as ",
      "returned by reportGV().")
  }
  requiredElements <- c(
    "report", "fe", "fg", "fgSE", "neGD", "neSexRatio", "neVariance",
    "nMaleFounders", "nFemaleFounders", "total"
  )
  missingElements <- setdiff(requiredElements, names(geneticValue))
  if (length(missingElements) > 0L) {
    stop("'geneticValue' is incomplete; missing element(s): ",
      toString(missingElements), ".")
  }
  report <- geneticValue$report
  requiredReportCols <- c("id", "sex", "indivMeanKin", "gu", "guSE")
  missingReportCols <- setdiff(requiredReportCols, names(report))
  if (length(missingReportCols) > 0L) {
    stop("'geneticValue$report' is incomplete; missing column(s): ",
      toString(missingReportCols), ".")
  }

  knownRules <- c("wholePedigree", "focalPopulation")
  if (!is.character(membershipRule) || length(membershipRule) != 1L ||
      is.na(membershipRule)) {
    stop("'membershipRule' must be a single string; known rules: ",
      toString(knownRules), ".")
  }
  if (!(membershipRule %in% knownRules)) {
    stop("Unknown 'membershipRule' \"", membershipRule, "\"; known rules: ",
      toString(knownRules), ".")
  }

  if (missing(guIter)) {
    stop("'guIter' must be supplied: the guIter value the reportGV() call ",
      "used (there is no default, so the recorded provenance cannot ",
      "silently be wrong).")
  }
  if (missing(guThresh)) {
    stop("'guThresh' must be supplied: the guThresh value the reportGV() ",
      "call used (there is no default, so the recorded provenance cannot ",
      "silently be wrong).")
  }
  validateWholeCount <- function(value, name) {
    if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
        value < 1L || value != as.integer(value)) {
      stop("'", name, "' must be a single positive whole number (the ",
        "value the reportGV() call used).")
    }
    as.integer(value)
  }
  guIter <- validateWholeCount(guIter, "guIter")
  guThresh <- validateWholeCount(guThresh, "guThresh")

  ## a Date round-trips through as.character() as YYYY-MM-DD, so one
  ## coercion path serves both accepted input types
  snapshotDate <- as.Date(as.character(snapshotDate), format = "%Y-%m-%d")
  if (length(snapshotDate) != 1L || anyNA(snapshotDate)) {
    stop("'snapshotDate' must be a single ISO-8601 (YYYY-MM-DD) date.")
  }

  reportIds <- as.character(report$id)
  pedIds <- as.character(ped$id)
  if (membershipRule == "wholePedigree") {
    if (!setequal(reportIds, pedIds)) {
      stop("membershipRule 'wholePedigree' claims the analysis covered the ",
        "whole pedigree, but the geneticValue report covers ",
        length(reportIds), " animal(s) while 'ped' holds ",
        length(pedIds), ".")
    }
  } else {
    if (is.null(ped$population)) {
      stop("membershipRule 'focalPopulation' requires 'ped' to carry the ",
        "logical population column that designated the focal population ",
        "(see setPopulation()).")
    }
    focalIds <- as.character(ped$id[ped$population])
    if (!setequal(reportIds, focalIds)) {
      stop("membershipRule 'focalPopulation' claims the analysis covered ",
        "the pedigree's designated focal population, but the geneticValue ",
        "report covers ", length(reportIds), " animal(s) while 'ped' ",
        "designates ", length(focalIds), ".")
    }
  }

  data.frame(
    schemaVersion = 1L,
    snapshotDate = snapshotDate,
    packageVersion = as.character(utils::packageVersion("nprcgenekeepr")),
    membershipRule = membershipRule,
    guIter = guIter,
    guThresh = guThresh,
    nAnimals = nrow(report),
    nMales = sum(report$sex == "M", na.rm = TRUE),
    nFemales = sum(report$sex == "F", na.rm = TRUE),
    ## colony scalars, verbatim from the reportGV object (as.numeric() only
    ## pins the schema's numeric type; a degenerate all-NA scalar would
    ## otherwise arrive as logical NA and fail checkSnapshotHistory())
    fe = as.numeric(geneticValue$fe),
    fg = as.numeric(geneticValue$fg),
    fgSE = as.numeric(geneticValue$fgSE),
    neGD = as.numeric(geneticValue$neGD),
    neSexRatio = as.numeric(geneticValue$neSexRatio),
    neVariance = as.numeric(geneticValue$neVariance),
    nMaleFounders = as.integer(geneticValue$nMaleFounders),
    nFemaleFounders = as.integer(geneticValue$nFemaleFounders),
    nFounders = as.integer(geneticValue$total),
    ## Summary Statistics aggregates at full precision (Dragon 5): mean()/
    ## median() are summary()'s Mean/Median without its display rounding
    meanIndivMeanKin = mean(report$indivMeanKin, na.rm = TRUE),
    medianIndivMeanKin = stats::median(report$indivMeanKin, na.rm = TRUE),
    skewnessIndivMeanKin = calcSkewness(report$indivMeanKin),
    kurtosisIndivMeanKin = calcKurtosis(report$indivMeanKin),
    meanGu = mean(report$gu, na.rm = TRUE),
    medianGu = stats::median(report$gu, na.rm = TRUE),
    meanGuSE = mean(report$guSE, na.rm = TRUE),
    skewnessGu = calcSkewness(report$gu),
    kurtosisGu = calcKurtosis(report$gu),
    stringsAsFactors = FALSE
  )
}
