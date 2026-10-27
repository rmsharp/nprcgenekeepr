## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Style of the grey help box under a tab's controls or chart
#'
#' Single source of truth for the CSS of the rounded grey box that holds a
#' help page from \code{inst/extdata/ui_guidance/} on the Genetic Value
#' Analysis, Age-Sex Pyramid and Genetic-Health Trends tabs. Internal helper
#' constant -- the three tabs read it from here, so their boxes cannot drift
#' apart. The other tabs' help boxes differ in padding, corners or margins and
#' keep their own style.
#' @noRd
helpBoxStyle <- paste(
  "padding: 10px; border: 1px solid lightgray;",
  "background-color: #EDEDED; border-radius: 25px;",
  "box-shadow: 0 0 5px 2px #888; margin-top: 10px;"
)
