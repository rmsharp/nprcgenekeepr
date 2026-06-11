# shinytest2 wrapper for nprcgenekeepr Shiny application
# This app is used for automated testing with shinytest2

library(shiny)
library(nprcgenekeepr)

# Create and run the app
shinyApp(
  ui = appUI(),
  server = appServer
)
