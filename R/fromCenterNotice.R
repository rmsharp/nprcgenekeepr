## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' The notice shown when the pedigree has no "fromCenter" column
#'
#' \code{getPotentialParents()} returns \code{NULL} without a
#' \code{fromCenter} (colony-origin) column, so the Potential Parents tab and
#' the Candidate Parent Assignment tab (Marker Genetics) can find no one.
#' Both tabs show this one notice, so the sentence cannot differ between them.
#'
#' @return A \code{shiny.tag} (a \code{div}).
#' @noRd
fromCenterNotice <- function() {
  shiny::div(
    class = "alert alert-warning",
    paste0(
      "This dataset has no colony-origin ('fromCenter') field, so ",
      "potential parents cannot be identified."
    )
  )
}
