# Breeding Group Formation Shiny Module

#' Breeding Groups Module - UI Function
#'
#' Copyright(c) 2017-2025 R. Mark Sharp
#' This file is part of nprcgenekeepr
#'
#' @return A \code{div} containing breeding group formation UI.
#'
#' @param id character vector of length 1. Module namespace identifier.
#'
#' @seealso \code{\link{modBreedingGroupsServer}}
#' @seealso \code{\link{groupAddAssign}} for group formation algorithm.
#'
#' @references
#' Vinson, A. and Raboin, M.J. (2015)
#' @importFrom DT DTOutput renderDT
#' @importFrom shiny NS div h3 fluidRow column wellPanel radioButtons
#'             conditionalPanel numericInput actionButton tabsetPanel
#'             tabPanel uiOutput tableOutput icon includeHTML
#' @export
modBreedingGroupsUI <- function(id) {
  ns <- NS(id)

  div(
    id = ns("moduleContainer"),
    `data-ready` = "false",
    `data-module` = "breedingGroups",

    h3("Breeding Group Formation"),
    fluidRow(
      column(4,
             wellPanel(
               h4(icon("users"), "Configuration"),
               radioButtons(ns("animalSource"), "Source:",
                            choices = c("Top ranked" = "topRanked",
                                        "Upload list" = "custom",
                                        "All available" = "all")),
               conditionalPanel(
                 condition = sprintf("input['%s'] == 'topRanked'", ns("animalSource")),
                 ns = ns,
                 numericInput(ns("nTopAnimals"), "Number of top animals:",
                              value = 20, min = 5, max = 100)
               ),
               numericInput(ns("nGroups"), "Number of groups:",
                            value = 3, min = 1, max = 20),
               numericInput(ns("maxKinship"), "Max kinship threshold:",
                            value = 0.25, min = 0, max = 0.5, step = 0.01),
               radioButtons(ns("sexRatio"), "Sex ratio:",
                            choices = c("None" = "none",
                                        "Harem (1M:NF)" = "harem",
                                        "Custom" = "custom")),
               actionButton(ns("formGroups"), "Form Groups",
                            icon = icon("users"), class = "btn-primary btn-block")
             )
      ),
      column(8,
             tabsetPanel(
               tabPanel("Groups", br(), uiOutput(ns("groupsDisplay"))),
               tabPanel("Statistics", br(), tableOutput(ns("groupStats"))),
               tabPanel(
                 "Group Detail", br(),
                 selectInput(ns("viewGrp"), "Group to view:", choices = NULL),
                 h4("Group members"),
                 DT::DTOutput(ns("groupMemberTable")),
                 br(),
                 h4("Within-group kinship"),
                 DT::DTOutput(ns("groupKinTable")),
                 br(),
                 downloadButton(ns("downloadGroup"),
                                "Export Current Group"),
                 downloadButton(ns("downloadGroupKin"),
                                "Export Current Group Kinship Matrix")
               )
             )
      )
    ),
    fluidRow(
      column(
        width = 10,
        offset = 1,
        style = paste0(
          "border: 1px solid lightgray; background-color: #EDEDED; ",
          "border-radius: 15px; box-shadow: 0 0 5px 2px #888; ",
          "margin-top: 15px; padding: 10px;"
        ),
        includeHTML(
          system.file("extdata", "ui_guidance", "group_formation.html",
                      package = "nprcgenekeepr")
        )
      )
    )
  )
}

