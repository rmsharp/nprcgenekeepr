## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Facts about a pedigree that decide who was alive on a past date
#'
#' Internal helper for \code{\link{backfillColonySnapshots}}. It reads the
#' pedigree once and keeps what the counting rule needs, so the rule lives in
#' one place for the analysis population and the support table. An animal with
#' no birth date is placed by the birth of its first offspring that has one (it
#' was born before that offspring); an animal with no exit date can be alive
#' only when the studbook lists it as living, the test the application applies
#' today (\code{isLivingAnimal()}).
#'
#' @param ped A quality-controlled pedigree data.frame with \code{id},
#' \code{sire}, \code{dam}, \code{birth} and \code{exit}.
#' @return A list of vectors, one element per row of \code{ped}: \code{standIn}
#' (a generated stand-in parent), \code{undated} (no birth date),
#' \code{birth}, \code{exit} and \code{placedFrom} (day numbers; the birth, or
#' the first offspring's birth for an undated animal), \code{canBeLiving} (has
#' an exit date, or is listed as living) and \code{sireRecorded} and
#' \code{damRecorded} (a parent that is neither blank nor a stand-in).
#'
#' @noRd
describeBackfillColony <- function(ped) {
  standIn <- isGeneratedUnknownId(ped$id, ped = ped)
  standIn[is.na(standIn)] <- FALSE
  birth <- as.numeric(ped$birth)
  undated <- is.na(birth)

  parent <- c(as.character(ped$sire), as.character(ped$dam))
  offspringBirth <- c(birth, birth)
  known <- !is.na(parent) & !is.na(offspringBirth)
  firstOffspring <- tapply(offspringBirth[known], parent[known], min)
  firstOffspring <- stats::setNames(
    as.vector(firstOffspring), names(firstOffspring)
  )
  placedFrom <- birth
  placedFrom[undated] <- firstOffspring[as.character(ped$id[undated])]

  isRecorded <- function(parentId) {
    !is.na(parentId) & !(parentId %in% ped$id[standIn])
  }
  list(
    standIn = standIn,
    undated = undated,
    birth = birth,
    exit = as.numeric(ped$exit),
    placedFrom = unname(placedFrom),
    canBeLiving = !is.na(ped$exit) | isLivingAnimal(ped),
    sireRecorded = isRecorded(as.character(ped$sire)),
    damRecorded = isRecorded(as.character(ped$dam))
  )
}

#' Who was alive on a date, and who the studbook does not rule out
#'
#' @param facts The list from \code{describeBackfillColony()}.
#' @param date A single \code{Date}.
#' @return A list of two logical vectors, one element per pedigree row:
#' \code{living} (a real animal born, or placed by its first offspring, on or
#' before the date, not gone by it, and either with a recorded exit date later
#' than the date or listed as living) and \code{possibly} (a real animal that is
#' not counted but whose dates do not rule out that it was alive: not born
#' after the date and not gone by it).
#'
#' @noRd
livingOnDate <- function(facts, date) {
  day <- as.numeric(date)
  gone <- !is.na(facts$exit) & facts$exit <= day
  living <- !facts$standIn & !is.na(facts$placedFrom) &
    facts$placedFrom <= day & !gone & facts$canBeLiving
  possibly <- !facts$standIn & !living & (facts$undated | facts$birth <= day) &
    !gone
  list(living = living, possibly = possibly)
}

#' What one date of a rebuilt series rests on
#'
#' @param facts The list from \code{describeBackfillColony()}.
#' @param date A single \code{Date}.
#' @return A one-row data.frame: \code{snapshotDate}, \code{nLiving},
#' \code{nPlacedByOffspring} (living animals with no birth date),
#' \code{nPossiblyAlive}, and \code{pctSireKnown} and \code{pctDamKnown} (the
#' percentage of the living animals with a recorded sire or dam; \code{NA} when
#' nobody was alive).
#'
#' @noRd
supportOnDate <- function(facts, date) {
  who <- livingOnDate(facts, date)
  nLiving <- sum(who$living)
  percentRecorded <- function(recorded) {
    if (nLiving == 0L) {
      NA_real_
    } else {
      100.0 * sum(who$living & recorded) / nLiving
    }
  }
  data.frame(
    snapshotDate = date,
    nLiving = as.integer(nLiving),
    nPlacedByOffspring = as.integer(sum(who$living & facts$undated)),
    nPossiblyAlive = as.integer(sum(who$possibly)),
    pctSireKnown = percentRecorded(facts$sireRecorded),
    pctDamKnown = percentRecorded(facts$damRecorded),
    stringsAsFactors = FALSE
  )
}
