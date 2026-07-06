# Coverage backfill for modPotentialParents.R (#111 slice 7).
#
# test_modPotentialParents.R exhaustively covers the four pure helpers and
# drives tableData()/gestationDefault(), but never reaches these server
# branches:
#   * the eventReactive NULL-pedigree return (L257) and NULL/NA gestation
#     fallback to 210 (L261),
#   * the statusMessage "No pedigree is loaded" warning branch (L283-287),
#   * the downloadParents filename + content handlers (L321, L324).
# The module code is correct; these three testServer tests characterize those
# branches (they pass on authoring -- this is backfill, not a bug fix).

# A rhesus pedigree marked entirely from-center, so getPotentialParents finds
# candidate parents for in-colony animals with an unknown parent (e.g. BRI2MW).
ppFromCenterPed <- function() {
  ped <- nprcgenekeepr::rhesusPedigree
  ped$fromCenter <- TRUE
  ped
}

test_that("modPotentialParents: Find with no pedigree warns, empty table", {
  skip_if_not_installed("shiny")

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(NULL), minParentAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)

      # eventReactive returns NULL for a NULL pedigree (L257) -> empty table.
      td <- session$getReturned()$tableData()
      expect_true(is.data.frame(td))
      expect_equal(nrow(td), 0L)

      # statusMessage renders the no-pedigree warning branch (L283-287).
      msg <- as.character(output$statusMessage)
      expect_true(any(grepl("No pedigree is loaded", msg)))
    }
  )
})

test_that("modPotentialParents: NA gestation input falls back to 210", {
  skip_if_not_installed("shiny")

  ped <- ppFromCenterPed()

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped), minParentAge = 2),
    {
      # NA gestation input -> the eventReactive fallback uses 210L (L261)
      # instead of passing NA to getPotentialParents.
      session$setInputs(maxGestationalPeriod = NA, findParents = 1)

      td <- session$getReturned()$tableData()
      expect_true(is.data.frame(td))
      expect_true(nrow(td) > 0L)
      expect_true("BRI2MW" %in% td$id)
    }
  )
})

test_that("modPotentialParents: downloadParents writes results CSV", {
  skip_if_not_installed("shiny")

  ped <- ppFromCenterPed()

  shiny::testServer(
    modPotentialParentsServer,
    args = list(pedigree = shiny::reactive(ped), minParentAge = 2),
    {
      session$setInputs(maxGestationalPeriod = 210, findParents = 1)

      # Reading the download output runs both the filename (L321) and the
      # content (L324) handlers, writing the flattened table to a file.
      path <- output$downloadParents
      expect_true(file.exists(path))

      back <- utils::read.csv(path, stringsAsFactors = FALSE,
                              colClasses = "character")
      expect_identical(names(back),
                       c("id", "nSires", "nDams", "sires", "dams"))
      expect_true(nrow(back) > 0L)
      expect_true("BRI2MW" %in% back$id)
    }
  )
})
