library(shiny)

# Source the module files
source("R/mod_pyramid.R")
source("R/utils_pyramid.R")

# Create sample data
sample_data <- data.frame(
  id = 1:100,
  sex = sample(c("M", "F"), 100, replace = TRUE),
  birth_date = Sys.Date() - sample(0:3650, 100)
)

# Build your app
ui <- fluidPage(
  titlePanel("Pyramid Demo"),
  mod_pyramid_ui("pyramid1")
)

server <- function(input, output, session) {
  pedigree <- reactive({ sample_data })
  mod_pyramid_server("pyramid1", pedigree)
}

shinyApp(ui, server)
