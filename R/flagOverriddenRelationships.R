## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Flag overridden pairs in a relationship table
#'
#' Marks the pairwise rows whose kinship coefficient came from an
#' outside-information override (issue #13 item-3, R13). The relation
#' \emph{label} is pedigree-derived and is left unchanged; this only appends a
#' logical \code{overridden} column so a user can see which rows carry an
#' overridden value (a label and an overridden value can otherwise disagree).
#' When no overrides are supplied the table is returned unchanged, so the
#' no-override path stays byte-identical to before (D10).
#'
#' @param relationships data frame from \code{\link{convertRelationships}} with
#'   columns \code{id1}, \code{id2}, \code{kinship}, \code{relation}.
#' @param overrides validated kinship-override data frame (\code{id1},
#'   \code{id2}, \code{kinship}) or \code{NULL}.
#' @return \code{relationships} unchanged when \code{overrides} is \code{NULL}
#'   or empty; otherwise the same frame with an appended logical
#'   \code{overridden} column (\code{TRUE} for overridden pairs, matched
#'   without regard to id order).
#' @noRd
flagOverriddenRelationships <- function(relationships, overrides) {
  if (is.null(overrides) || nrow(overrides) == 0L) {
    return(relationships)
  }
  pairKey <- function(a, b) {
    a <- as.character(a)
    b <- as.character(b)
    paste(pmin(a, b), pmax(a, b), sep = "\r")
  }
  overrideKeys <- pairKey(overrides$id1, overrides$id2)
  rowKeys <- pairKey(relationships$id1, relationships$id2)
  relationships$overridden <- rowKeys %in% overrideKeys
  relationships
}
