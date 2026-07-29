## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Order the results of the genetic value analysis for use in a report
#'
#' Part of Genetic Value Analysis
#'
#' Takes in the results from a genetic value analysis and orders the report
#' according to the ranking scheme we have developed.
#'
#' @param rpt a dataframe with required colnames \code{id}, \code{gu},
#' \code{zScores}, and optionally \code{origin} and \code{parentage}, which is
#' a data.frame of results from a genetic value analysis. When \code{parentage}
#' is absent the both-unknown founders are taken from \code{getFounders(ped)};
#' when \code{origin} is absent every both-unknown founder is treated as
#' ONPRC-born (no recorded origin).
#' @param ped the pedigree information in datatable format with required
#' colnames \code{id}, \code{sire}, \code{dam}, \code{gen}, \code{population}).
#' This requires complete pedigree information..
#' @param guCutoff Optional numeric genome-uniqueness threshold above which an
#' animal qualifies for the high-uniqueness tier. \code{NULL} (the default)
#' resolves to \code{10L}, today's hardcoded cutoff.
#' @param zScoreCutoff Optional numeric mean-kinship z-score threshold at or
#' below which an animal qualifies for the low-kinship tier. \code{NULL} (the
#' default) resolves to \code{0.25}, today's hardcoded cutoff.
#' @param axisPriority Optional string, one of \code{"gu"} or \code{"mk"},
#' naming which axis's cutoff-filter is applied first -- this decides both
#' which tier claims an animal that qualifies for both axes and the tiers'
#' relative stacking order. \code{NULL} (the default) resolves to
#' \code{"gu"}, today's behavior (high-uniqueness filtered before low-kinship).
#' @return A dataframe, which is \code{rpt} sorted according to the ranking
#' scheme:
#' \itemize{
#'  \item imported animals with no offspring
#'  \item animals with genome uniqueness above \code{guCutoff}, ranked by
#'  descending gu
#'  \item animals with mean-kinship z-score no greater than
#'  \code{zScoreCutoff}, ranked by ascending zScores
#'  \item all remaining animals, ranked by ascending zScores
#' }
#'
#' @noRd
orderReport <- function(rpt, ped, guCutoff = NULL, zScoreCutoff = NULL,
                        axisPriority = NULL) {
  # Issue #125 Slice 1: NULL-resolve here, once, at the top of this function's
  # own body -- orderReport() is not a wrapper around a pre-existing accessor
  # (see the plan's Dragon R2), so reportGV()/gvaConvergence() pass whatever
  # they have straight through with no branching of their own.
  guCutoff <- if (is.null(guCutoff)) 10L else guCutoff
  zScoreCutoff <- if (is.null(zScoreCutoff)) 0.25 else zScoreCutoff
  axisPriority <- if (is.null(axisPriority)) {
    "gu"
  } else {
    match.arg(axisPriority, c("gu", "mk"))
  }

  finalRpt <- list()

  # Issue #9 Slice 3: both-unknown founders (U-id aware via parentage, falling
  # back to getFounders) are split by recorded origin. Genuine imports (origin
  # present) are kept and ranked; ONPRC-born founders with no recorded origin
  # -- including those WITH offspring -- become noParentage so the displayed
  # rank can demote them. An absent origin column is treated as all-NA.
  bothUnknown <- if ("parentage" %in% names(rpt)) {
    rpt$parentage == "both unknown"
  } else {
    rpt$id %in% getFounders(ped)
  }
  origin <- if ("origin" %in% names(rpt)) {
    rpt$origin
  } else {
    rep(NA_character_, nrow(rpt))
  }

  # imports: both-unknown founders with a recorded origin -> kept and ranked
  i <- !is.na(origin) & bothUnknown
  imports <- rpt[i, ]
  if ("age" %in% names(imports)) {
    finalRpt$imports <- imports[with(imports, order(age)), ]
  } else {
    finalRpt$imports <- imports[with(imports, order(id)), ]
  }
  rpt <- rpt[!i, ]
  origin <- origin[!i]
  bothUnknown <- bothUnknown[!i]

  # ONPRC-born both-unknown founders (no recorded origin) -> noParentage
  i <- is.na(origin) & bothUnknown
  noParentage <- rpt[i, ]
  if ("age" %in% names(noParentage)) {
    finalRpt$noParentage <- noParentage[with(noParentage, order(age)), ]
  } else {
    finalRpt$noParentage <- noParentage[with(noParentage, order(id)), ]
  }
  rpt <- rpt[!i, ]

  # Issue #125 Slice 1: axisPriority decides which cutoff-filter runs first on
  # the still-unfiltered pool, which decides both tier MEMBERSHIP (a
  # dual-qualifying animal is claimed by whichever axis goes first) and the
  # tier STACKING order (Dragon R3 -- these two must not drift independently).
  claimHighGu <- function(pool) {
    highGu <- pool[(pool$gu > guCutoff), ]
    list(
      claimed = highGu[with(highGu, order(-trunc(gu), zScores)), ],
      remainder = pool[(pool$gu <= guCutoff), ]
    )
  }
  claimLowMk <- function(pool) {
    lowMk <- pool[(pool$zScores <= zScoreCutoff), ]
    list(
      claimed = lowMk[with(lowMk, order(zScores)), ],
      remainder = pool[(pool$zScores > zScoreCutoff), ]
    )
  }

  if (axisPriority == "mk") {
    mkFirst <- claimLowMk(rpt)
    finalRpt$lowMk <- mkFirst$claimed
    guSecond <- claimHighGu(mkFirst$remainder)
    finalRpt$highGu <- guSecond$claimed
    rpt <- guSecond$remainder

    tierOrder <- c("imports", "lowMk", "highGu", "lowVal", "noParentage")
  } else {
    guFirst <- claimHighGu(rpt)
    finalRpt$highGu <- guFirst$claimed
    mkSecond <- claimLowMk(guFirst$remainder)
    finalRpt$lowMk <- mkSecond$claimed
    rpt <- mkSecond$remainder

    tierOrder <- c("imports", "highGu", "lowMk", "lowVal", "noParentage")
  }

  # subjects claimed by neither axis
  finalRpt$lowVal <- rpt[with(rpt, order(zScores)), ]

  includeCols <- intersect(tierOrder, names(finalRpt))

  finalRpt <- finalRpt[includeCols]
  finalRpt <- rankSubjects(finalRpt)
  finalRpt <- do.call("rbind", finalRpt)
  rownames(finalRpt) <- seq_len(nrow(finalRpt))
  finalRpt
}
