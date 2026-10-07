## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' One box of the Input tab's QC Summary
#'
#' A Bootstrap 4 card: a header colored by \code{colour} holding the title,
#' and a body holding the count. The app's theme is Bootstrap 4 (bslib,
#' flatly), which has no rules for the Bootstrap 3 \code{panel} classes these
#' boxes used to carry, so the boxes showed plain grey. The three boxes
#' (Records Processed, Errors, Warnings) are all drawn here.
#'
#' @param title character the heading shown in the card header.
#' @param count the number shown in the card body.
#' @param colour character a Bootstrap contextual colour name: \code{"primary"},
#' \code{"danger"}, \code{"warning"} or \code{"success"}.
#' @return A \code{shiny.tag} (a \code{div}).
#' @noRd
qcSummaryBox <- function(title, count, colour) {
  shiny::div(
    class = paste0("card border-", colour),
    shiny::div(class = paste0("card-header bg-", colour, " text-white"),
               shiny::h4(title)),
    shiny::div(class = "card-body", shiny::h2(count))
  )
}
