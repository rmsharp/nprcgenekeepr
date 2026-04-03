#' Minimal Test Module UI
#' @param id Module ID
#' @export
modMinimalTestUI <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Minimal Test Module"),
    actionButton(ns("testBtn"), "Click Me"),
    textOutput(ns("testOutput"))
  )
}

#' Minimal Test Module Server
#' @param id Module ID
#' @export
modMinimalTestServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    counter <- reactiveVal(0)

    observeEvent(input$testBtn, {
      counter(counter() + 1)
    })

    output$testOutput <- renderText({
      paste("Clicked:", counter())
    })
  })
}
