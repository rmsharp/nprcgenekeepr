## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

.onLoad <- function(libname, pkgname) {
  shiny::addResourcePath("sbs", system.file("www", package = "shinyBS"))
}
