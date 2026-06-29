# Genetic Value and Breeding Group Description Shiny Module

#' Genetic Value and Breeding Group Description Module - UI Function
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Creates user interface displaying detailed documentation about
#' genetic value analysis and breeding group formation algorithms.
#'
#' @return A \code{div} object containing the description HTML.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modGvAndBgDescServer}} for server logic.
#' @seealso \code{\link{modGeneticValueUI}} for genetic value analysis.
#' @seealso \code{\link{modBreedingGroupsUI}} for breeding group formation.
#' @importFrom shiny NS div h3 includeHTML
#' @export
modGvAndBgDescUI <- function(id) {
  div(
    h3("Genetic Value Analysis and Breeding Group Description"),
    div(
      style = paste(
        "padding: 15px; border: 1px solid lightgray;",
        "background-color: #EDEDED; border-radius: 15px;",
        "box-shadow: 0 0 5px 2px #888; margin: 10px;"
      ),
      includeHTML(
        system.file("extdata", "ui_guidance", "gvAndBgDesc.html",
                    package = "nprcgenekeepr")
      )
    )
  )
}

#' Genetic Value and Breeding Group Description Module - Server Function
#'
#' Server logic for genetic value and breeding group description module.
#' This module is primarily informational and does not require reactive logic.
#'
#' @return NULL (no reactive outputs).
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modGvAndBgDescUI}} for the user interface.
#' @importFrom shiny moduleServer
#' @export
modGvAndBgDescServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    # This module is informational only - no server logic required
    NULL
  })
}
