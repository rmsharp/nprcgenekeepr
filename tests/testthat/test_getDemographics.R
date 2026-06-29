## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

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
      if (grepl("Could not resolve host|network|connection|No LabKey credential",
                e$message, ignore.case = TRUE)) {
        skip("No live LabKey credential/connection available")
      }
      stop(e)
    }
  )
})

test_that("getDemographics configures auth before querying and returns result", {
  skip_if_not_installed("mockery")

  fake_site <- list(
    baseUrl = "https://example.test", folderPath = "/X",
    schemaName = "study", queryName = "demographics",
    configFile = tempfile(), homeDir = tempfile(),
    sysname = Sys.info()[["sysname"]]
  )
  auth_mock <- mockery::mock(list(method = "apiKey", baseUrl = fake_site$baseUrl))
  fake_df <- data.frame(Id = "A", stringsAsFactors = FALSE)
  select_mock <- mockery::mock(fake_df)
  mockery::stub(getDemographics, "getSiteInfo", fake_site)
  mockery::stub(getDemographics, "setLabKeyDefaults", auth_mock)
  mockery::stub(getDemographics, "labkey.selectRows", select_mock)

  result <- getDemographics(colSelect = c("Id"))

  mockery::expect_called(auth_mock, 1)
  mockery::expect_called(select_mock, 1)
  expect_identical(result, fake_df)
})

test_that("getDemographics propagates the no-credential error without querying", {
  skip_if_not_installed("mockery")

  fake_site <- list(
    baseUrl = "https://example.test", folderPath = "/X",
    schemaName = "study", queryName = "demographics",
    configFile = tempfile(), homeDir = tempfile(),
    sysname = Sys.info()[["sysname"]]
  )
  select_mock <- mockery::mock(data.frame())
  mockery::stub(getDemographics, "getSiteInfo", fake_site)
  mockery::stub(
    getDemographics, "setLabKeyDefaults",
    function(...) stop("No LabKey credential found.")
  )
  mockery::stub(getDemographics, "labkey.selectRows", select_mock)

  expect_error(getDemographics(), "No LabKey credential found")
  mockery::expect_called(select_mock, 0)
})
