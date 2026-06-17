# Potential Parents Shiny Module (#48)

#' Flatten getPotentialParents() output into a render/CSV-ready data.frame
#'
#' Converts the per-animal list-of-lists returned by
#' \code{\link{getPotentialParents}} (or \code{NULL}) into a single
#' data.frame with one row per animal and the candidate sire/dam IDs
#' collapsed into comma-separated strings. \code{NULL} or an empty list
#' maps to a 0-row data.frame carrying the same columns (the empty state).
#'
#' @param potentialParents the list returned by \code{getPotentialParents}:
#'   each element a list with \code{id}, \code{sires}, and \code{dams}. May be
#'   \code{NULL}.
#' @return a data.frame with columns \code{id}, \code{nSires}, \code{nDams},
#'   \code{sires}, \code{dams}.
#' @keywords internal
#' @noRd
flattenPotentialParents <- function(potentialParents) {
  emptyDf <- data.frame(
    id = character(0L),
    nSires = integer(0L),
    nDams = integer(0L),
    sires = character(0L),
    dams = character(0L),
    stringsAsFactors = FALSE
  )
  if (is.null(potentialParents) || length(potentialParents) == 0L) {
    return(emptyDf)
  }
  data.frame(
    id = vapply(potentialParents,
                function(x) as.character(x$id)[1L], character(1L)),
    nSires = vapply(potentialParents,
                    function(x) length(x$sires), integer(1L)),
    nDams = vapply(potentialParents,
                   function(x) length(x$dams), integer(1L)),
    sires = vapply(potentialParents,
                   function(x) toString(x$sires), character(1L)),
    dams = vapply(potentialParents,
                  function(x) toString(x$dams), character(1L)),
    stringsAsFactors = FALSE
  )
}

#' Potential Parents Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' Creates the user interface for identifying potential parents of in-colony
#' animals that have at least one unknown parent. The user sets a maximum
#' gestational period, presses a button to compute candidate sires and dams
#' on the current pedigree, views a sortable results table, and downloads the
#' results as CSV.
#'
#' @return A \code{div} object containing the Potential Parents UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modPotentialParentsServer}} for server logic.
#' @seealso \code{\link{getPotentialParents}} for the underlying computation.
#' @importFrom shiny NS div h3 p fluidRow column numericInput helpText br
#' @importFrom shiny actionButton downloadButton uiOutput hr icon
#' @export
modPotentialParentsUI <- function(id) {
  ns <- NS(id)

  div(
    h3("Potential Parents"),
    p("Identify candidate sires and dams for in-colony animals that have at ",
      "least one unknown parent. Candidates are screened using estimated ",
      "conception dates (birth minus the maximum gestational period)."),

    fluidRow(
      column(
        4L,
        numericInput(
          ns("maxGestationalPeriod"),
          label = "Maximum Gestational Period (days)",
          value = 210L, min = 1L, step = 1L
        ),
        helpText(
          style = "font-size: 11px; color: #666;",
          paste(
            "A conservative upper bound on days from conception to birth for",
            "the species (e.g. 210 for rhesus; typical gestation ~165 days)."
          )
        )
      ),
      column(
        4L,
        br(),
        actionButton(
          ns("findParents"), "Find Potential Parents",
          icon = icon("search"), class = "btn-primary"
        )
      ),
      column(
        4L,
        br(),
        downloadButton(ns("downloadParents"), "Download CSV")
      )
    ),

    hr(),
    uiOutput(ns("statusMessage")),
    DT::DTOutput(ns("resultsTable"))
  )
}

#' Potential Parents Module - Server Function
#'
#' Server logic for the Potential Parents module. On button press, it calls
#' \code{\link{getPotentialParents}} against the current pedigree, flattens the
#' result into a sortable table, and exposes it for CSV download. The surface
#' degrades gracefully when no pedigree is loaded, when the pedigree lacks the
#' \code{fromCenter} colony-origin field, or when no in-colony animal has an
#' unknown parent.
#'
#' @return A list of reactive expressions:
#' \itemize{
#'   \item \code{potentialParents} - the raw \code{getPotentialParents} result
#'     (or \code{NULL}).
#'   \item \code{tableData} - the flattened results data.frame.
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigree reactive returning the current pedigree data.frame.
#' @param minParentAge numeric minimum age in years for an animal to be a
#'   parent. Defaults to 2 (the QC default).
#'
#' @seealso \code{\link{modPotentialParentsUI}} for the user interface.
#' @seealso \code{\link{getPotentialParents}} for the underlying computation.
#' @importFrom shiny moduleServer eventReactive reactive renderUI
#' @importFrom shiny downloadHandler div helpText
#' @importFrom utils write.csv
#' @export
modPotentialParentsServer <- function(id, pedigree = NULL, minParentAge = 2.0) {
  moduleServer(id, function(input, output, session) {

    potentialParents <- eventReactive(input$findParents, {
      ped <- tryCatch(pedigree(), error = function(e) NULL)
      if (is.null(ped)) {
        return(NULL)
      }
      maxGest <- input$maxGestationalPeriod
      if (is.null(maxGest) || is.na(maxGest)) {
        maxGest <- 210L
      }
      getPotentialParents(
        ped = ped, minParentAge = minParentAge,
        maxGestationalPeriod = maxGest
      )
    })

    tableData <- reactive({
      pp <- tryCatch(potentialParents(), error = function(e) NULL)
      flattenPotentialParents(pp)
    })

    output$statusMessage <- renderUI({
      if (is.null(input$findParents) || input$findParents == 0L) {
        return(helpText(
          "Set the maximum gestational period, then click ",
          "'Find Potential Parents'."
        ))
      }
      ped <- tryCatch(pedigree(), error = function(e) NULL)
      if (is.null(ped) || !is.data.frame(ped) || nrow(ped) == 0L) {
        return(div(
          class = "alert alert-warning",
          "No pedigree is loaded. Create a pedigree first using the Input ",
          "and Pedigree Browser tabs."
        ))
      }
      if (!"fromCenter" %in% names(ped)) {
        return(div(
          class = "alert alert-warning",
          "This dataset has no colony-origin ('fromCenter') field, so ",
          "potential parents cannot be identified."
        ))
      }
      td <- tableData()
      if (nrow(td) == 0L) {
        return(div(
          class = "alert alert-info",
          "No in-colony animals with unknown parents were found."
        ))
      }
      helpText(paste0(
        "Found candidate parents for ", nrow(td),
        " animal(s) with at least one unknown parent."
      ))
    })

    output$resultsTable <- DT::renderDT({
      DT::datatable(
        tableData(),
        rownames = FALSE,
        colnames = c("Animal", "# Sires", "# Dams",
                     "Candidate Sires", "Candidate Dams"),
        options = list(pageLength = 25L)
      )
    })

    output$downloadParents <- downloadHandler(
      filename = function() {
        paste0("potential_parents_", Sys.Date(), ".csv")
      },
      content = function(file) {
        utils::write.csv(tableData(), file, row.names = FALSE)
      }
    )

    list(
      potentialParents = potentialParents,
      tableData = tableData
    )
  })
}
