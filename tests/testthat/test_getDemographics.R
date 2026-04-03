#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr

test_that("getDemographics throws an error with no LabKey session connection", {
  # Skip if network is not available (e.g., during R CMD check)
  skip_on_cran()

  # Try to connect - if network fails, skip the test
  result <- tryCatch(
    {
      expect_warning(getDemographics())
      TRUE
    },
    error = function(e) {
      if (grepl("Could not resolve host|network|connection", e$message,
                ignore.case = TRUE)) {
        skip("Network not available - cannot reach LabKey server")
      }
      stop(e)
    }
  )
})
