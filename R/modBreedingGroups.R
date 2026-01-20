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
               tabPanel("Statistics", br(), tableOutput(ns("groupStats")))
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
#' @return List with \code{groups}, \code{nGroups}, and \code{unassigned}.
#'
#' @param id character vector of length 1. Module namespace identifier.
#' @param pedigree reactive returning pedigree data frame.
#' @param geneticValues optional reactive returning genetic value results.
#'
#' @seealso \code{\link{modBreedingGroupsUI}}
#' @seealso \code{\link{modGeneticValueServer}}
#'
#' @importFrom shiny moduleServer reactive eventReactive
#' @export
modBreedingGroupsServer <- function(id, pedigree, geneticValues = NULL) {
  moduleServer(id, function(input, output, session) {

    breedingGroups <- eventReactive(input$formGroups, {
      req(pedigree())

      withProgress(message = "Forming breeding groups...", {

        if (input$animalSource == "topRanked") {
          req(geneticValues())
          candidateIds <- geneticValues()$id[1:input$nTopAnimals]
        } else {
          candidateIds <- pedigree()$id
        }

        incProgress(0.4, detail = "Calculating kinship")
        # kmat <- kinship(...)

        incProgress(0.4, detail = "Forming groups")
        # groups <- groupAddAssign(candidateIds, kmat, ...)

        # Placeholder
        groups <- lapply(1:input$nGroups, function(i) {
          nAnimals <- sample(3:7, 1)
          data.frame(
            group = i,
            id = sample(candidateIds, min(nAnimals, length(candidateIds))),
            sex = sample(c("M", "F"), nAnimals, replace = TRUE),
            stringsAsFactors = FALSE
          )
        })

        incProgress(0.2, detail = "Complete")
        groups
      })
    })

    output$groupsDisplay <- renderUI({
      req(breedingGroups())

      groupsList <- lapply(seq_along(breedingGroups()), function(i) {
        group <- breedingGroups()[[i]]
        div(class = "panel panel-primary",
            div(class = "panel-heading",
                h4(sprintf("Group %d (%d animals)", i, nrow(group)))),
            div(class = "panel-body",
                DT::DTOutput(session$ns(paste0("groupTable", i))))
        )
      })
      do.call(tagList, groupsList)
    })

    observe({
      req(breedingGroups())
      lapply(seq_along(breedingGroups()), function(i) {
        output[[paste0("groupTable", i)]] <- DT::renderDT({
          breedingGroups()[[i]]
        }, options = list(pageLength = 10, dom = 't'))
      })
    })

    output$groupStats <- renderTable({
      req(breedingGroups())
      stats <- lapply(seq_along(breedingGroups()), function(i) {
        group <- breedingGroups()[[i]]
        data.frame(
          Group = i,
          Total = nrow(group),
          Males = sum(group$sex == "M"),
          Females = sum(group$sex == "F"),
          stringsAsFactors = FALSE
        )
      })
      do.call(rbind, stats)
    })

    return(list(
      groups = reactive({ breedingGroups() }),
      nGroups = reactive({ length(breedingGroups()) }),
      unassigned = reactive({ NULL })
    ))
  })
}
