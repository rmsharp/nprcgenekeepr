## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Remove animal pairs and kinship values where an animal is younger than minAge
#'
#' Part of Group Formation
#' @param kin a dataframe with columns \code{id1}, \code{id2}, and
#' \code{kinship}. This is the kinship data reformatted from a matrix,
#' to a long-format table.
#' @inheritParams getPotentialSires
#' @param minAge numeric value representing minimum years of age of
#' animals to retain.
#' @return a dataframe with columns \code{id1}, \code{id2}, and \code{kinship}
#' with all animals greater than or equal to the minimum age.
#'
#' @noRd
filterAge <- function(kin, ped, minAge = 1L) {
  kin$sort.col <- seq_len(nrow(kin))

  a1 <- merge(kin, ped, by.x = "id1", by.y = "id", all.x = TRUE, all.y = FALSE)
  a2 <- merge(kin, ped, by.x = "id2", by.y = "id", all.x = TRUE, all.y = FALSE)

  a1 <- a1[with(a1, order(sort.col)), "age"]
  a2 <- a2[with(a2, order(sort.col)), "age"]

  keep <- (((a1 >= minAge) | is.na(a1)) & ((a2 >= minAge) | is.na(a2)))

  kin$sort.col <- NULL
  kin <- kin[keep, ]
  if (nrow(kin) > 0L) {
    rownames(kin) <- seq_len(nrow(kin))
  }
  kin
}
