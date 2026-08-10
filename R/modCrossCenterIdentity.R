## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Cross-Center Identity Mapping Shiny Module (issue #149 Slice 2)

#' Build one lineage-change row per mapped pair (D6)
#'
#' The Preview tab's row shape: for each mapped pair, the id on each side,
#' each side's originally-recorded \code{sire}/\code{dam}, and the
#' \code{\link{resolveCrossCenterIds}}-equivalent resolved value plus which
#' side it came from (\code{\link{.pickCrossCenterParent}}'s \code{source}
#' field, D2). \code{pedB}'s originally-recorded \code{sire}/\code{dam} are
#' shown in \code{pedB}'s own, un-rewritten id space (what a curator
#' actually uploaded), while the resolved value is computed against the
#' rewritten copy -- the same two-copy approach
#' \code{\link{.checkCrossCenterConflict}} uses, for the same reason
#' (Dragon #2).
#'
#' @param pedA,pedB pedigree data.frames.
#' @param mapping a mapping data.frame with columns \code{idA}/\code{idB}.
#' @return A data.frame with columns \code{idA}, \code{idB}, \code{pedA_sire},
#' \code{pedA_dam}, \code{pedB_sire}, \code{pedB_dam}, \code{resolved_sire},
#' \code{resolved_dam}, \code{sireSource}, \code{damSource} -- one row per
#' mapped pair.
#' @noRd
.buildCrossCenterLineagePreview <- function(pedA, pedB, mapping) {
  rewrittenPedB <- .rewriteCrossCenterIds(pedB, mapping)
  rows <- lapply(seq_len(nrow(mapping)), function(i) {
    idA <- mapping$idA[i]
    idB <- mapping$idB[i]
    rowA <- pedA[pedA$id == idA, , drop = FALSE][1L, ]
    origRowB <- pedB[pedB$id == idB, , drop = FALSE][1L, ]
    rowB <- rewrittenPedB[rewrittenPedB$id == idA, , drop = FALSE][1L, ]

    sireResult <- .pickCrossCenterParent(rowA, rowB, "sire")
    damResult <- .pickCrossCenterParent(rowA, rowB, "dam")

    data.frame(
      idA = idA, idB = idB,
      pedA_sire = rowA$sire, pedA_dam = rowA$dam,
      pedB_sire = origRowB$sire, pedB_dam = origRowB$dam,
      resolved_sire = sireResult$value, resolved_dam = damResult$value,
      sireSource = sireResult$source, damSource = damResult$source,
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, rows)
}

#' Build the Provenance export artifact (D8, bullet 5)
#'
#' One row per merged individual (\code{idA}, \code{sireSource},
#' \code{damSource}, from \code{\link{.buildCrossCenterLineagePreview}}),
#' with the scalar provenance fields (\code{timestamp}, the 3 uploaded file
#' names, \code{\link{getVersion}}'s package version, and the D6 summary
#' counts) repeated on every row via ordinary \code{data.frame()} recycling.
#'
#' @param pedAFileName,pedBFileName,mappingFileName the 3 uploaded
#' \code{fileInput}'s own \code{$name} fields (Dragon #5: user-supplied
#' display text, never used for identity/dedup logic).
#' @param pedA,pedB,mapping the 3 uploaded data.frames.
#' @param merged the \code{\link{resolveCrossCenterIds}} output.
#' @param lineagePreview \code{\link{.buildCrossCenterLineagePreview}}'s
#' output.
#' @return A data.frame -- see the D8 bullet 5 field list above.
#' @noRd
.buildCrossCenterMergeProvenance <- function(pedAFileName, pedBFileName,
                                              mappingFileName, pedA, pedB,
                                              mapping, merged,
                                              lineagePreview) {
  data.frame(
    timestamp = format(Sys.time()),
    pedAFileName = pedAFileName,
    pedBFileName = pedBFileName,
    mappingFileName = mappingFileName,
    packageVersion = getVersion(date = FALSE),
    nPedA = nrow(pedA),
    nPedB = nrow(pedB),
    nMapped = nrow(mapping),
    nMerged = nrow(merged),
    idA = lineagePreview$idA,
    sireSource = lineagePreview$sireSource,
    damSource = lineagePreview$damSource,
    stringsAsFactors = FALSE
  )
}

#' Read an uploaded cross-center CSV
#'
#' Reused by all 3 \code{fileInput}s (D4: "reusing \code{read.csv()}, not a
#' new parser").
#' @param file a \code{fileInput} value (\code{list(name=, datapath=)}).
#' @return A data.frame, or \code{NULL} if \code{file} is \code{NULL}.
#' @noRd
.readCrossCenterUpload <- function(file) {
  if (is.null(file)) {
    return(NULL)
  }
  read.csv(file$datapath, stringsAsFactors = FALSE)
}

#' Cross-Center Identity Mapping Module - UI Function
#'
#' A Shiny workflow around the script-callable
#' \code{\link{checkCrossCenterMapping}} (Slice 1, "show every problem at
#' once") and \code{\link{resolveCrossCenterIds}}: upload two center
#' pedigrees and a curator-reviewed identity mapping, validate, preview the
#' lineage changes the proposed merge would make, confirm, and export the
#' mapping, validation results, merge summary, merged pedigree, and
#' provenance.
#' Retains the no-automatic-identity-inference policy -- identity is
#' established only by the uploaded mapping file, never guessed.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A \code{div} object containing the module's UI.
#' @seealso \code{\link{modCrossCenterIdentityServer}} for server logic.
#' @importFrom shiny NS div h3 h5 icon helpText wellPanel fileInput
#' @importFrom shiny sidebarLayout sidebarPanel mainPanel actionButton
#' @importFrom shiny tabsetPanel tabPanel uiOutput downloadButton br
#' @importFrom DT DTOutput
#' @family Shiny modules
#' @export
modCrossCenterIdentityUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "crossCenterIdentity",

    h3("Cross-Center Identity Mapping"),

    sidebarLayout(
      sidebarPanel(
        helpText(
          "Upload two centers' pedigrees plus a curator-reviewed id",
          "mapping to safely merge cross-center transfers. Identity is",
          "never inferred from matching id strings -- only the mapping",
          "file's explicit links are merged."
        ),
        wellPanel(
          h5(icon("file-csv"), "Center A Pedigree"),
          helpText("CSV with columns id, sire, dam (extra columns allowed)."),
          fileInput(ns("pedAFile"), label = NULL, accept = ".csv")
        ),
        wellPanel(
          h5(icon("file-csv"), "Center B Pedigree"),
          helpText("CSV with columns id, sire, dam (extra columns allowed)."),
          fileInput(ns("pedBFile"), label = NULL, accept = ".csv")
        ),
        wellPanel(
          h5(icon("file-csv"), "Identity Mapping"),
          helpText(
            "CSV with columns idA, idB: one row per curator-confirmed",
            "cross-center identity link."
          ),
          fileInput(ns("mappingFile"), label = NULL, accept = ".csv")
        ),
        actionButton(ns("validate"), "Validate Mapping",
                     icon = icon("check"), class = "btn-primary btn-block")
      ),

      mainPanel(
        tabsetPanel(
          id = ns("mainTabs"),

          tabPanel(
            "Validation",
            icon = icon("list-check"),
            br(),
            uiOutput(ns("validationSummaryUI")),
            DT::DTOutput(ns("validationTable"))
          ),

          tabPanel(
            "Preview",
            icon = icon("eye"),
            br(),
            uiOutput(ns("previewGateUI")),
            DT::DTOutput(ns("previewTable")),
            br(),
            actionButton(ns("confirmMerge"), "Confirm Merge",
                         icon = icon("check-double"), class = "btn-success")
          ),

          tabPanel(
            "Export",
            icon = icon("download"),
            br(),
            uiOutput(ns("exportGateUI")),
            downloadButton(ns("downloadMergedPedigree"),
                           "Download Merged Pedigree"),
            downloadButton(ns("downloadMapping"), "Download Mapping"),
            downloadButton(ns("downloadValidationResults"),
                           "Download Validation Results"),
            downloadButton(ns("downloadMergeSummary"),
                           "Download Merge Summary"),
            downloadButton(ns("downloadProvenance"), "Download Provenance")
          )
        )
      )
    )
  )
}

