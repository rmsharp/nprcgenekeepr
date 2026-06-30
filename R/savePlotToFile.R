## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Save Plot to File
#'
#' Helper function to save ggplot2 plots to files with consistent settings
#' and error handling. Supports PNG, PDF, and SVG formats with configurable
#' dimensions and resolution.
#'
#' @param plot A ggplot2 plot object to save. If NULL, returns FALSE.
#' @param file character. The file path to save the plot to.
#' @param format character. Output format: "png", "pdf", or "svg".
#'   Defaults to "png". If not specified, format is inferred from file
#'   extension.
#' @param width numeric. Plot width in inches. Defaults to 8.
#' @param height numeric. Plot height in inches. Defaults to 6.
#' @param dpi numeric. Resolution in dots per inch for raster formats.
#'   Defaults to 150 for good quality web/screen use. Use 300 for print.
#' @param units character. Units for width and height. Defaults to "in"
#'   (inches).
#' @param bg character. Background color. Defaults to "white".
#'
#' @return Logical. TRUE if the file was saved successfully, FALSE otherwise.
#'
#' @seealso \code{\link[ggplot2]{ggsave}} for the underlying save function
#' @importFrom ggplot2 ggsave
#' @export
#' @examples
#' \dontrun{
#' library(ggplot2)
#' p <- ggplot(mtcars, aes(mpg, wt)) + geom_point()
#' savePlotToFile(p, "my_plot.png")
#' savePlotToFile(p, "my_plot.pdf", format = "pdf")
#' savePlotToFile(p, "high_res.png", dpi = 300)
#' }
#'
savePlotToFile <- function(plot, file, format = NULL,
                            width = 8L, height = 6L, dpi = 150L,
                            units = "in", bg = "white") {
  # Handle NULL plot
  if (is.null(plot)) {
    logModuleEvent("savePlotToFile", "Cannot save NULL plot", level = "WARN")
    return(FALSE)
  }

  # Validate plot is a ggplot object
  if (!inherits(plot, "ggplot")) {
    logModuleEvent("savePlotToFile", "Plot is not a ggplot object",
                   level = "WARN")
    return(FALSE)
  }

  # Determine format from file extension if not specified
  if (is.null(format)) {
    ext <- tolower(tools::file_ext(file))
    format <- if (ext %in% c("png", "pdf", "svg", "jpg", "jpeg", "tiff")) {
      ext
    } else {
      "png"
    }
  }

  # Attempt to save the plot
  result <- tryCatch({
    ggplot2::ggsave(
      filename = file,
      plot = plot,
      device = format,
      width = width,
      height = height,
      dpi = dpi,
      units = units,
      bg = bg
    )
    logModuleEvent("savePlotToFile",
                   sprintf("Saved plot to %s (%s format)", file, format),
                   level = "DEBUG")
    TRUE
  }, error = function(e) {
    logModuleEvent("savePlotToFile",
                   sprintf("Failed to save plot: %s", e$message),
                   level = "ERROR")
    FALSE
  })

  result
}
