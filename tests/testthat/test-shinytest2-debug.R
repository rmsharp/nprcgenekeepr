# Debug test for modInput reactivity issue
# This test is for development debugging only and should be skipped during check

test_that("Counter works before and after file upload", {
  skip_on_cran()
  skip_if_not_installed("shinytest2")
  # Skip this debug test during R CMD check - it tests development debug elements
  skip("Debug test for development only - testCounter element not in production UI")

  # Create the app using the modular UI/Server
  app <- AppDriver$new(
    shinyApp(ui = nprcgenekeepr::appUI(), server = nprcgenekeepr::appServer),
    name = "debug-test",
    load_timeout = 30000,
    timeout = 10000
  )

  on.exit(app$stop(), add = TRUE)

  # Navigate to Input tab
  app$click(selector = "a[data-value='Input']")
  Sys.sleep(1)

  # Click counter button 3 times
  cat("Clicking counter 3 times before upload...\n")
  app$click(selector = "#dataInput-testCounter")
  Sys.sleep(0.5)
  app$click(selector = "#dataInput-testCounter")
  Sys.sleep(0.5)
  app$click(selector = "#dataInput-testCounter")
  Sys.sleep(0.5)

  # Get counter value
  counter_before <- app$get_text(selector = "#dataInput-counterValue")
  cat("Counter before upload:", counter_before, "\n")

  # Select Text file type
  app$click(selector = "#dataInput-fileType input[value='fileTypeText']")
  Sys.sleep(0.5)

  # Select Tab separator
  app$click(selector = "#dataInput-separator input[value='\t']")
  Sys.sleep(0.5)

  # Upload file
  test_file <- system.file("extdata", "ExamplePedigree.txt", package = "nprcgenekeepr")
  cat("Uploading file:", test_file, "\n")
  app$upload_file(`dataInput-pedigreeFileOne` = test_file)
  Sys.sleep(1)

  # Click the Read and Check Pedigree button
  cat("Clicking Read and Check Pedigree button...\n")
  app$click(selector = "#dataInput-getData")
  Sys.sleep(2)

  # Click counter button 2 more times
  cat("Clicking counter 2 times after upload...\n")
  app$click(selector = "#dataInput-testCounter")
  Sys.sleep(0.5)
  app$click(selector = "#dataInput-testCounter")
  Sys.sleep(0.5)

  # Get counter value
  counter_after <- app$get_text(selector = "#dataInput-counterValue")
  cat("Counter after upload:", counter_after, "\n")

  # The counter should have incremented
  # Before: 3, After clicking 2 more: should be 5
  expect_true(grepl("5", counter_after),
              info = paste("Expected counter to be 5, got:", counter_after))
})
