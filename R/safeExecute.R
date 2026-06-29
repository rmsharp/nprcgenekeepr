#' Safe Execution Wrapper with Error Handling
#'
## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' Executes an expression with comprehensive error handling. On error,
#' logs the error and returns a default value instead of stopping execution.
#' This is particularly useful in Shiny reactive contexts where errors
#' should be handled gracefully.
#'
#' @return The result of evaluating \code{expr}, or \code{default} if an
#'   error occurs.
#'
#' @param expr An expression to evaluate.
#' @param module character. Name of the calling module for logging purposes.
#' @param default The value to return if an error occurs. Defaults to NULL.
#' @param silent logical. If TRUE, suppresses the error notification.
#'   Defaults to FALSE.
#' @param notify logical. If TRUE and in a Shiny context, shows a notification
#'   to the user. Defaults to FALSE.
#'
#' @examples
#' \dontrun{
#' # Returns 4
#' safeExecute({ 2 + 2 }, module = "test")
#'
#' # Returns NULL and logs error
#' safeExecute({ stop("Error!") }, module = "test")
#'
#' # Returns custom default on error
#' safeExecute({ stop("Error!") }, module = "test", default = data.frame())
#' }
#'
#' @seealso \code{\link{logModuleEvent}} for logging
#' @importFrom shiny showNotification getDefaultReactiveDomain
#' @export
safeExecute <- function(expr, module = "unknown", default = NULL,
                        silent = FALSE, notify = FALSE) {
  tryCatch(
    {
      expr
    },
    warning = function(w) {
      if (!silent) {
        logModuleEvent(module, paste("Warning:", conditionMessage(w)),
                       level = "WARN")
      }
      # Continue with expression result despite warning
      suppressWarnings(expr)
    },
    error = function(e) {
      if (!silent) {
        logModuleEvent(module, paste("Error:", conditionMessage(e)),
                       level = "ERROR")
      }

      # Show notification in Shiny context if requested
      if (notify) {
        session <- tryCatch(
          shiny::getDefaultReactiveDomain(),
          error = function(e) NULL
        )
        if (!is.null(session)) {
          shiny::showNotification(
            paste("Error in", module, ":", conditionMessage(e)),
            type = "error",
            duration = 10L
          )
        }
      }

      default
    }
  )
}
