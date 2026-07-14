# Coverage backfill for modPedigree.R (issue #111, slice 10). Drives the two
# branches the happy-path suite in test_modPedigree.R never reaches: the
# focal-file read error handler and the export download handler.

covModPed <- function() {
  data.frame(
    id = c("A", "B", "C", "D", "E"),
    sire = c(NA, NA, "A", "A", "B"),
    dam = c(NA, NA, "B", NA, NA),
    sex = c("M", "F", "F", "M", "F"),
    stringsAsFactors = FALSE
  )
}

test_that("a failed focal-file read is caught, leaving typed IDs intact", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ covModPed() })),
    {
      # A datapath that does not exist makes read.csv() throw; the tryCatch
      # error branch must catch it, so the typed IDs still survive.
      session$setInputs(
        displayUnknownIds = TRUE, trimPedigree = FALSE,
        clearFocalAnimals = FALSE, focalAnimalIds = "A, B",
        focalAnimalFile = list(
          datapath = file.path(tempdir(), "modped_cov_missing.csv"),
          name = "missing.csv"
        )
      )
      # read.csv() also warns ("cannot open file") before throwing; the
      # handler catches the error, so suppress the incidental warning here.
      suppressWarnings(session$setInputs(updateFocalAnimals = 1))

      focal <- session$getReturned()$focalAnimals()
      # The unreadable file added nothing; the typed IDs are kept (no crash).
      expect_equal(length(focal), 2L)
      expect_true(all(c("A", "B") %in% focal))
    }
  )
})

test_that("the export download handler writes the pedigree to CSV", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modPedigreeServer,
    args = list(studbook = shiny::reactive({ covModPed() })),
    {
      session$setInputs(displayUnknownIds = TRUE, trimPedigree = FALSE)

      # Reading output$exportPedigree runs BOTH the filename and content
      # download-handler functions.
      path <- output$exportPedigree
      df <- utils::read.csv(path, stringsAsFactors = FALSE)

      expect_equal(nrow(df), 5L)
      expect_true("id" %in% names(df))
      expect_true(all(c("A", "B", "C", "D", "E") %in% df$id))
    }
  )
})
