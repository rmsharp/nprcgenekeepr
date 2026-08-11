## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# De-Identified Pedigree Export -- Slice 1 (issue #150)
# Core, script-callable helper (below). The Shiny module
# (modDeidentifiedExportUI/modDeidentifiedExportServer, Slice 2) follows it --
# docs/planning/issue150-deidentified-pedigree-export-plan.md sec 5.

#' Build the de-identified export's transformation manifest (D4)
#'
#' A "non-sensitive ... auditable" record of how a de-identified pedigree
#' export was produced: export timestamp, package version, the exact
#' \code{\link{obfuscatePed}} parameters used, the exported row count, and a
#' copy of the confirm-gate warning text shown to the curator. Deliberately
#' \strong{never} includes the id map (kept separate and locally-downloaded
#' per D5) or any raw pre-obfuscation value -- mirrors
#' \code{.buildCrossCenterMergeProvenance}'s shape
#' (\code{R/modCrossCenterIdentity.R}).
#'
#' @param pedRows the exported (already de-identified) pedigree data.frame --
#' only its row count is used.
#' @param size,maxDelta,linkedDateShift the \code{\link{obfuscatePed}}
#' parameters used to produce \code{pedRows}.
#' @param warningText the D6 institutional-responsibility warning text shown
#' at the confirm gate.
#' @return A one-row data.frame with columns \code{timestamp},
#' \code{packageVersion}, \code{size}, \code{maxDelta},
#' \code{linkedDateShift}, \code{nRows}, \code{warningText}.
#' @noRd
.buildDeidentificationManifest <- function(pedRows, size, maxDelta,
                                            linkedDateShift, warningText) {
  data.frame(
    timestamp = format(Sys.time()),
    packageVersion = getVersion(date = FALSE),
    size = size,
    maxDelta = maxDelta,
    linkedDateShift = linkedDateShift,
    nRows = nrow(pedRows),
    warningText = warningText,
    stringsAsFactors = FALSE
  )
}

# The D6-ratified institutional-responsibility warning text (issue #150 sec 3
# D6 / sec 11 ratification) -- this app's first such disclaimer (sec 2.10:
# no prior wording exists anywhere in R/ to reuse). Shown both statically on
# the Configure tab and inside the modalDialog() confirm gate, so a curator
# sees it before reaching Confirm, not only at the gate itself.
.deidentifiedExportWarningText <- paste(
  "This export removes identifying ids, names, and shifts dates -- it does",
  "not verify or enforce who you may share it with. Confirming that your",
  "institution's data-sharing and authorization policies permit this export",
  "and its intended recipient(s) is your responsibility, not this tool's.",
  "Fields other than id, dam, sire, dates, and name are exported unchanged",
  "-- review for sensitivity before sharing."
)

