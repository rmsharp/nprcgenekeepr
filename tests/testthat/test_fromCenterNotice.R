# Tests for fromCenterNotice() -- the one sentence the Potential Parents tab
# and the Candidate Parent Assignment tab (Marker Genetics) show when the
# pedigree has no "fromCenter" (colony-origin) column.
#
# getPotentialParents() returns NULL without that column
# (R/getPotentialParents.R), so neither tab can find anyone. The Potential
# Parents tab has always said so; the Candidate tab showed a blank table with
# no reason (found S944, BACKLOG.md:57; the owner ruled in S948 to give it the
# same sentence). The sentence lives in one internal function so the two tabs
# cannot drift apart.

fromCenterSentence <- paste0(
  "This dataset has no colony-origin ('fromCenter') field, so ",
  "potential parents cannot be identified."
)

test_that("fromCenterNotice exists", {
  expect_true(exists("fromCenterNotice", mode = "function"))
})

test_that("fromCenterNotice returns one alert-warning div", {
  notice <- fromCenterNotice()

  expect_s3_class(notice, "shiny.tag")
  expect_identical(notice$name, "div")
  expect_identical(notice$attribs$class, "alert alert-warning")
})

test_that("fromCenterNotice says, in the Potential Parents tab's words, that the dataset has no colony-origin field", {
  text <- paste(unlist(fromCenterNotice()$children), collapse = "")

  expect_identical(text, fromCenterSentence)
})

test_that("fromCenterNotice takes no arguments and gives the same notice every call", {
  expect_length(formals(fromCenterNotice), 0L)
  expect_identical(fromCenterNotice(), fromCenterNotice())
})
