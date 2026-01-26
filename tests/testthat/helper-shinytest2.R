# Helper functions for shinytest2 E2E tests
# These utilities provide reliable waiting mechanisms using data-ready attributes

#' Wait for a module container to signal data-ready state
#'
#' Polls the data-ready attribute of a module container until it becomes "true"
#' or the timeout is reached.
#'
#' @param app ShinyDriver2 app object
#' @param selector CSS selector for the module container (e.g., "#input-moduleContainer")
#' @param timeout Maximum wait time in milliseconds (default 30000)
#' @param poll_interval Polling interval in milliseconds (default 500)
#' @return TRUE if ready, FALSE if timeout
wait_for_data_ready <- function(app, selector, timeout = 30000, poll_interval = 500) {
  start_time <- Sys.time()
  elapsed <- 0

  while (elapsed < timeout) {
    # Check data-ready attribute via JavaScript
    is_ready <- tryCatch({
      result <- app$get_js(sprintf(
        "var el = document.querySelector('%s'); el ? el.getAttribute('data-ready') : null",
        selector
      ))
      identical(result, "true")
    }, error = function(e) FALSE)

    if (is_ready) {
      return(TRUE)
    }

    Sys.sleep(poll_interval / 1000)
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000
  }

  FALSE
}

#' Wait for Shiny to become idle
#'
#' Waits for Shiny's busy indicator to clear, indicating no pending operations.
#'
#' @param app ShinyDriver2 app object
#' @param timeout Maximum wait time in milliseconds (default 10000)
#' @return TRUE if idle, FALSE if timeout
wait_for_idle <- function(app, timeout = 10000) {
  start_time <- Sys.time()
  elapsed <- 0

  while (elapsed < timeout) {
    is_idle <- tryCatch({
      result <- app$get_js(
        "!document.querySelector('html').classList.contains('shiny-busy')"
      )
      isTRUE(result)
    }, error = function(e) FALSE)

    if (is_idle) {
      return(TRUE)
    }

    Sys.sleep(0.2)
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000
  }

  FALSE
}

#' Wait for an element to exist in the DOM
#'
#' @param app ShinyDriver2 app object
#' @param selector CSS selector for the element
#' @param timeout Maximum wait time in milliseconds (default 10000)
#' @return TRUE if element exists, FALSE if timeout
wait_for_element <- function(app, selector, timeout = 10000) {
  start_time <- Sys.time()
  elapsed <- 0

  while (elapsed < timeout) {
    exists <- tryCatch({
      result <- app$get_js(sprintf(
        "document.querySelector('%s') !== null",
        selector
      ))
      isTRUE(result)
    }, error = function(e) FALSE)

    if (exists) {
      return(TRUE)
    }

    Sys.sleep(0.2)
    elapsed <- as.numeric(difftime(Sys.time(), start_time, units = "secs")) * 1000
  }

  FALSE
}

#' Get the data-ready attribute value for a module
#'
#' @param app ShinyDriver2 app object
#' @param selector CSS selector for the module container
#' @return The data-ready attribute value or NULL
get_data_ready_state <- function(app, selector) {
  tryCatch({
    app$get_js(sprintf(
      "var el = document.querySelector('%s'); el ? el.getAttribute('data-ready') : null",
      selector
    ))
  }, error = function(e) NULL)
}

#' Check if a module is ready
#'
#' @param app ShinyDriver2 app object
#' @param module_id The module namespace ID (e.g., "input", "pedigree")
#' @return TRUE if the module's data-ready attribute is "true"
is_module_ready <- function(app, module_id) {
  selector <- sprintf("#%s-moduleContainer", module_id)
  state <- get_data_ready_state(app, selector)
  identical(state, "true")
}

#' Wait for a specific module to be ready
#'
#' Convenience wrapper that constructs the selector from module ID.
#'
#' @param app ShinyDriver2 app object
#' @param module_id The module namespace ID (e.g., "input", "pedigree")
#' @param timeout Maximum wait time in milliseconds (default 30000)
#' @return TRUE if ready, FALSE if timeout
wait_for_module_ready <- function(app, module_id, timeout = 30000) {
  selector <- sprintf("#%s-moduleContainer", module_id)
  wait_for_data_ready(app, selector, timeout = timeout)
}

#' Upload a file and wait for QC processing to complete
#'
#' Helper function that handles file upload and waits for the input module
#' to signal data-ready.
#'
#' @param app ShinyDriver2 app object
#' @param file_path Path to the file to upload
#' @param file_input_id The file input ID (without namespace prefix)
#' @param button_id The action button ID to trigger processing (without namespace prefix)
#' @param module_id The module namespace ID (default "input")
#' @param timeout Maximum wait time in milliseconds (default 30000)
#' @return TRUE if upload and processing succeeded, FALSE otherwise
upload_and_wait <- function(app, file_path, file_input_id = "pedigreeFileOne",
                             button_id = "getData", module_id = "input",
                             timeout = 30000) {
  tryCatch({
    # Upload the file
    app$upload_file(`input-pedigreeFileOne` = file_path)

    # Click the process button
    app$click(sprintf("%s-%s", module_id, button_id))

    # Wait for processing to complete
    wait_for_module_ready(app, module_id, timeout = timeout)
  }, error = function(e) {
    FALSE
  })
}

#' Get standard test data file path
#'
#' Returns the path to a test data file in inst/extdata.
#'
#' @param filename The name of the test file
#' @return Full path to the test file
get_test_data_path <- function(filename) {
  system.file("extdata", filename, package = "nprcgenekeepr")
}
