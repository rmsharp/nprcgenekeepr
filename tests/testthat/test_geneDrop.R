#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr
set_seed(10L)
## This test is entirely dependent on repeatable pseudorandom sequence
## generation. If this is disturbed, it will need to be rewritten.
ped <- nprcgenekeepr::lacy1989Ped
nDrops <- 5L
pedFactors <- data.frame(
  id = as.factor(ped$id),
  sire = as.factor(ped$sire),
  dam = as.factor(ped$dam),
  gen = ped$gen,
  population = ped$population,
  stringsAsFactors = TRUE
)
genotype <- data.frame(
  id = ped$id,
  first_allele = c(
    NA, NA, "A001_B001", "A001_B002", NA,
    "A001_B002", "A001_B001"
  ),
  second_allele = c(
    NA, NA, "A010_B001", "A001_B001", NA,
    NA, NA
  ),
  stringsAsFactors = FALSE
)
pedWithGenotype <- addGenotype(ped, genotype)
pedGenotype <- getGVGenotype(pedWithGenotype)
allelesFactors <-
  geneDrop(
    pedFactors$id,
    pedFactors$sire,
    pedFactors$dam,
    pedFactors$gen,
    genotype = NULL,
    n = nDrops,
    updateProgress = NULL
  )
allelesNew <- geneDrop(
  ped$id,
  ped$sire,
  ped$dam,
  ped$gen,
  genotype = NULL,
  n = nDrops,
  updateProgress = NULL
)
allelesNewGen <- geneDrop(
  ped$id,
  ped$sire,
  ped$dam,
  ped$gen,
  genotype = pedGenotype,
  n = nDrops,
  updateProgress = NULL
)

test_that(
  "geneDrop correctly drops gene down the pedigree using
          random segregation by Mendelian rules",
  {
    expect_identical(table(as.numeric(allelesNew[7L, 1L:nDrops]))[[1L]], 1L)
    expect_identical(table(as.numeric(allelesNew[7L, 1L:nDrops]))[[2L]], 4L)
    expect_identical(
      table(as.numeric(allelesFactors[7L, 1L:nDrops]))[[1L]],
      2L
    )
    expect_identical(
      table(as.numeric(allelesFactors[7L, 1L:nDrops]))[[2L]],
      3L
    )
    expect_identical(
      table(as.numeric(allelesNewGen[7L, 1L:nDrops]))[["10001"]],
      nDrops
    )
    expect_identical(
      table(as.numeric(allelesNewGen[9L, 1L:nDrops]))[["10002"]],
      nDrops
    )
    expect_identical(
      table(as.numeric(allelesNewGen[13L, 1L:nDrops]))[["10001"]],
      5L
    )
    expect_identical(
      table(as.numeric(allelesNewGen[12L, 1L:nDrops]))[["6"]],
      3L
    )
  }
)

## NEW-45: geneDrop rebuilds id/parent by splitting flattened rownames on '.',
## so a period-bearing id silently corrupts the output. The ID domain forbids
## '.' (input_format.html "Alphanumeric characters (no symbols)"), so geneDrop
## must reject such ids with a clear error rather than mis-assign alleles.
test_that("geneDrop rejects IDs containing a period ('.') (NEW-45)", {
  expect_error(
    geneDrop(
      ids = c("A.1", "B2", "C3"),
      sires = c(NA, "A.1", "A.1"),
      dams = c(NA, NA, "B2"),
      gen = c(1L, 2L, 3L),
      genotype = NULL, n = 3L, updateProgress = NULL
    ),
    "must not contain a period"
  )
  ## no-false-positive guard: period-free ids still run normally
  out <- geneDrop(
    ids = c("A1", "B2", "C3"),
    sires = c(NA, "A1", "A1"),
    dams = c(NA, NA, "B2"),
    gen = c(1L, 2L, 3L),
    genotype = NULL, n = 3L, updateProgress = NULL
  )
  expect_s3_class(out, "data.frame")
  expect_identical(unique(out$id), c("A1", "B2", "C3"))
})
