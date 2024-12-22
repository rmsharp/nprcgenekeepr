#' Get minimum parent age.
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' This can be set to anything greater than or equal to 0.
#'
#' Set to 0 if you do not want to enforce parents being sexually mature
#' by age. Animals that do not have an age are ignored.
#' @param input shiny's input
#' @import shiny
#' @noRd
getMinParentAge <- function(input) {
  minParentAge <- as.numeric(renderText({
    input$minParentAge
  }))
  if (minParentAge < 0)
    stop("Minimum Parent Age must be >= 0.")
  else
    return(minParentAge)
}