#' Cross-Center Identity Mapping Module - Server Function
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @return A list with reactive components:
#' \itemize{
#'   \item \code{mergedPedigree} - the \code{\link{resolveCrossCenterIds}}
#'     output, once the uploaded mapping validates clean
#'   \item \code{issues} - the \code{\link{checkCrossCenterMapping}} output
#'     (plus a synthetic \code{type = "structural"} row if a required column
#'     was missing from an upload); zero rows means clean
#'   \item \code{confirmed} - logical: has the D7 confirmation modal been
#'     accepted for the currently-validated mapping
#' }
#'
#' Standalone review/export tool (D3): the merged pedigree is a downloadable
#' artifact only -- it is not written into \code{shared$currentPedigree} or
#' any other module's reactive graph. A curator who wants the merged result
#' to drive downstream analysis re-uploads the exported "Merged Pedigree"
#' CSV through \code{modInputServer}'s existing pedigree-file path.
#'
#' @seealso \code{\link{modCrossCenterIdentityUI}} for the user interface.
#' @importFrom shiny moduleServer reactive reactiveVal observeEvent req
#' @importFrom shiny renderUI showModal removeModal modalDialog modalButton
#' @importFrom shiny tagList p downloadHandler showNotification
#' @importFrom DT renderDT
#' @family Shiny modules
#' @export
modCrossCenterIdentityServer <- function(id) {

  moduleServer(id, function(input, output, session) {

    storedPedA <- reactiveVal(NULL)
    storedPedB <- reactiveVal(NULL)
    storedMapping <- reactiveVal(NULL)
    storedIssues <- reactiveVal(NULL)
    storedFileNames <- reactiveVal(list(pedA = NULL, pedB = NULL,
                                         mapping = NULL))
    confirmed <- reactiveVal(FALSE)

    # D5: (re-)validating always resets the confirmation gate -- an already
    # -confirmed merge must not silently keep the Export tab unlocked once
    # the underlying upload changes.
    observeEvent(input$validate, {
      req(input$pedAFile, input$pedBFile, input$mappingFile)
      confirmed(FALSE)

      pedA <- .readCrossCenterUpload(input$pedAFile)
      pedB <- .readCrossCenterUpload(input$pedBFile)
      mapping <- .readCrossCenterUpload(input$mappingFile)
      storedFileNames(list(pedA = input$pedAFile$name,
                            pedB = input$pedBFile$name,
                            mapping = input$mappingFile$name))
      storedPedA(pedA)
      storedPedB(pedB)
      storedMapping(mapping)

      # checkCrossCenterMapping() stop()s on a structural problem (a
      # required column missing from any of the 3 uploads), matching every
      # other checkXxx() function -- caught here and folded into the SAME
      # issues data.frame shape (type = "structural") so the Validation tab
      # has one rendering path regardless of problem kind, instead of a
      # raw stop() reaching the Shiny runtime uncaught.
      issues <- tryCatch(
        checkCrossCenterMapping(pedA, pedB, mapping),
        error = function(e) {
          showNotification(
            paste("Structural error:", conditionMessage(e)),
            type = "error", duration = 10L
          )
          data.frame(
            type = "structural", ids = NA_character_,
            message = conditionMessage(e), stringsAsFactors = FALSE
          )
        }
      )
      storedIssues(issues)

      session$sendCustomMessage("setDataReady", list(
        selector = paste0("#", session$ns("moduleContainer")),
        ready = TRUE
      ))
    })

    issues <- reactive({
      req(storedIssues())
      storedIssues()
    })

    isClean <- reactive({
      !is.null(storedIssues()) && nrow(storedIssues()) == 0L
    })

    lineagePreview <- reactive({
      req(isClean())
      .buildCrossCenterLineagePreview(storedPedA(), storedPedB(),
                                       storedMapping())
    })

    mergedPedigreeComputed <- reactive({
      req(isClean())
      resolveCrossCenterIds(storedPedA(), storedPedB(), storedMapping())
    })

    provenance <- reactive({
      req(isClean())
      names <- storedFileNames()
      .buildCrossCenterMergeProvenance(
        pedAFileName = names$pedA, pedBFileName = names$pedB,
        mappingFileName = names$mapping,
        pedA = storedPedA(), pedB = storedPedB(), mapping = storedMapping(),
        merged = mergedPedigreeComputed(), lineagePreview = lineagePreview()
      )
    })

    output$validationSummaryUI <- renderUI({
      req(storedIssues())
      n <- nrow(storedIssues())
      if (n == 0L) {
        div(class = "alert alert-success", icon("check"),
            " Mapping is clean -- see the Preview tab.")
      } else {
        div(class = "alert alert-danger", icon("exclamation-triangle"),
            paste0(" Resolve ", n, " issue(s) below before previewing."))
      }
    })

    output$validationTable <- DT::renderDT({
      req(storedIssues())
      storedIssues()
    }, options = list(pageLength = 10L))

    output$previewGateUI <- renderUI({
      if (!isClean()) {
        div(class = "alert alert-info",
            "Resolve every issue on the Validation tab to see a preview.")
      }
    })

    output$previewTable <- DT::renderDT({
      req(isClean())
      lineagePreview()
    }, options = list(pageLength = 10L))

    observeEvent(input$confirmMerge, {
      req(isClean())
      showModal(modalDialog(
        title = "Confirm Cross-Center Merge",
        p(paste0(
          nrow(storedMapping()), " mapped pair(s); ",
          nrow(mergedPedigreeComputed()), " row(s) in the merged pedigree."
        )),
        footer = tagList(
          modalButton("Cancel"),
          actionButton(session$ns("confirmMergeOk"), "Confirm Merge",
                       class = "btn-success")
        )
      ))
    })

    observeEvent(input$confirmMergeOk, {
      req(isClean())
      confirmed(TRUE)
      removeModal()
    })

    output$exportGateUI <- renderUI({
      if (!confirmed()) {
        div(class = "alert alert-info",
            "Confirm the merge on the Preview tab to unlock exports.")
      }
    })

    output$downloadMergedPedigree <- downloadHandler(
      filename = function() paste0("merged_pedigree_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(mergedPedigreeComputed(), file, row.names = FALSE)
      }
    )

    output$downloadMapping <- downloadHandler(
      filename = function() {
        paste0("cross_center_mapping_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(storedMapping(), file, row.names = FALSE)
      }
    )

    output$downloadValidationResults <- downloadHandler(
      filename = function() {
        paste0("validation_results_", Sys.Date(), ".csv")
      },
      content = function(file) {
        write.csv(storedIssues(), file, row.names = FALSE)
      }
    )

    output$downloadMergeSummary <- downloadHandler(
      filename = function() paste0("merge_summary_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(lineagePreview(), file, row.names = FALSE)
      }
    )

    output$downloadProvenance <- downloadHandler(
      filename = function() paste0("provenance_", Sys.Date(), ".csv"),
      content = function(file) {
        write.csv(provenance(), file, row.names = FALSE)
      }
    )

    list(
      mergedPedigree = reactive({
        mergedPedigreeComputed()
      }),
      issues = reactive({
        issues()
      }),
      confirmed = reactive({
        confirmed()
      })
    )
  })
}
