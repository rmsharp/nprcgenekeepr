## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
data("ped1Alleles")
test_that("calcGU forms dataframe with correct calculations", {
  gu_1 <- calcGU(ped1Alleles, threshold = 1L, byID = FALSE, pop = NULL)
  gu_3 <- calcGU(ped1Alleles, threshold = 3L, byID = FALSE, pop = NULL)
  expect_length(gu_1$gu[gu_1$gu == 50L], 110L)
  expect_length(gu_3$gu[gu_3$gu == 50L], 43L)
  gu_1 <- calcGU(ped1Alleles, threshold = 2L, byID = TRUE, pop = NULL)
  gu_3 <- calcGU(ped1Alleles,
    threshold = 3L, byID = FALSE,
    pop = ped1Alleles$id[20L:60L]
  )
  expect_length(gu_1$gu[gu_1$gu == 50L], 53L)
  expect_length(gu_3$gu[gu_3$gu == 50L], 0L)
})

# S925: one animal stopped calcGU() with "'x' must be an array of at least two
# dimensions" (calcA() returned a bare vector), and a pop that names no animal
# stopped it in alleleFreq() ("'names' attribute [2] must be the same length as
# the vector [1]"). One animal now gives one row; no animal gives no rows.
test_that("calcGU returns one row for a single animal (S925)", {
  oneId <- ped1Alleles$id[1L]
  one <- ped1Alleles[ped1Alleles$id == oneId, ]
  iterations <- setdiff(names(ped1Alleles), c("id", "parent"))
  ## Alone, both alleles are rare unless they are the same allele.
  rareCount <- ifelse(
    unlist(one[1L, iterations]) != unlist(one[2L, iterations]), 2L, 0L
  )
  expectedGU <- 100 * sum(rareCount) / (2L * length(iterations))

  gu <- calcGU(ped1Alleles, threshold = 1L, byID = FALSE, pop = oneId)
  expect_s3_class(gu, "data.frame")
  expect_named(gu, "gu")
  expect_identical(rownames(gu), oneId)
  expect_equal(gu$gu, expectedGU)

  ## byID counts each distinct allele once, so a lone animal is 100% unique.
  guByID <- calcGU(ped1Alleles, threshold = 1L, byID = TRUE, pop = oneId)
  expect_identical(rownames(guByID), oneId)
  expect_equal(guByID$gu, 100)
})

test_that("calcGU returns an empty table when pop names no animal (S925)", {
  for (pop in list("NO_SUCH_ANIMAL", character(0L))) {
    for (byID in c(FALSE, TRUE)) {
      gu <- calcGU(ped1Alleles, threshold = 1L, byID = byID, pop = pop)
      expect_s3_class(gu, "data.frame")
      expect_named(gu, "gu")
      expect_identical(nrow(gu), 0L)
    }
  }
})
