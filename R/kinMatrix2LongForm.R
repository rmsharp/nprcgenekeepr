## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Reformat a kinship matrix into long form
#'
#' Part of Group Formation
#'
#' @param kinMatrix numerical matrix of pairwise kinship values. The row and
#' column names correspond to animal IDs.
#' @param removeDups logical value indication whether or not reverse-order ID
#' pairs be filtered out? (i.e., "ID1 ID2 kin_val" and "ID2 ID1 kin_val" will
#' be collapsed into a single entry if removeDups = TRUE)
#'
#' @return A dataframe with columns \code{id1}, \code{id2}, and \code{kinship}.
#' This is the kinship data reformatted from a matrix, to a long-format table.
#'
#' @importFrom utils stack
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
#' reformattedKmat <- kinMatrix2LongForm(kmat, removeDups = FALSE)
#' nrow(reformattedKmat)
#' reformattedNoDupsKmat <- kinMatrix2LongForm(kmat, removeDups = TRUE)
#' nrow(reformattedNoDupsKmat)
kinMatrix2LongForm <- function(kinMatrix, removeDups = FALSE) {
  ## Performance plan Phase 6 (S1059): a matrix the direct build below was not
  ## built for runs today's code unchanged (owner ruling).
  if (!longFormFits(kinMatrix, removeDups)) {
    return(kinMatrix2LongFormGeneral(kinMatrix, removeDups))
  }
  m <- nrow(kinMatrix)
  p <- ncol(kinMatrix)
  ## One row per cell in column order, as stack() made them: id1 names the
  ## column, id2 the row.
  if (!removeDups && !anyNA(kinMatrix)) {
    kin <- list(id1 = rep(colnames(kinMatrix), each = m),
                id2 = rep(rownames(kinMatrix), times = p),
                kinship = as.vector(kinMatrix))
    attr(kin, "row.names") <- c(NA_integer_, -(m * p))
    class(kin) <- "data.frame"
    return(kin)
  }
  ## Some cells are left out: the upper triangle (removeDups) and the missing
  ## kinships. The rows kept are named by their cell's position, as today's
  ## subset of the stacked rows named them.
  if (removeDups) {
    cols <- seq_len(min(m, p))
    keep <- sequence(m - cols + 1L, from = (cols - 1L) * m + cols)
    keep <- keep[!is.na(kinMatrix[keep])]
  } else {
    keep <- which(!is.na(kinMatrix))
  }
  position <- keep - 1L
  kin <- list(id1 = colnames(kinMatrix)[position %/% m + 1L],
              id2 = rownames(kinMatrix)[position %% m + 1L],
              kinship = kinMatrix[keep])
  attr(kin, "row.names") <- keep
  class(kin) <- "data.frame"
  kin
}

#' Whether kinMatrix2LongForm()'s direct build takes a matrix
#'
#' Performance plan Phase 6: \code{kinMatrix2LongForm()} builds its columns
#' directly from a base double matrix with at least one row and one column,
#' row and column names that are present, unique and not missing, and fewer
#' cells than the largest integer, when \code{removeDups} is \code{TRUE} or
#' \code{FALSE}. Any other input runs \code{kinMatrix2LongFormGeneral()},
#' today's code, so it keeps today's result, error and warnings.
#'
#' @inheritParams kinMatrix2LongForm
#' @return \code{TRUE} or \code{FALSE}.
#' @noRd
longFormFits <- function(kinMatrix, removeDups) {
  if (!(isTRUE(removeDups) || isFALSE(removeDups)) || !is.matrix(kinMatrix) ||
        !is.double(kinMatrix) || is.object(kinMatrix)) {
    return(FALSE)
  }
  rows <- rownames(kinMatrix)
  cols <- colnames(kinMatrix)
  nrow(kinMatrix) >= 1L && ncol(kinMatrix) >= 1L &&
    !is.null(rows) && !is.null(cols) && !anyNA(rows) && !anyNA(cols) &&
    !anyDuplicated(rows) && !anyDuplicated(cols) &&
    as.numeric(nrow(kinMatrix)) * ncol(kinMatrix) <= .Machine$integer.max
}

#' Today's long form, for any matrix
#'
#' \code{kinMatrix2LongForm()} before performance plan Phase 6, word for
#' word: \code{as.data.frame()} and \code{stack()}, then the missing kinships
#' dropped. \code{kinMatrix2LongForm()} calls it for a matrix its direct build
#' was not built for, which keeps that matrix's result, error and warnings.
#'
#' @inheritParams kinMatrix2LongForm
#' @return As \code{kinMatrix2LongForm()}.
#' @noRd
kinMatrix2LongFormGeneral <- function(kinMatrix, removeDups = FALSE) {
  if (removeDups) {
    kinMatrix[upper.tri(kinMatrix)] <- NA
  }

  kmat <- as.data.frame(kinMatrix)
  k <- stack(kmat)
  k["id2"] <- row.names(kmat)

  colnames(k) <- c("kinship", "id1", "id2")
  k$id1 <- as.character(k$id1)

  k <- k[!is.na(k$kinship), ]

  k[, c("id1", "id2", "kinship")]
}
