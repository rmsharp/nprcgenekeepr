## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Animals the Mate Pair report leaves out because their sex is not known
#'
#' The one definition of "an animal \code{\link{reportMatePairs}} does not
#' pair": any animal of the population whose sex in \code{ped} is not male or
#' female (unknown, hermaphrodite or missing, or an id \code{ped} does not
#' list). \code{\link{reportMatePairs}} drops exactly these animals, and the
#' Mate Pair page counts them for its one sentence, so the two cannot disagree.
#'
#' @param ped data frame with \code{id} and \code{sex} columns.
#' @param kmat kinship matrix whose row names are the animal ids.
#' @param populationIds character vector of the ids the analysis is scoped to,
#' applied through \code{\link{filterKinMatrix}} as in
#' \code{\link{reportMatePairs}}; \code{NULL} (the default) scopes to every
#' animal of \code{kmat}.
#' @return character vector of the ids left out, in \code{kmat} order (zero
#' length when every animal is recorded male or female; never \code{NULL}).
#' @noRd
matePairLeftOutIds <- function(ped, kmat, populationIds = NULL) {
  if (!is.null(populationIds)) {
    kmat <- filterKinMatrix(populationIds, kmat)
  }
  ids <- as.character(rownames(kmat))
  paired <- ped$id[ped$sex %in% c(sexCodes[["male"]], sexCodes[["female"]])]
  ids[!ids %in% paired]
}

#' The Mate Pair page's one sentence about the animals left out
#'
#' Shown by \code{modMatePairServer} beside the pairs (and beside the
#' "No eligible pairs found" message), from the count
#' \code{matePairLeftOutIds()} gave at the click.
#'
#' @param n number of animals left out.
#' @return \code{NULL} when \code{n} is zero; otherwise an info alert holding
#' the sentence, singular for one animal.
#' @noRd
matePairLeftOutNote <- function(n) {
  if (n > 0L) {
    div(
      class = "alert alert-info",
      sprintf(paste("%d %s not recorded as male or female %s left out of",
                    "the pairs."),
              n, if (n == 1L) "animal" else "animals",
              if (n == 1L) "was" else "were")
    )
  }
}
