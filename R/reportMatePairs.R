## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Report eligible individual mate pairs with kinship and genetic-value context
#'
#' Issue #151 Slice 1: composes the existing pair-eligibility pipeline
#' (\code{\link{kinMatrix2LongForm}}, \code{\link{filterPairs}},
#' \code{filterAge()}, \code{\link{filterKinMatrix}} -- all unmodified)
#' into a report of opposite-sex, minimum-age-eligible mate-pair candidates,
#' each row optionally enriched with marker-based kinship
#' (\code{\link{markerKinship}}) and per-parent genetic-value context
#' (\code{\link{reportGV}}'s \code{indivMeanKin}/\code{gu}) when available.
#' No composite/blended ranking score is computed -- callers sort/filter the
#' raw columns themselves (see
#' \code{docs/planning/issue151-individual-mate-pair-analysis-plan.md}
#' Section 3, decision D3).
#'
#' @details
#' \strong{Population scoping (D4).} \code{minAge} alone does not bound the
#' candidate-pair table on real, imperfectly-curated data: a missing age
#' \emph{passes} \code{filterAge()}'s screen rather than being excluded
#' by it (see that function's own semantics), so long-retired or
#' never-dated individuals can still appear. \code{populationIds}, applied
#' via \code{\link{filterKinMatrix}} \emph{before} the pair-reshape, is the
#' mechanism that actually bounds both correctness and table size; the
#' default \code{NULL} performs no scoping (every individual in \code{kmat}
#' is a candidate). An explicit \code{character(0)} is a valid, distinct
#' input -- "scope to nobody" -- and returns a zero-row \code{pairs} frame
#' with the full column shape, not an error.
#'
#' \strong{Exclusion transparency (D5).} Two independent screens produce
#' \code{excluded} rows: the age screen (\code{"under minimum age"}) and the
#' caller-supplied \code{exclude} id list (\code{"user-excluded"}). A pair
#' failing the age screen is reported with that reason and never reaches the
#' user-exclude screen, so each dropped pair carries exactly one reason from
#' this closed, enumerable vocabulary.
#'
#' \strong{Graceful degradation.} \code{markerKmat} and \code{geneticValues}
#' are both \code{NULL}-safe: when absent (or when a specific pair is not
#' covered by them), the corresponding columns are \code{NA} for that row --
#' the pair itself is never dropped or the call errored, mirroring
#' \code{modMarkerGeneticsServer}'s own "not yet uploaded" contract.
#'
#' @param ped Pedigree data.frame with at least \code{id}, \code{sire},
#' \code{dam}, \code{sex}, and \code{age} columns.
#' @param kmat Pedigree kinship matrix (e.g. as returned by
#' \code{\link{kinship}}), \code{id} x \code{id}, covering every id
#' considered.
#' @param markerKmat Optional genotype-only KING-robust kinship matrix (e.g.
#' as returned by \code{\link{markerKinship}}), \code{id} x \code{id}, which
#' may cover only a subset of \code{ped$id} (not every animal is
#' genotyped). \code{NULL} (the default) leaves \code{markerKinship} as
#' \code{NA} for every pair.
#' @param geneticValues Optional \code{\link{reportGV}}-shaped list (only
#' \code{$report}, with \code{id}, \code{indivMeanKin}, and \code{gu}
#' columns, is used). \code{NULL} (the default) leaves the four per-parent
#' genetic-value columns \code{NA} for every pair.
#' @param minAge Numeric scalar, the minimum age (in the same units as
#' \code{ped$age}) for an individual to be pair-eligible. Default \code{1},
#' mirroring Breeding Groups' own scalar convention. A missing (\code{NA})
#' age passes this screen (see Details) -- use \code{populationIds} to
#' actually bound the candidate population.
#' @param populationIds Optional character vector of ids to which the
#' analysis is scoped, applied before the pair-reshape (D4, see Details).
#' \code{NULL} (the default) performs no scoping; \code{character(0)} scopes
#' to nobody and returns a zero-row result.
#' @param exclude Character vector of ids to drop entirely, regardless of
#' any other eligibility screen. Default \code{character(0)} (no
#' caller-supplied exclusions).
#' @return A list with two data.frames:
#' \item{pairs}{One row per eligible opposite-sex pair surviving every
#' screen: \code{sireId}, \code{damId}, \code{kinship}, \code{markerKinship}
#' (\code{NA} if unavailable), \code{sireIndivMeanKin}, \code{sireGu},
#' \code{damIndivMeanKin}, \code{damGu} (the latter four \code{NA} if
#' \code{geneticValues} is not supplied or the parent is absent from its
#' report).}
#' \item{excluded}{One row per pair dropped by the age or user-exclude
#' screen: \code{sireId}, \code{damId}, \code{reason} (\code{"under minimum
#' age"} or \code{"user-excluded"}).}
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- data.frame(
#'   id = c("S1", "D1", "A", "B"),
#'   sire = c(NA, NA, "S1", NA),
#'   dam = c(NA, NA, "D1", NA),
#'   sex = c("M", "F", "M", "F"),
#'   age = c(10, 10, 5, 5),
#'   stringsAsFactors = FALSE
#' )
#' ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
#' result <- reportMatePairs(ped, kmat, minAge = 1)
#' result$pairs
reportMatePairs <- function(ped, kmat, markerKmat = NULL, geneticValues = NULL,
                             minAge = 1L, populationIds = NULL,
                             exclude = character(0L)) {
  assertRequiredColsPresent(
    names(ped), c("id", "sire", "dam", "sex", "age"),
    "reportMatePairs(ped)"
  )
  if (!is.matrix(kmat)) {
    stop("nprcgenekeepr: kmat must be a matrix, as returned by kinship().",
         call. = FALSE)
  }

  if (!is.null(populationIds)) {
    kmat <- filterKinMatrix(populationIds, kmat)
  }

  if (nrow(kmat) == 0L || ncol(kmat) == 0L) {
    return(list(
      pairs = emptyMatePairsFrame(), excluded = emptyMateExcludedFrame()
    ))
  }

  kin <- kinMatrix2LongForm(kmat, removeDups = TRUE)
  kin <- filterPairs(kin, ped, ignore = list(
    c(sexCodes[["male"]], sexCodes[["male"]]),
    c(sexCodes[["female"]], sexCodes[["female"]])
  ))

  if (nrow(kin) == 0L) {
    return(list(
      pairs = emptyMatePairsFrame(), excluded = emptyMateExcludedFrame()
    ))
  }

  # Normalize id1/id2 (whichever happened to land where in the matrix) to
  # sireId (male) / damId (female) -- filterPairs() above guarantees every
  # surviving row is opposite-sex.
  sex1 <- ped$sex[match(kin$id1, ped$id)]
  isSire1 <- sex1 == sexCodes[["male"]]
  kin <- data.frame(
    sireId = ifelse(isSire1, kin$id1, kin$id2),
    damId = ifelse(isSire1, kin$id2, kin$id1),
    kinship = kin$kinship,
    stringsAsFactors = FALSE
  )

  sireAge <- ped$age[match(kin$sireId, ped$id)]
  damAge <- ped$age[match(kin$damId, ped$id)]
  ageOk <- ((sireAge >= minAge) | is.na(sireAge)) &
    ((damAge >= minAge) | is.na(damAge))

  excludedAge <- kin[!ageOk, c("sireId", "damId"), drop = FALSE]
  excludedAge$reason <- rep("under minimum age", nrow(excludedAge))
  kin <- kin[ageOk, , drop = FALSE]

  userOk <- !(kin$sireId %in% exclude | kin$damId %in% exclude)
  excludedUser <- kin[!userOk, c("sireId", "damId"), drop = FALSE]
  excludedUser$reason <- rep("user-excluded", nrow(excludedUser))
  kin <- kin[userOk, , drop = FALSE]

  excluded <- rbind(excludedAge, excludedUser)
  rownames(excluded) <- NULL

  # kin may legitimately be 0-row here (every candidate pair excluded); the
  # merges below are 0-row-safe by construction (match()/%in%/any() on
  # empty vectors resolve to correct no-ops), so no extra guard is needed.
  kin$markerKinship <- NA_real_
  if (!is.null(markerKmat)) {
    bothGenotyped <- kin$sireId %in% rownames(markerKmat) &
      kin$damId %in% rownames(markerKmat)
    if (any(bothGenotyped)) {
      kin$markerKinship[bothGenotyped] <- markerKmat[
        cbind(kin$sireId[bothGenotyped], kin$damId[bothGenotyped])
      ]
    }
  }

  kin$sireIndivMeanKin <- NA_real_
  kin$sireGu <- NA_real_
  kin$damIndivMeanKin <- NA_real_
  kin$damGu <- NA_real_
  if (!is.null(geneticValues) && !is.null(geneticValues$report)) {
    rpt <- geneticValues$report
    sireIdx <- match(kin$sireId, rpt$id)
    damIdx <- match(kin$damId, rpt$id)
    kin$sireIndivMeanKin <- rpt$indivMeanKin[sireIdx]
    kin$sireGu <- rpt$gu[sireIdx]
    kin$damIndivMeanKin <- rpt$indivMeanKin[damIdx]
    kin$damGu <- rpt$gu[damIdx]
  }

  rownames(kin) <- NULL
  list(pairs = kin, excluded = excluded)
}

#' @noRd
emptyMatePairsFrame <- function() {
  data.frame(
    sireId = character(0L), damId = character(0L),
    kinship = numeric(0L), markerKinship = numeric(0L),
    sireIndivMeanKin = numeric(0L), sireGu = numeric(0L),
    damIndivMeanKin = numeric(0L), damGu = numeric(0L),
    stringsAsFactors = FALSE
  )
}

#' @noRd
emptyMateExcludedFrame <- function() {
  data.frame(
    sireId = character(0L), damId = character(0L),
    reason = character(0L), stringsAsFactors = FALSE
  )
}