#' De-Identified Export Module - UI Function
#'
#' A Shiny workflow around the existing, tested de-identification primitives
#' (\code{\link{obfuscatePed}}) and this file's \code{
#' .buildDeidentificationManifest}: configure export parameters, preview the
#' de-identified output for the pedigree already loaded in the current
#' session, confirm via a modal gate, and download 3 artifacts -- the
#' de-identified pedigree, a transformation manifest, and a distinctly
#' labeled re-identification key.
#'
#' Unlike \code{\link{modCrossCenterIdentityUI}} (issue #149), this module has
#' no \code{fileInput} -- it reads the pedigree the curator is already working
#' with (D1), so there is no Upload/Validate stage, only Configure & Preview,
#' then Export (D2).
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} object containing the module's UI.
#' @seealso \code{\link{modDeidentifiedExportServer}} for server logic.
#' @importFrom shiny NS div h3 h5 icon helpText wellPanel numericInput
#' @importFrom shiny checkboxInput sidebarLayout sidebarPanel mainPanel
#' @importFrom shiny actionButton tabsetPanel tabPanel uiOutput downloadButton
#' @importFrom shiny br
#' @importFrom DT DTOutput
#' @family Shiny modules
#' @export
modDeidentifiedExportUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "deidentifiedExport",

    h3("De-Identified Export"),

    sidebarLayout(
      sidebarPanel(
        helpText(
          "Export the pedigree already loaded in this session with ids,",
          "names, and dates de-identified for approved external data",
          "sharing. Relationships are preserved exactly -- only identity",
          "and absolute dates change."
        ),
        wellPanel(
          h5(icon("sliders-h"), "Configuration"),
          numericInput(ns("size"), "Alias id length:",
                       value = 6L, min = 4L, max = 20L),
          numericInput(ns("maxDelta"), "Maximum date shift (days):",
                       value = 30L, min = 1L, max = 365L),
          checkboxInput(
            ns("linkedDateShift"),
            "Preserve each individual's date gaps (recommended)",
            value = TRUE
          )
        ),
        div(class = "alert alert-warning",
            icon("triangle-exclamation"),
            helpText(.deidentifiedExportWarningText)),
        actionButton(ns("preview"), "Generate Preview",
                     icon = icon("eye"), class = "btn-primary btn-block")
      ),

      mainPanel(
        tabsetPanel(
          id = ns("mainTabs"),

          tabPanel(
            "Configure & Preview",
            icon = icon("eye"),
            br(),
            uiOutput(ns("previewGuidanceUI")),
            DT::DTOutput(ns("previewTable")),
            br(),
            actionButton(ns("confirmExport"), "Confirm Export",
                         icon = icon("check-double"), class = "btn-success")
          ),

          tabPanel(
            "Export",
            icon = icon("download"),
            br(),
            uiOutput(ns("exportGateUI")),
            downloadButton(ns("downloadPedigree"),
                           "Download De-Identified Pedigree"),
            downloadButton(ns("downloadManifest"),
                           "Download Transformation Manifest"),
            br(), br(),
            downloadButton(ns("downloadMap"),
                           "Download Re-identification Key (DO NOT SHARE)",
                           class = "btn-danger")
          )
        )
      )
    )
  )
}

