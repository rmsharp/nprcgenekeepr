#' Main Application UI for nprcgenekeepr
#' @importFrom bslib bs_theme
#' @importFrom shiny navbarPage tabPanel icon fluidRow column div h1 p hr
#'             actionButton navbarMenu tags includeScript
#' @export
appUI <- function() {

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
    # Breeding Groups Tab
    # ====================
    tabPanel(
      "Breeding Groups",
      icon = icon("users"),
      modBreedingGroupsUI("breedingGroups")
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
        p("Version 1.0.8"),
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
