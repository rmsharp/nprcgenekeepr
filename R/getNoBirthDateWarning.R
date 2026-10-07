## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' The Input tab's warning about animals with no birth date
#'
#' Builds the one row the QC warnings table gets when animals in the cleaned
#' pedigree have no birth date. Every animal with no birth date counts,
#' whatever its sex, status or exit date.
#'
#' @param ped data frame that is the cleaned pedigree, as
#' \code{runQcStudbook()} holds it after its second pass. A pedigree with no
#' \code{birth} column has no animals to count.
#' @return A data frame with the columns \code{Row}, \code{Warning} and
#' \code{Details}, in the shape of the \code{warnings} table that
#' \code{processQcStudbookResult()} returns: one row, or no rows when every
#' animal has a birth date.
#' @noRd
getNoBirthDateWarning <- function(ped) {
  nNoBirth <- sum(is.na(ped[["birth"]]))
  if (nNoBirth == 0L) {
    return(data.frame(
      Row = integer(0L),
      Warning = character(0L),
      Details = character(0L),
      stringsAsFactors = FALSE
    ))
  }
  data.frame(
    Row = NA_integer_,
    Warning = "Animals with no birth date",
    Details = paste0(
      nNoBirth, " of ", nrow(ped), " animals ",
      if (nNoBirth == 1L) "has" else "have",
      " no birth date, so their age is unknown. Age-based checks and counts ",
      "(the parent-age check, the Age-Sex Pyramid, breeding-age counts) ",
      "cannot use them."
    ),
    stringsAsFactors = FALSE
  )
}