#' De-Identified Export Module - Server Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigree reactive returning the current pedigree data.frame
#' (\code{shared$currentPedigree}, D1) -- not a fresh upload, unlike
#' \code{\link{modCrossCenterIdentityServer}}.
#'
#' @return A list with reactive components:
#' \itemize{
#'   \item \code{exportedPedigree} - the most recent \code{\link{obfuscatePed}}
#'     output
#'   \item \code{map} - the corresponding id alias map (\code{obfuscatePed}'s
#'     \code{map=TRUE} return)
#'   \item \code{manifest} - the D4 transformation manifest, built from the
#'     EXACT parameters that produced \code{exportedPedigree} (captured at
#'     preview time, not re-read from live input state -- a curator who tweaks
#'     the configuration after previewing but before exporting must not get a
#'     manifest describing different parameters than what was actually
#'     exported)
#'   \item \code{confirmed} - logical: has the modal confirm gate been
#'     accepted for the current preview. Resets to \code{FALSE} whenever the
#'     preview is regenerated (mirrors
#'     \code{\link{modCrossCenterIdentityServer}}'s own D5 stale-confirmation
#'     -reset pattern), so a stale confirmation can never silently unlock
#'     exports for changed output.
#' }
#'
#' Downloads are not hard-gated on \code{confirmed} (mirroring
#' \code{modCrossCenterIdentityServer}'s own precedent exactly) -- per this
#' issue's own ratified framing, "curator-controlled" means a confirmation
#' dialog and warning text, not real access control (sec 1.2).
#'
#' @seealso \code{\link{modDeidentifiedExportUI}} for the user interface.
#' @seealso \code{\link{obfuscatePed}} for the underlying de-identification.
#' @importFrom shiny moduleServer reactive reactiveVal observeEvent req
#' @importFrom shiny renderUI showModal removeModal modalDialog modalButton
#' @importFrom shiny tagList p downloadHandler showNotification div
#' @importFrom DT renderDT
#' @importFrom utils write.csv
#' @family Shiny modules
#' @export
modDeidentifiedExportServer <- function(id, pedigree) {

  moduleServer(id, function(input, output, session) {

    # Holds list(ped=, map=, size=, maxDelta=, linkedDateShift=) from the
    # most recent Generate Preview click. Params are snapshotted here (not
    # re-read from input$... later) so the manifest can never drift from
    # what was actually exported.
    exportRaw <- reactiveVal(NULL)
    confirmed <- reactiveVal(FALSE)

    observeEvent(input$preview, {
      req(pedigree())
      confirmed(FALSE)

      size <- if (!is.null(input$size)) input$size else 6L
      maxDelta <- if (!is.null(input$maxDelta)) input$maxDelta else 30L
      linkedDateShift <- if (is.null(input$linkedDateShift)) {
        TRUE
      } else {
        isTRUE(input$linkedDateShift)
      }

      obf <- obfuscatePed(pedigree(), size = size, maxDelta = maxDelta,
                           map = TRUE, linkedDateShift = linkedDateShift)

      exportRaw(list(ped = obf$ped, map = obf$map, size = size,
                      maxDelta = maxDelta,
                      linkedDateShift = linkedDateShift))

      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

    result <- reactive({
      req(exportRaw())
      exportRaw()
    })

    manifest <- reactive({
      res <- result()
      .buildDeidentificationManifest(
        pedRows = res$ped, size = res$size, maxDelta = res$maxDelta,
        linkedDateShift = res$linkedDateShift,
        warningText = .deidentifiedExportWarningText
      )
    })

    output$previewGuidanceUI <- renderUI({
      if (is.null(pedigree())) {
        div(class = "alert alert-warning",
            "Load a pedigree via the Input tab before generating a",
            "de-identified export.")
      } else if (is.null(exportRaw())) {
        div(class = "alert alert-info",
            "Configure export parameters and click \"Generate Preview\" to",
            "see the de-identified output.")
      } else {
        div(class = "alert alert-secondary",
            "Displayed ages are recomputed from the shifted dates above --",
            "not the original recorded values.")
      }
    })

    output$previewTable <- DT::renderDT({
      result()$ped
    }, options = list(pageLength = 10L))

    observeEvent(input$confirmExport, {
      req(exportRaw())
      showModal(modalDialog(
        title = "Confirm De-Identified Export",
        p(.deidentifiedExportWarningText),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(session$ns("confirmExportOk"), "Confirm Export",
                       class = "btn-success")
        )
      ))
    })

    observeEvent(input$confirmExportOk, {
      req(exportRaw())
      confirmed(TRUE)
      removeModal()
    })

    output$exportGateUI <- renderUI({
      if (!confirmed()) {
        div(class = "alert alert-info",
            "Confirm the export on the Configure & Preview tab to unlock",
            "downloads.")
      }
    })

    output$downloadPedigree <- downloadHandler(
      filename = function() {
        paste0("deidentified_pedigree_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(result()$ped, file, row.names = FALSE)
      }
    )

    output$downloadManifest <- downloadHandler(
      filename = function() {
        paste0("deidentification_manifest_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(manifest(), file, row.names = FALSE)
      }
    )

    output$downloadMap <- downloadHandler(
      filename = function() {
        paste0("reidentification_key_DO_NOT_SHARE_", Sys.Date(), ".csv")
      },
      content = function(file) {
        mapVec <- result()$map
        write.csv(
          data.frame(originalId = names(mapVec), aliasId = unname(mapVec),
                     stringsAsFactors = FALSE),
          file, row.names = FALSE
        )
      }
    )

    list(
      exportedPedigree = reactive({
        result()$ped
      }),
      map = reactive({
        result()$map
      }),
      manifest = manifest,
      confirmed = reactive({
        confirmed()
      })
    )
  })
}
