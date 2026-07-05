## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# nolint start: object_name_linter
ped <- nprcgenekeepr::smallPed
simParent_1 <- list(
  id = "A",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_2 <- list(
  id = "B",
  sires = c("s1_1", "s1_2", "s1_3"),
  dams = c("d1_1", "d1_2", "d1_3", "d1_4")
)
simParent_3 <- list(
  id = "E",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_4 <- list(
  id = "J",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_5 <- list(
  id = "K",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
simParent_6 <- list(
  id = "N",
  sires = c("A", "C", "s1_1"),
  dams = c("d3_1", "B")
)
allSimParents <- list(
  simParent_1, simParent_2, simParent_3,
  simParent_4, simParent_5, simParent_6
)

extractKinship <- function(simKinships, id1, id2) {
  vapply(simKinships,
    function(x) {
      x[
        seq_along(ped$id)[ped$id == id1],
        seq_along(ped$id)[ped$id == id2]
      ]
    },
    FUN.VALUE = numeric(1L)
  )
}
# nolint end: object_name_linter
set_seed(seed = 2L)
n <- 100L
simKinships <- cumulateSimKinships(ped, allSimParents, pop = ped$id, n = n)
testEN <- simKinships$meanKinship[
  seq_along(ped$id)[ped$id == "E"],
  seq_along(ped$id)[ped$id == "N"]
]

test_that("cumulateSimKinships creates the correct kinship summary structure", {
  ## Re-baselined S277: makeSimPed now preserves A's known sire Q (#31).
  expect_equal(testEN, 0.060000, tolerance = 0.000001)
  expect_length(simKinships, 4L)
  expect_equal(names(simKinships), c(
    "meanKinship", "sdKinship", "minKinship",
    "maxKinship"
  ))
  expect_equal(length(simKinships$meanKinship), 17L * 17L)
  expect_equal(nrow(simKinships$sdKinship), 17L)
})

test_that("cumulateSimKinships handles n < 2 simulations (NEW-52)", {
  # n = 1: the sample standard deviation is undefined, so sdKinship is NA
  # (not NaN), accompanied by a warning; mean/min/max remain valid.
  set_seed(seed = 2L)
  expect_warning(
    sim_n1 <- cumulateSimKinships(ped, allSimParents, pop = ped$id, n = 1L),
    "undefined for n < 2"
  )
  expect_true(all(is.na(sim_n1$sdKinship)))
  expect_false(any(is.nan(sim_n1$sdKinship))) # NA, not NaN
  expect_false(any(is.nan(sim_n1$meanKinship))) # mean still computed
  expect_false(any(is.nan(sim_n1$minKinship)))
  expect_false(any(is.nan(sim_n1$maxKinship)))

  # n = 0: zero simulations is a clear error, not the cryptic
  # "object 'minKinship' not found".
  expect_error(
    cumulateSimKinships(ped, allSimParents, pop = ped$id, n = 0L),
    "at least one simulation"
  )

  # Guard: n >= 2 still yields a finite sd, with no warning and no NA/NaN.
  set_seed(seed = 2L)
  expect_warning(
    sim_n2 <- cumulateSimKinships(ped, allSimParents, pop = ped$id, n = 2L),
    regexp = NA
  )
  expect_false(any(is.na(sim_n2$sdKinship)))
})