#' Breeding Groups Module - Server Function
#'
#' Server logic for breeding group formation using the groupAddAssign algorithm.
#' This module integrates with the kinship-based maximal independent set (MIS)
#' algorithm to form optimal breeding groups that minimize relatedness within
#' groups while maximizing group sizes.
#'
#' The module supports multiple configuration options:
#' \itemize{
#'   \item \strong{Animal source}: Select top-ranked animals or all available
#'   \item \strong{Kinship threshold}: Maximum allowed kinship within groups
#'   \item \strong{Harem mode}: Form groups with exactly one male each
#'   \item \strong{Sex ratio}: Target female-to-male ratio in groups
#' }
#'
#' @return List with reactive components:
#' \itemize{
#'   \item \code{groups} - List of character vectors with animal IDs per group
#'   \item \code{nGroups} - Number of groups formed
#'   \item \code{score} - Optimization score from groupAddAssign (minimum group size)
#'   \item \code{unassigned} - Character vector of candidate IDs not placed in groups
#'   \item \code{groupKinship} - List of kinship matrices per group (if withKin=TRUE)
#' }
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigree reactive returning pedigree data frame with columns:
#'   id, sire, dam, sex, and optionally birth, exit, gen.
#' @param geneticValues optional reactive returning genetic value results
#'   from \code{\link{modGeneticValueServer}}. If provided and contains a
#'   kinship matrix, it will be used instead of calculating one.
#'
#' @seealso \code{\link{modBreedingGroupsUI}} for the UI component
#' @seealso \code{\link{groupAddAssign}} for the underlying MIS algorithm
#' @seealso \code{\link{modGeneticValueServer}} for genetic value analysis
#' @seealso \code{\link{kinship}} for kinship matrix calculation
#'
#' @importFrom shiny moduleServer reactive eventReactive reactiveVal withProgress
#'   incProgress req showNotification
#' @export
modBreedingGroupsServer <- function(id, pedigree, geneticValues = NULL) {
  moduleServer(id, function(input, output, session) {

    # Store results from groupAddAssign
    groupResults <- reactiveVal(NULL)

    # Helper: Get kinship matrix from geneticValues or calculate from pedigree
    getKinshipMatrix <- function(ped, gvReactive) {
      # Try to get kinship from geneticValues module
      if (!is.null(gvReactive) && is.function(gvReactive)) {
        gvData <- tryCatch(gvReactive(), error = function(e) NULL)
        if (!is.null(gvData) && "kinship" %in% names(gvData)) {
          return(gvData$kinship)
        }
      }

      # Calculate kinship from pedigree
      if (!"gen" %in% names(ped)) {
        ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
      }
      kinship(ped$id, ped$sire, ped$dam, ped$gen)
    }

    # Helper: Parse sex ratio from UI input
    parseSexRatio <- function(sexRatioInput) {
      if (is.null(sexRatioInput) || sexRatioInput %in% c("none", "harem")) {
        return(0.0)
      }
      sexRatioNum <- suppressWarnings(as.numeric(sexRatioInput))
      if (is.na(sexRatioNum)) 0.0 else sexRatioNum
    }

    # Helper: Filter out NA/empty groups from groupAddAssign result
    filterValidGroups <- function(groupList) {
      validGroups <- lapply(groupList, function(g) {
        if (length(g) == 0 || all(is.na(g))) return(NULL)
        g[!is.na(g)]
      })
      validGroups[!sapply(validGroups, is.null)]
    }

    breedingGroups <- eventReactive(input$formGroups, {
      req(pedigree())

      withProgress(message = "Forming breeding groups...", {
        ped <- pedigree()

        # Get candidate IDs based on source selection
        candidateIds <- if (input$animalSource == "topRanked") {
          req(geneticValues())
          gv <- geneticValues()
          gv$id[seq_len(min(input$nTopAnimals, length(gv$id)))]
        } else {
          ped$id
        }

        incProgress(0.2, detail = "Calculating kinship")
        kmat <- getKinshipMatrix(ped, geneticValues)

        incProgress(0.3, detail = "Running group formation algorithm")

        # Parse groupAddAssign parameters
        threshold <- input$maxKinship
        numGp <- input$nGroups
        harem <- (input$sexRatio == "harem")
        sexRatio <- parseSexRatio(input$sexRatio)
        minAge <- if (!is.null(input$minAge)) input$minAge else 1.0
        iter <- if (!is.null(input$nIterations)) input$nIterations else 1000L
        withKin <- if (!is.null(input$withKinship)) input$withKinship else FALSE

        # Progress callback for groupAddAssign
        updateProgress <- function(n = 1L, detail = NULL, value = 0L,
                                   reset = FALSE) {
          incProgress(amount = 0.001, detail = detail)
        }

        # Run the MIS-based group formation algorithm
        result <- tryCatch({
          groupAddAssign(
            candidates = candidateIds,
            kmat = kmat,
            ped = ped,
            currentGroups = list(character(0L)),
            threshold = threshold,
            ignore = list(c("F", "F")),
            minAge = minAge,
            iter = iter,
            numGp = numGp,
            harem = harem,
            sexRatio = sexRatio,
            withKin = withKin,
            updateProgress = updateProgress
          )
        }, error = function(e) {
          showNotification(
            paste("Could not form breeding groups. Error:",
                  e$message,
                  "Please check your input data and try again."),
            type = "error",
            duration = 10
          )
          list(group = list(character(0)), score = 0)
        })

        # Process results
        validGroups <- filterValidGroups(result$group)
        assignedIds <- unlist(validGroups)
        unassignedIds <- setdiff(candidateIds, assignedIds)

        # The unused-animals group is the last element appended by
        # addGroupOfUnusedAnimals(); it survives filterValidGroups() only when
        # it is non-empty, in which case it is the last element of validGroups.
        lastRaw <- result$group[[length(result$group)]]
        hasUnused <- !(length(lastRaw) == 0L || all(is.na(lastRaw)))

        # Store full results for other reactives. kmat is retained so the
        # Group Detail tab can derive each group's kinship submatrix via
        # filterKinMatrix() without re-deriving the matrix (display-only;
        # the group-formation result above is unchanged).
        groupResults(list(
          group = validGroups,
          score = result$score,
          groupKin = result$groupKin,
          unassigned = unassignedIds,
          kmat = kmat,
          hasUnused = hasUnused
        ))

        incProgress(0.5, detail = "Complete")

        # Signal that breeding group formation is complete (for E2E testing)
        session$sendCustomMessage("setDataReady", list(
          selector = paste0("#", session$ns("moduleContainer")),
          ready = TRUE
        ))

        validGroups
      })
    })

    output$groupsDisplay <- renderUI({
      req(breedingGroups())
      ped <- pedigree()

      groupsList <- lapply(seq_along(breedingGroups()), function(i) {
        groupIds <- breedingGroups()[[i]]
        nAnimals <- length(groupIds)
        div(class = "panel panel-primary",
            div(class = "panel-heading",
                h4(sprintf("Group %d (%d animals)", i, nAnimals))),
            div(class = "panel-body",
                DT::DTOutput(session$ns(paste0("groupTable", i))))
        )
      })
      do.call(tagList, groupsList)
    })

    observe({
      req(breedingGroups())
      ped <- pedigree()

      lapply(seq_along(breedingGroups()), function(i) {
        output[[paste0("groupTable", i)]] <- DT::renderDT({
          groupIds <- breedingGroups()[[i]]
          # Create display data frame from IDs
          groupData <- ped[ped$id %in% groupIds,
                           c("id", "sex", "birth", "sire", "dam")]
          groupData
        }, options = list(pageLength = 10, dom = 't'))
      })
    })

    output$groupStats <- renderTable({
      req(breedingGroups())
      ped <- pedigree()

      stats <- lapply(seq_along(breedingGroups()), function(i) {
        groupIds <- breedingGroups()[[i]]
        sexes <- ped$sex[ped$id %in% groupIds]
        data.frame(
          Group = i,
          Total = length(groupIds),
          Males = sum(sexes == "M", na.rm = TRUE),
          Females = sum(sexes == "F", na.rm = TRUE),
          stringsAsFactors = FALSE
        )
      })
      do.call(rbind, stats)
    })

    # ---- Group Detail tab: viewGrp selector + per-group member/kinship views

    # Selected group index, clamped to the number of groups actually formed.
    # length() rather than req(breedingGroups()) because an empty result is a
    # zero-length list, which req() treats as truthy.
    selectedGroup <- reactive({
      req(length(breedingGroups()) >= 1L)
      withinIntegerRange(input$viewGrp, minimum = 1L,
                         maximum = length(breedingGroups()))[1L]
    })

    # Populate the group selector when groups are (re)formed. When a non-empty
    # group of unused animals is present it is the last element, labelled
    # "Unused"; otherwise every element is labelled "Group i".
    observe({
      n <- length(breedingGroups())
      req(n >= 1L)
      res <- groupResults()
      labels <- paste("Group", seq_len(n))
      if (isTRUE(res$hasUnused)) {
        labels[n] <- "Unused"
      }
      updateSelectInput(session, "viewGrp",
                        choices = stats::setNames(seq_len(n), labels),
                        selected = 1L)
    })

    # Annotated members (Ego ID / Sex / Age in Years) of the selected group.
    bgGroupView <- reactive({
      req(breedingGroups())
      ids <- breedingGroups()[[selectedGroup()]]
      gp <- addSexAndAgeToGroup(ids, pedigree())
      gp$age <- round(gp$age, 1L)
      colnames(gp) <- c("Ego ID", "Sex", "Age in Years")
      gp[order(gp$`Ego ID`), , drop = FALSE]
    })

    # Within-group kinship submatrix of the selected group, derived from the
    # retained full kinship matrix (identical to groupAddAssign's groupKin
    # because the group's members are a subset of the candidate set).
    bgGroupKinView <- reactive({
      req(breedingGroups())
      res <- groupResults()
      req(!is.null(res$kmat))
      ids <- breedingGroups()[[selectedGroup()]]
      as.data.frame(as.matrix(round(filterKinMatrix(ids, res$kmat), 6L)))
    })

    output$groupMemberTable <- DT::renderDT(
      bgGroupView(),
      options = list(pageLength = 25L, dom = "t")
    )
    output$groupKinTable <- DT::renderDT(
      bgGroupKinView(),
      options = list(pageLength = 25L, dom = "t")
    )

    output$downloadGroup <- downloadHandler(
      filename = function() {
        getDatedFilename(paste0("Group-", input$viewGrp, ".csv"))
      },
      content = function(file) {
        write.csv(bgGroupView(), file, na = "", row.names = FALSE)
      }
    )
    output$downloadGroupKin <- downloadHandler(
      filename = function() {
        getDatedFilename(paste0("GroupKin-", input$viewGrp, ".csv"))
      },
      content = function(file) {
        write.csv(bgGroupKinView(), file, na = "", row.names = TRUE)
      }
    )

    return(list(
      groups = reactive({ breedingGroups() }),
      nGroups = reactive({ length(breedingGroups()) }),
      score = reactive({
        res <- groupResults()
        if (is.null(res)) return(0)
        res$score
      }),
      unassigned = reactive({
        res <- groupResults()
        if (is.null(res)) return(character(0))
        res$unassigned
      }),
      groupKinship = reactive({
        res <- groupResults()
        if (is.null(res)) return(NULL)
        res$groupKin
      })
    ))
  })
}
