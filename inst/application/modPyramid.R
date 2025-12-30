#' @export
modPyramidUI <- function(id) {
  ns <- NS(id)
  tagList(
    h3("Age-Sex Pyramid"),
    fluidRow(
      column(3,
             wellPanel(
               selectInput(ns("age_unit"), "Age Unit:",
                           choices = c("Years" = "years", "Months" = "months")),
               numericInput(ns("age_bin"), "Bin Size:", value = 2, min = 1),
               actionButton(ns("generate"), "Generate Plot", class = "btn-primary")
             )
      ),
      column(9,
             plotOutput(ns("plot"), height = "600px")
      )
    )
  )
}

#' @export
modPyramidServer <- function(id, pedigree_data) {
  moduleServer(id, function(input, output, session) {
    output$plot <- renderPlot({
      req(pedigree_data())
      input$generate

      # Your plotting code here
      plot(1:10, main = "Age-Sex Pyramid Plot")
    })
  })
}
