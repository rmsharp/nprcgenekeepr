#' Order the results of the genetic value analysis for use in a report.
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#' Part of Genetic Value Analysis
#'
#' Takes in the results from a genetic value analysis and orders the report
#' according to the ranking scheme we have developed.
#'
#' @return A dataframe, which is \code{rpt} sorted according to the ranking
#' scheme:
#' \itemize{
#'  \item imported animals with no offspring
#'  \item animals with genome uniqueness above 10%, ranked by descending gu
#'  \item animals with mean-kinship z-score no greater than 0.25, ranked
#'  by ascending zScores
#'  \item all remaining animals, ranked by ascending zScores
#' }
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
#' @noRd
orderReport <- function(rpt, ped) {
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

  # subjects with > 10% genome uniqueness
  highGu <- rpt[(rpt$gu > 10L), ]
  finalRpt$highGu <- highGu[with(highGu, order(-trunc(gu), zScores)), ]
  rpt <- rpt[(rpt$gu <= 10L), ]

  # subjects with <= 10% genome uniqueness and <= 0.25 z-score
  lowMk <- rpt[(rpt$zScores <= 0.25), ]
  finalRpt$lowMk <- lowMk[with(lowMk, order(zScores)), ]

  rpt <- rpt[(rpt$zScores > 0.25), ]

  # subjects with <= 10% genome uniqueness and > 0.25 z-score
  finalRpt$lowVal <- rpt[with(rpt, order(zScores)), ]

  includeCols <- intersect(
    c(
      "imports", "highGu", "lowMk",
      "lowVal", "noParentage"
    ),
    names(finalRpt)
  )

  finalRpt <- finalRpt[includeCols]
  finalRpt <- rankSubjects(finalRpt)
  finalRpt <- do.call("rbind", finalRpt)
  rownames(finalRpt) <- seq_len(nrow(finalRpt))
  finalRpt
}
