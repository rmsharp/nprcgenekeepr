# Tests for the modORIPReportingServer server body (R/modORIPReporting.R).
#
# The UI/appServer wiring (tab gating under #47/#49) is covered by
# test_modORIPReporting.R, and test_modSiteConfig.R checks that the module
# functions exist with the right formals. Neither drives the server through
# shiny::testServer, so the entire server body -- the three output renderers
# (siteInfo, colonySummary, geneticDiversity), both downloadHandlers, and the
# returned colonySummary reactive -- ran only under the opt-in browser e2e
# (test-e2e-orip-module.R), which skips without shinytest2 + chromote. These
# tests exercise that server body headlessly, mirroring the testServer idiom in
# test_modSummaryStats.R (renderUI/renderTable read via as.character(output$x);
# downloadHandler content read via a path = output$downloadX; read.csv(path)).

# ---- Shared fixtures -------------------------------------------------------
# A pedigree with three founders (F1-F3) and two offspring (O1, O2): 5 animals,
# 2 males, 3 females, 3 founders (1 male, 2 female).
oripTestPed <- data.frame(
  id = c("F1", "F2", "F3", "O1", "O2"),
  sire = c(NA, NA, NA, "F1", "F1"),
  dam = c(NA, NA, NA, "F2", "F3"),
  sex = c("M", "F", "F", "M", "F"),
  stringsAsFactors = FALSE
)

# Genetic values: indivMeanKin averages to 0.30, gu to 0.70.
oripTestGv <- data.frame(
  id = c("F1", "F2", "F3", "O1", "O2"),
  indivMeanKin = c(0.10, 0.20, 0.30, 0.40, 0.50),
  gu = c(0.90, 0.80, 0.70, 0.60, 0.50),
  stringsAsFactors = FALSE
)

# A site-configuration list shaped like getSiteInfo()'s return.
oripTestConfig <- list(
  center = "ONPRC", nodename = "testnode", user = "tester",
  sysname = "TestOS", release = "1.0"
)

# ---- siteInfo renderUI -----------------------------------------------------
test_that("siteInfo renders a table from a supplied siteConfig", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modORIPReportingServer,
    args = list(siteConfig = shiny::reactive(oripTestConfig)),
    {
      html <- as.character(output$siteInfo)
      expect_true(any(grepl("Center", html)))
      expect_true(any(grepl("ONPRC", html)))
      expect_true(any(grepl("testnode", html)))
      expect_true(any(grepl("tester", html)))
      expect_true(any(grepl("TestOS", html)))
      expect_true(any(grepl("1.0", html, fixed = TRUE)))
    }
  )
})

test_that("siteInfo falls back to getSiteInfo when siteConfig is NULL", {
  skip_if_not_installed("shiny")

  # siteConfig defaults to NULL, so the renderer calls
  # getSiteInfo(expectConfigFile = FALSE), which always returns a non-NULL
  # list -> the table renders regardless of the host config file.
  shiny::testServer(
    modORIPReportingServer,
    args = list(),
    {
      html <- as.character(output$siteInfo)
      expect_true(any(grepl("Center", html)))
      expect_true(any(grepl("Node", html)))
    }
  )
})

test_that("siteInfo shows a fallback message when siteConfig errors", {
  skip_if_not_installed("shiny")

  # A reactive that errors -> tryCatch returns NULL -> the "not available"
  # branch renders.
  shiny::testServer(
    modORIPReportingServer,
    args = list(siteConfig = shiny::reactive(stop("no config"))),
    {
      html <- as.character(output$siteInfo)
      expect_true(any(grepl("Site configuration not available", html)))
    }
  )
})

# ---- colonySummary renderTable ---------------------------------------------
test_that("colonySummary reports counts for a populated pedigree", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modORIPReportingServer,
    args = list(pedigree = shiny::reactive(oripTestPed)),
    {
      html <- as.character(output$colonySummary)
      expect_true(any(grepl("Total Animals", html)))
      expect_true(any(grepl("Total Founders", html)))
      expect_true(any(grepl("Male Founders", html)))
      expect_true(any(grepl("Female Founders", html)))
      # 5 animals total, 3 founders.
      expect_true(any(grepl("5", html)))
      expect_true(any(grepl("3", html)))
    }
  )
})

test_that("colonySummary shows a No-data row for an empty pedigree", {
  skip_if_not_installed("shiny")

  emptyPed <- data.frame(
    id = character(), sire = character(),
    dam = character(), sex = character(),
    stringsAsFactors = FALSE
  )
  shiny::testServer(
    modORIPReportingServer,
    args = list(pedigree = shiny::reactive(emptyPed)),
    {
      html <- as.character(output$colonySummary)
      expect_true(any(grepl("No data", html)))
      expect_true(any(grepl("Load pedigree data", html)))
    }
  )
})

