## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' The Input tab's warning about animals that leave before they are born
#'
#' Builds the one row the QC warning table gets when animals in the cleaned
#' pedigree have an exit date (a death or a departure) earlier than their birth
#' date. An exit on the birth day is not flagged, and an animal with no exit
#' date or no birth date is left out of the count of flagged animals (it still
#' counts in the total).
#'
#' @param ped data frame that is the cleaned pedigree, as
#' \code{runQcStudbook()} holds it after its second pass. A pedigree with no
#' \code{birth} or no \code{exit} column has no animals to flag.
#' @return A data frame with the columns \code{Row}, \code{Warning} and
#' \code{Details}, in the shape of the \code{warnings} table that
#' \code{processQcStudbookResult()} returns: one row, or no rows when no animal
#' leaves before its birth. The \code{Details} name up to five animals, in the
#' order of \code{ped}.
#' @noRd
getExitBeforeBirthWarning <- function(ped) {
  # [[ matches a column name exactly and gives NULL for a missing column, so a
  # pedigree with no birth or no exit column has nothing to flag
  early <- which(ped[["exit"]] < ped[["birth"]])
  nEarly <- length(early)
  if (nEarly == 0L) {
    return(getEmptyWarningsTable())
  }
  ids <- toString(ped[["id"]][early[seq_len(min(nEarly, 5L))]])
  one <- nEarly == 1L
  data.frame(
    Row = NA_integer_,
    Warning = "Animals with a death or departure before birth",
    Details = paste0(
      nEarly, " of ", nrow(ped), " animals ",
      if (one) "has" else "have",
      " an exit date earlier than ", if (one) "its" else "their",
      " birth date (", if (nEarly > 5L) "first 5: ", ids, "). ",
      if (one) "Its" else "Their", " age comes out zero or negative. Check ",
      if (one) "that date" else "those dates", " in your file."
    ),
    stringsAsFactors = FALSE
  )
}
