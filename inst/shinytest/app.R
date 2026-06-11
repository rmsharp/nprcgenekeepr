# shinytest2 wrapper for nprcgenekeepr Shiny application
# This app is used for automated testing with shinytest2

library(shiny) # nolint: undesirable_function_linter
library(nprcgenekeepr) # nolint: undesirable_function_linter

# Create and run the app
shinyApp(
  ui = appUI(),
  server = appServer
)
