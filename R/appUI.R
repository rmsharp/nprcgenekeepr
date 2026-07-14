## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Main Application UI for nprcgenekeepr
#'
#' @param siteInfo Named list of site configuration as returned by
#'   \code{\link{getSiteInfo}}; defaults to \code{NULL}, in which case it is
#'   resolved internally via \code{getSiteInfo(expectConfigFile = FALSE)}. A
#'   present-but-malformed site-config file makes that call fail; the failure
#'   is caught and logged (\code{futile.logger::flog.warn}) rather than
#'   propagating, and the UI falls back to hiding the ORIP Reporting tab. Its
#'   \code{center} and \code{configFile} elements gate the Oregon
#'   (ONPRC)-specific ORIP Reporting tab, which is shown only for an actual
#'   ONPRC configuration (see \code{\link{shouldShowOripTab}}).
#' @return A \code{shiny.tag.list} object (as produced by
#'   \code{shiny::tagList()}) describing the complete GeneKeepR user interface;
#'   pass it as the \code{ui} argument to \code{shiny::shinyApp()} or
#'   \code{shiny::runApp()}.
#' @importFrom bslib bs_theme
#' @importFrom shiny navbarPage tabPanel icon fluidRow column div h1 p hr
#' @importFrom shiny actionButton navbarMenu tags includeScript
#' @export
appUI <- function(siteInfo = NULL) {

  # The getSiteInfo() call is wrapped in tryCatch (mirroring appServer.R's
  # ORIP-gate guard, issue #50 crash class) so a present-but-malformed config
  # file can never crash THIS call site -- the UI-side twin of the
  # appServer.R gate, found live-testing that fix (S378) and fixed here (the
  # BACKLOG.md "appUI.R" item).
  if (is.null(siteInfo)) {
    siteInfo <- tryCatch(
      getSiteInfo(expectConfigFile = FALSE),
      error = function(e) {
        futile.logger::flog.warn(
          "Failed to load site configuration for ORIP gating: %s",
          conditionMessage(e),
          name = "nprcgenekeepr"
        )
        NULL
      }
    )
  }

  # ORIP Reporting is Oregon (ONPRC)-specific; show its tab only for an actual
  # ONPRC site configuration (#49). Fails closed (tab hidden) if siteInfo
  # could not be resolved.
  showOrip <- !is.null(siteInfo) &&
    shouldShowOripTab(siteInfo$center, file.exists(siteInfo$configFile))

  # Include data-ready JavaScript for E2E testing
  dataReadyJS <- system.file("www", "js", "data-ready.js",
                              package = "nprcgenekeepr")

  tagList(
    # Include the data-ready JavaScript if it exists
    if (file.exists(dataReadyJS)) tags$head(includeScript(dataReadyJS)),

    navbarPage(
    title = "GeneKeepR",
    id = "mainNavbar",
    theme = bslib::bs_theme(version = 4L, bootswatch = "flatly"),

    # ====================
    # Home Tab
    # ====================
    tabPanel(
      "Home",
      icon = icon("home"),

      fluidRow(
        column(
          width = 12L,
          div(
            class = "jumbotron",
            h1("Welcome to GeneKeepR"),
            p(class = "lead",
              paste0("Genetic Management Tools - Version ", getVersion())),
            hr(),
            p(paste0("This application provides tools for managing genetic ",
                     "diversity in captive breeding programs. ",
                     "Select a tool from the tabs above."))
          )
        )
      ),

      fluidRow(
        column(
          width = 4L,
          div(
            class = "panel panel-primary",
            div(class = "panel-heading", h4("Data Input")),
            div(class = "panel-body",
                p("Upload and validate studbook data"),
                actionButton("goto_input", "Go to Input",
                             class = "btn-primary btn-block"))
          )
        ),
        column(
          width = 4L,
          div(
            class = "panel panel-info",
            div(class = "panel-heading", h4("Pedigree Browser")),
            div(class = "panel-body",
                p("Browse and filter pedigree data"),
                actionButton("goto_pedigree", "Go to Pedigree",
                             class = "btn-info btn-block"))
          )
        ),
        column(
          width = 4L,
          div(
            class = "panel panel-success",
            div(class = "panel-heading", h4("Age-Sex Pyramid")),
            div(class = "panel-body",
                p("Analyze age and sex distribution"),
                actionButton("goto_pyramid", "Go to Pyramid",
                             class = "btn-success btn-block"))
          )
        )
      ),

      fluidRow(
        column(
          width = 4L,
          div(
            class = "panel panel-warning",
            div(class = "panel-heading", h4("Genetic Value Analysis")),
            div(class = "panel-body",
                p("Calculate kinship and genome uniqueness"),
                actionButton("goto_genetic", "Go to Genetic Value",
                             class = "btn-warning btn-block"))
          )
        ),
        column(
          width = 4L,
          div(
            class = "panel panel-danger",
            div(class = "panel-heading", h4("Summary Statistics")),
            div(class = "panel-body",
                p("View genetic diversity metrics and plots"),
                actionButton("goto_summary", "Go to Summary",
                             class = "btn-danger btn-block"))
          )
        ),
        column(
          width = 4L,
          div(
            class = "panel panel-default",
            div(class = "panel-heading", h4("Breeding Groups")),
            div(class = "panel-body",
                p("Form breeding groups to minimize inbreeding"),
                actionButton("goto_breeding", "Go to Breeding Groups",
                             class = "btn-default btn-block"))
          )
        )
      )
    ),

    # ====================
    # Input and Quality Control Tab
    # ====================
    tabPanel(
      "Input",
      icon = icon("upload"),
      modInputUI("dataInput")
    ),

    # ====================
    # Pedigree Browser Tab
    # ====================
    tabPanel(
      "Pedigree Browser",
      icon = icon("sitemap"),
      modPedigreeUI("pedigree")
    ),

    # ====================
    # Age-Sex Pyramid Tab
    # ====================
    tabPanel(
      "Age-Sex Pyramid",
      icon = icon("chart-bar"),
      modPyramidUI("pyramid")
    ),

    # ====================
    # Genetic Value Tab
    # ====================
    tabPanel(
      "Genetic Value Analysis",
      icon = icon("dna"),
      modGeneticValueUI("geneticValue")
    ),

    # ====================
    # Summary Statistics Tab
    # ====================
    tabPanel(
      "Summary Statistics",
      icon = icon("chart-line"),
      modSummaryStatsUI("summaryStats")
    ),

    # ====================
    # ORIP Reporting Tab (ONPRC-only, #49)
    # ====================
    if (isTRUE(showOrip)) {
      tabPanel(
        "ORIP Reporting",
        icon = icon("file-invoice"),
        modORIPReportingUI("oripReporting")
      )
    },

    # ====================
    # Breeding Groups Tab
    # ====================
    tabPanel(
      "Breeding Groups",
      icon = icon("users"),
      modBreedingGroupsUI("breedingGroups")
    ),

    # ====================
    # Genetic Diversity Tab
    # ====================
    tabPanel(
      "Genetic Diversity",
      icon = icon("th"),
      modGeneticDiversityUI("geneticDiversity")
    ),

    # ====================
    # Potential Parents Tab
    # ====================
    tabPanel(
      "Potential Parents",
      icon = icon("search"),
      modPotentialParentsUI("potentialParents")
    ),

    # ====================
    # GV & BG Description Tab
    # ====================
    tabPanel(
      "Genetic Value Analysis and Breeding Group Description",
      icon = icon("book"),
      modGvAndBgDescUI("gvAndBgDesc")
    ),

    # ====================
    # Settings/About Tab
    # ====================
    navbarMenu(
      "More",
      icon = icon("ellipsis-h"),

      tabPanel(
        "Settings",
        icon = icon("cog"),
        h3("Application Settings"),
        p("Configuration options will go here")
      ),

      tabPanel(
        "About",
        icon = icon("info-circle"),
        h3("About GeneKeepR"),
        p(paste("Version", getVersion(date = FALSE))),
        p("Developed at Oregon National Primate Research Center"),
        p("Funded by NIH grants P51 RR13986 and P51 OD011092")
      ),

      tabPanel(
        "Help",
        icon = icon("question-circle"),
        h3("Documentation"),
        p("For help, see:",
          a("Online Documentation",
            href = "https://rmsharp.github.io/nprcgenekeepr/",
            target = "_blank"))
      )
    )
  ))
}
