context("removeUninformativeFounders")
library(testthat)
pedOne <- data.frame(ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
                  si_re = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
                  dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
                  sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
                  stringsAsFactors = FALSE, check.names = FALSE)

data("baboonPed")

test_that("removeUninformativeFounders removes correct records", {
  expect_error(removeUninformativeFounders(pedOne))
  names(pedOne) <- c("id", "sire", "dam")
  expect_silent(removeUninformativeFounders(pedOne))
  expect_equal(nrow(removeUninformativeFounders(baboonPed)), 136)
})