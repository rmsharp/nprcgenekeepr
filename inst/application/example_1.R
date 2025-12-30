# ===================================
# EXAMPLE 1: Standalone App
# ===================================

ui <- fluidPage(
  titlePanel("Age-Sex Pyramid Demo"),
  modPyramidUI("pyramid1")
)

server <- function(input, output, session) {

  # Create sample pedigree data
  pedigree <- reactive({
    create_sample_pedigree(500)
  })

  # Call the module
  pyramidResults <- modPyramidServer("pyramid1", pedigree)

  # You can use the returned values in other parts of your app
  observe({
    req(pyramidResults$living_count())
    message("Number of living animals: ", pyramidResults$living_count())
  })
}

# Run the app
shinyApp(ui, server)

