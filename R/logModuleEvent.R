## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Log Module Events
#'
#' Centralized logging function for Shiny module events. Provides consistent
#' logging format across all modules with configurable log levels.
#'
#' @param module character. Name of the module generating the log message.
#' @param message character. The log message to record.
#' @param level character. Log level: "DEBUG", "INFO", "WARN", or "ERROR".
#'   Defaults to "INFO".
#' @param ... Additional arguments passed to the log message (for sprintf-style
#'   formatting).
#'
#' @return Invisible NULL. Called for side effect of logging.
#'
#' @seealso \code{\link{safeExecute}} for error-safe execution with logging
#' @export
#' @examples
#' \dontrun{
#' logModuleEvent("modInput", "File uploaded successfully")
#' logModuleEvent("modPedigree", "Processing %d animals", level = "DEBUG", 100)
#' logModuleEvent("modGeneticValue", "Calculation failed", level = "ERROR")
#' }
#'
logModuleEvent <- function(module, message, level = "INFO", ...) {
  # Validate log level
  valid_levels <- c("DEBUG", "INFO", "WARN", "ERROR")
  level <- toupper(level)
  if (!level %in% valid_levels) {
    level <- "INFO"
  }

  # Format message with additional arguments if provided
  if (length(list(...)) > 0L) {
    message <- sprintf(message, ...)
  }

  # Create formatted log entry
  timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
  log_entry <- sprintf("[%s] [%s] [%s] %s", timestamp, level, module, message)

  # Output based on level
  # In production, this could be extended to use futile.logger or other

  # logging frameworks
  switch(level,
    ERROR = ,
    WARN = message(log_entry),
    DEBUG = {
      # Debug messages only shown if debug mode is enabled
      if (getOption("nprcgenekeepr.debug", FALSE)) {
        cat(log_entry, "\n")
      }
    },
    # INFO level (default)
    if (getOption("nprcgenekeepr.verbose", FALSE)) {
      cat(log_entry, "\n")
    }
  )

  invisible(NULL)
}
