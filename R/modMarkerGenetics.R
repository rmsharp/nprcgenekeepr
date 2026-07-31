## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Marker Genetics Shiny Module

#' Marker Genetics Module - UI Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} containing the marker-genetics UI: a marker
#'   genotype file upload control, a guidance area, and the pedigree-vs-
#'   marker mean-kinship comparison table.
#'
#' @seealso \code{\link{modMarkerGeneticsServer}}
#' @importFrom shiny NS div h3 fluidRow column wellPanel fileInput
#' @importFrom shiny uiOutput
#' @importFrom DT DTOutput
#' @family Shiny modules
#' @export
modMarkerGeneticsUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "markerGenetics",

    h3("Marker Genetics"),
    fluidRow(
      column(4L,
             wellPanel(
               fileInput(ns("genotypeFile"),
                         "Select Marker Genotype File (CSV)",
                         accept = c(".csv"))
             )
      ),
      column(8L,
             uiOutput(ns("guidance")),
             DT::DTOutput(ns("comparisonTable"))
      )
    )
  )
}

#' Marker Genetics Module - Server Function
#'
#' Reads an uploaded long-format marker genotype file (D1 format: \code{id},
#' \code{locus}, \code{allele1}, \code{allele2}), validates and pivots it
#' (\code{\link{checkMarkerGenotypeFile}}, \code{\link{buildMarkerGenotypeMatrix}}),
#' estimates marker-based kinship independent of pedigree
#' (\code{\link{markerKinship}}), and surfaces a per-animal comparison of
#' pedigree-based mean kinship (\code{indivMeanKin}, already computed
#' upstream and passed in via \code{kinshipMatrix}) alongside the new
#' marker-based mean kinship (\code{markerMeanKin}) -- an independent check
#' on the pedigree-implied relatedness, not a replacement for it.
#'
#' This module never touches the existing single-locus genotype path
#' (\code{checkGenotypeFile}/\code{addGenotype}/\code{hasGenotype}/
#' \code{getGVGenotype}/\code{geneDrop}) -- the D1 long-format schema is a
#' new, sibling concern.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param kinshipMatrix reactive returning the full pedigree-based kinship
#'   matrix (row and column names are animal IDs), or \code{NULL} while
#'   upstream analysis has not yet been run.
#'
#' @return A list with four reactive elements: \code{markerGenotype}, the
#'   raw uploaded genotype data frame (or \code{NULL} before upload);
#'   \code{markerKinshipMatrix}, the marker-based \code{id} x \code{id}
#'   kinship matrix (or \code{NULL}); \code{comparisonTable}, the per-animal
#'   \code{indivMeanKin}/\code{markerMeanKin} comparison data frame (or
#'   \code{NULL}); and \code{isReady}, \code{TRUE} once
#'   \code{comparisonTable} has a value.
#'
#' @seealso \code{\link{modMarkerGeneticsUI}}
#' @importFrom shiny moduleServer reactive renderUI observe req div
#' @importFrom DT renderDT
#' @family Shiny modules
#' @export
modMarkerGeneticsServer <- function(id, kinshipMatrix) {
  moduleServer(id, function(input, output, session) {

    ## Upstream absence (pedigree kinship not yet computed) is treated as
    ## not-ready (NULL), per module-contract rule 5 -- but a malformed
    ## uploaded genotype file is NOT caught here: checkMarkerGenotypeFile()/
    ## buildMarkerGenotypeMatrix()/markerKinship() are called with no
    ## surrounding tryCatch, so a real validation error surfaces as a
    ## genuine Shiny reactive error, not a silent NULL.
    safeRead <- function(r) tryCatch(r(), error = function(e) NULL)

    rawGenotype <- reactive({
      if (is.null(input$genotypeFile)) {
        return(NULL)
      }
      getGenotypes(input$genotypeFile$datapath, sep = ",")
    })

    markerKmat <- reactive({
      raw <- rawGenotype()
      if (is.null(raw)) {
        return(NULL)
      }
      checked <- checkMarkerGenotypeFile(raw)
      genotypeMatrix <- buildMarkerGenotypeMatrix(checked)
      markerKinship(genotypeMatrix)
    })

    comparison <- reactive({
      mkmat <- markerKmat()
      if (is.null(mkmat)) {
        return(NULL)
      }
      markerMean <- meanKinship(mkmat)
      ids <- names(markerMean)

      pedKmat <- safeRead(kinshipMatrix)
      pedMean <- if (is.null(pedKmat)) {
        rep(NA_real_, length(ids))
      } else {
        as.numeric(meanKinship(pedKmat)[ids])
      }

      data.frame(
        id = ids,
        indivMeanKin = pedMean,
        markerMeanKin = as.numeric(markerMean),
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    })

    output$comparisonTable <- DT::renderDT({
      tbl <- comparison()
      req(tbl)
      tbl
    })

    output$guidance <- renderUI({
      if (is.null(comparison())) {
        div(
          class = "alert alert-info",
          paste(
            "Upload a marker genotype file to see the pedigree-vs-marker",
            "kinship comparison."
          )
        )
      }
    })

    # Signal data-ready when the comparison table is available (for E2E
    # testing).
    observe({
      req(comparison())
      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

    list(
      markerGenotype = reactive(rawGenotype()),
      markerKinshipMatrix = reactive(markerKmat()),
      comparisonTable = reactive(comparison()),
      isReady = reactive(!is.null(comparison()))
    )
  })
}
