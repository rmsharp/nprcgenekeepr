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

## NEW-46: geneDrop builds its working data.frame with `rownames(ped) <- ids`,
## which errors with the cryptic base-R message "duplicate 'row.names' are not
## allowed" when ids repeat -- before any allele logic runs. Animal IDs uniquely
## identify animals (kinship() stops with "All id values must be unique";
## removeDuplicates() stops on mismatched dup ids), so geneDrop must reject
## duplicate ids with a clear, actionable error of its own.
test_that("geneDrop rejects duplicate animal IDs (NEW-46)", {
  ## (1) mismatched duplicate id 'A' (founder at gen 1, child of B at gen 2)
  expect_error(
    geneDrop(
      ids = c("A", "B", "A"),
      sires = c(NA, NA, "B"),
      dams = c(NA, NA, NA),
      gen = c(1L, 1L, 2L),
      genotype = NULL, n = 3L, updateProgress = NULL
    ),
    "must be unique"
  )
  ## (2) exact-duplicate row 'A' (identical parents) is ALSO rejected
  expect_error(
    geneDrop(
      ids = c("A", "A", "B"),
      sires = c(NA, NA, "A"),
      dams = c(NA, NA, NA),
      gen = c(1L, 1L, 2L),
      genotype = NULL, n = 3L, updateProgress = NULL
    ),
    "must be unique"
  )
  ## no-false-positive guard: unique ids still run normally
  out <- geneDrop(
    ids = c("A", "B", "C"),
    sires = c(NA, "A", "A"),
    dams = c(NA, NA, "B"),
    gen = c(1L, 2L, 3L),
    genotype = NULL, n = 3L, updateProgress = NULL
  )
  expect_s3_class(out, "data.frame")
  expect_identical(unique(out$id), c("A", "B", "C"))
})

test_that("geneDrop defaults n to 1000 iterations (issue #2 Slice 3)", {
  ## Issue #2 D3 (RATIFIED S196): align the gene-drop default 5000 -> 1000.
  expect_identical(eval(formals(geneDrop)[["n"]]), 1000L)
  ## the default actually drives the simulation: a default-n run on the small
  ## lacy1989Ped fixture returns exactly 1000 iteration (V) columns
  ## (geneDrop returns V1..Vn, then id, parent).
  ped <- nprcgenekeepr::lacy1989Ped
  gd <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
                 genotype = NULL, updateProgress = NULL)
  expect_identical(sum(grepl("^V[0-9]+$", names(gd))), 1000L)
})