# ---- geneticDiversity renderUI ---------------------------------------------
test_that("geneticDiversity reports metrics for populated genetic values", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modORIPReportingServer,
    args = list(geneticValues = shiny::reactive(oripTestGv)),
    {
      html <- as.character(output$geneticDiversity)
      expect_true(any(grepl("Mean Kinship", html)))
      expect_true(any(grepl("Mean Genome Uniqueness", html)))
      expect_true(any(grepl("0.3000", html)))
      expect_true(any(grepl("0.7000", html)))
      expect_true(any(grepl("Animals Analyzed", html)))
    }
  )
})

test_that("geneticDiversity prompts to run analysis when values are empty", {
  skip_if_not_installed("shiny")

  emptyGv <- data.frame(
    id = character(), indivMeanKin = numeric(),
    gu = numeric(), stringsAsFactors = FALSE
  )
  shiny::testServer(
    modORIPReportingServer,
    args = list(geneticValues = shiny::reactive(emptyGv)),
    {
      html <- as.character(output$geneticDiversity)
      expect_true(any(grepl("Run genetic value analysis", html)))
    }
  )
})

# ---- downloadORIPReport downloadHandler ------------------------------------
test_that("downloadORIPReport writes site, colony, and diversity rows", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modORIPReportingServer,
    args = list(
      pedigree = shiny::reactive(oripTestPed),
      geneticValues = shiny::reactive(oripTestGv),
      siteConfig = shiny::reactive(oripTestConfig)
    ),
    {
      path <- output$downloadORIPReport
      report <- utils::read.csv(path, stringsAsFactors = FALSE)

      expect_true(all(
        c("Category", "Metric", "Value") %in% names(report)
      ))
      expect_true("Site" %in% report$Category)
      expect_true("Colony" %in% report$Category)
      expect_true("Genetic Diversity" %in% report$Category)
      # Site rows carry the supplied center.
      expect_true("ONPRC" %in% report$Value)
      # Colony rows carry the total animal count.
      expect_true("5" %in% report$Value)
      # Genetic diversity rows carry the formatted mean kinship.
      expect_true("0.3000" %in% report$Value)
    }
  )
})

test_that("downloadORIPReport omits colony/diversity when data are absent", {
  skip_if_not_installed("shiny")

  # NULL pedigree + NULL genetic values -> only the Site section is written,
  # and (siteConfig NULL) config comes from the getSiteInfo() else-branch.
  shiny::testServer(
    modORIPReportingServer,
    args = list(
      pedigree = shiny::reactive(NULL),
      geneticValues = shiny::reactive(NULL)
    ),
    {
      path <- output$downloadORIPReport
      report <- utils::read.csv(path, stringsAsFactors = FALSE)

      expect_true("Site" %in% report$Category)
      expect_false("Colony" %in% report$Category)
      expect_false("Genetic Diversity" %in% report$Category)
    }
  )
})

# ---- downloadDemographics downloadHandler ----------------------------------
test_that("downloadDemographics writes the pedigree", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modORIPReportingServer,
    args = list(pedigree = shiny::reactive(oripTestPed)),
    {
      path <- output$downloadDemographics
      demog <- utils::read.csv(path, stringsAsFactors = FALSE)

      expect_equal(nrow(demog), 5L)
      expect_setequal(as.character(demog$id), oripTestPed$id)
    }
  )
})

test_that("downloadDemographics writes a placeholder when no pedigree", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modORIPReportingServer,
    args = list(pedigree = shiny::reactive(NULL)),
    {
      path <- output$downloadDemographics
      demog <- utils::read.csv(path, stringsAsFactors = FALSE)

      expect_true("Note" %in% names(demog))
      expect_true(any(grepl("No pedigree data available", demog$Note)))
    }
  )
})

# ---- returned colonySummary reactive ---------------------------------------
test_that("server returns a colonySummary reactive with colony counts", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modORIPReportingServer,
    args = list(pedigree = shiny::reactive(oripTestPed)),
    {
      result <- session$getReturned()
      expect_true(is.list(result))
      expect_true("colonySummary" %in% names(result))

      cs <- result$colonySummary()
      expect_equal(cs$nTotal, 5L)
      expect_equal(cs$nMales, 2L)
      expect_equal(cs$nFemales, 3L)
      expect_equal(cs$nFounders, 3L)
    }
  )
})
