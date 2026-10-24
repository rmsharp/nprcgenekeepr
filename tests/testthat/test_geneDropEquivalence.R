## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 2, the gene drop" (owner
## pick S1054; plan docs/planning/performance-memory-campaign-plan.md, Phase 2
## and section 5.1). geneDrop() kept each animal's alleles in a list grown one
## animal at a time, looked its parents up by row name and built its table
## through a data frame with one column per allele: 1.87 s and a 265 MB peak on
## the example's 3,694 animals at 1,000 iterations (S1054, this Mac). A fast
## path fills one matrix, one column per allele, finding parents by position.
##
## The owner's rulings: every result stays exactly today's for the same inputs
## and seed (D1), and the exported functions keep their arguments and results
## (D3). So each block compares geneDrop() with the frozen copy of today's
## function (geneDropReference(), helper-perfReference.R) using identical().
## The fast path is for ordinary pedigrees; any other input goes through
## geneDropGeneral(), today's code unchanged (owner ruling S1054), so it gives
## today's result, or today's error, by construction. reportGV()'s own
## comparison with its frozen copy is in test_rareAlleleCounts.R; its two gene
## drops now run in geneDropReference() there.

## The plan's grid: four shipped pedigrees (the genotyped one with its double
## codes as shipped and with integer copies) and the example's analysis set.
gridInputs <- function() {
  genotype <- getGVGenotype(nprcgenekeepr::pedWithGenotype)
  list(
    list(name = "lacy1989Ped", ped = nprcgenekeepr::lacy1989Ped,
         genotype = NULL, n = 50L, type = "integer"),
    list(name = "qcPed", ped = nprcgenekeepr::qcPed,
         genotype = NULL, n = 50L, type = "integer"),
    list(name = "pedWithGenotype (double codes)",
         ped = nprcgenekeepr::pedWithGenotype,
         genotype = genotype, n = 50L, type = "double"),
    list(name = "pedWithGenotype (integer codes)",
         ped = nprcgenekeepr::pedWithGenotype,
         genotype = integerCodes(genotype), n = 50L, type = "integer"),
    list(name = "example (app trim)", ped = exampleAnalysisPed(),
         genotype = NULL, n = 20L, type = "integer")
  )
}

gridSeeds <- c(1L, 7L, 2026L)

dropWith <- function(f, input, seed) {
  ped <- input$ped
  withr::with_seed(seed, f(
    ped$id, ped$sire, ped$dam, ped$gen, genotype = input$genotype,
    n = input$n
  ))
}

expectGridMatchesReference <- function() {
  for (input in gridInputs()) {
    for (seed in gridSeeds) {
      info <- sprintf("%s, seed %d", input$name, seed)
      new <- dropWith(geneDrop, input, seed)
      expect_identical(new, dropWith(geneDropReference, input, seed),
                       info = info)
      expect_type(new$V1, input$type)
    }
  }
}

## geneDrop()'s arguments, from a pedigree's columns.
pedArgs <- function(ped, ...) {
  c(list(ids = ped$id, sires = ped$sire, dams = ped$dam, gen = ped$gen),
    list(...))
}

## Inputs a script can pass to geneDrop() that the app never does: each was
## run through today's geneDrop() and the plan's prototype before RED (S1054).
## The prototype gave a different table or error on 9 of them.
## Each element: the arguments, and the path the fast version must take.
unusualInputs <- function() {
  lacy <- nprcgenekeepr::lacy1989Ped
  qc <- nprcgenekeepr::qcPed
  pg <- nprcgenekeepr::pedWithGenotype
  codes <- integerCodes(getGVGenotype(pg))
  ## a genotyped animal of pedWithGenotype with both codes known (row 52)
  known <- which(!is.na(codes$first) & !is.na(codes$second) &
                   codes$id %in% pg$id)[1L]
  ## a row with both codes missing, which geneDrop() removes first (row 1)
  blank <- which(is.na(codes$first) & is.na(codes$second))[1L]
  lacyFactors <- lacy
  lacyFactors$id <- factor(lacy$id)
  lacyFactors$sire <- factor(lacy$sire)
  lacyFactors$dam <- factor(lacy$dam)
  numericPed <- data.frame(id = 1L:5L, sire = c(NA, NA, 1L, 1L, 3L),
                           dam = c(NA, NA, 2L, 2L, 4L), gen = c(0, 0, 1, 1, 2))
  tiny <- function(ids, sires, dams, gen) {
    list(ids = ids, sires = sires, dams = dams, gen = gen, n = 5L)
  }
  sameGen <- pedArgs(qc, n = 5L)
  sameGen$gen <- rep(0L, length(qc$id))
  textGen <- pedArgs(lacy, n = 5L)
  textGen$gen <- as.character(lacy$gen)
  allMissing <- codes
  allMissing$first <- NA_real_
  allMissing$second <- NA_real_
  outsideRow <- codes[known, ]
  outsideRow$id <- "notInPed"
  outsideRow$first <- 99
  outsideRow$second <- 98
  unusedDouble <- codes
  unusedDouble$first <- NA_real_
  textCodes <- codes
  textCodes$first <- as.character(textCodes$first)
  factorIds <- codes
  factorIds$id <- factor(factorIds$id)
  usedNA <- codes
  usedNA$id[known] <- NA
  missingAnimal <- codes[-known, ]
  missingAnimal <- rbind(missingAnimal, transform(codes[known, ], id = NA))
  blankNA <- codes
  blankNA$id[blank] <- NA
  twiceOutside <- data.frame(id = c("zz1", "zz1"), first = 1L, second = 2L)
  fast <- function(args) list(args = args, path = "fast")
  general <- function(args) list(args = args, path = "general")
  list(
    `no animals` = general(tiny(character(), character(), character(),
                                integer())),
    `one founder` = fast(tiny("a", NA, NA, 0L)),
    `zero iterations` = general(pedArgs(lacy, n = 0L)),
    `one iteration` = fast(pedArgs(lacy, n = 1L)),
    `a whole number of iterations stored as a double` =
      fast(pedArgs(lacy, n = 50)),
    `a fractional number of iterations` = general(pedArgs(lacy, n = 2.5)),
    `a negative number of iterations` = general(pedArgs(lacy, n = -1L)),
    `a missing number of iterations` =
      general(pedArgs(lacy, n = NA_integer_)),
    `factor ids and parents` = fast(pedArgs(lacyFactors, n = 5L)),
    `numeric ids and parents` = fast(pedArgs(numericPed, n = 5L)),
    `parents all NA (logical)` = fast(tiny(c("a", "b"), c(NA, NA),
                                           c(NA, NA), c(0L, 0L))),
    `a missing id` = general(tiny(c("a", NA, "c"), c(NA, NA, "a"),
                                  c(NA, NA, NA), c(0L, 0L, 1L))),
    `an empty id` = general(tiny(c("a", "", "c"), c(NA, NA, "a"),
                                 c(NA, NA, ""), c(0L, 0L, 1L))),
    `an empty sire` = general(tiny(c("a", "b", "c"), c(NA, NA, ""),
                                   c(NA, NA, "b"), c(0L, 0L, 1L))),
    `a sire that is not an animal` =
      general(tiny(c("a", "b", "c"), c(NA, NA, "zz"), c(NA, NA, "b"),
                   c(0L, 0L, 1L))),
    `a parent in a later generation` =
      general(tiny(c("a", "b", "c"), c("c", NA, NA), c(NA, NA, NA),
                   c(0L, 0L, 1L))),
    `an animal that is its own sire` =
      general(tiny(c("a", "b"), c(NA, "b"), c(NA, NA), c(0L, 1L))),
    `one animal as both sire and dam` =
      fast(tiny(c("a", "b"), c(NA, "a"), c(NA, "a"), c(0L, 1L))),
    `short sires R repeats to fit` =
      general(tiny(c("a", "b", "c", "d"), c(NA, NA), c(NA, NA, NA, NA),
                   c(0L, 0L, 0L, 0L))),
    `sires of a different length` =
      general(tiny(c("a", "b", "c"), c(NA, NA), c(NA, NA, NA),
                   c(0L, 0L, 0L))),
    `a missing generation` =
      general(tiny(c("a", "b", "c"), c(NA, NA, "a"), c(NA, NA, "b"),
                   c(0L, NA, 1L))),
    `every animal in one generation` = fast(sameGen),
    `generations as text` = fast(textGen),
    `genotype: every code missing (double columns)` =
      fast(pedArgs(pg, genotype = allMissing, n = 5L)),
    `genotype: a double-coded row for an animal not in the pedigree` =
      fast(pedArgs(pg, genotype = rbind(codes, outsideRow), n = 5L)),
    `genotype: a double first column never used` =
      fast(pedArgs(pg, genotype = unusedDouble, n = 5L)),
    `genotype: a duplicated row with both codes missing` =
      fast(pedArgs(pg, genotype = rbind(codes, codes[blank, ]), n = 5L)),
    `genotype: a missing id on a row with both codes missing` =
      fast(pedArgs(pg, genotype = blankNA, n = 5L)),
    `genotype: text codes` =
      general(pedArgs(pg, genotype = textCodes, n = 5L)),
    `genotype: factor ids` = fast(pedArgs(pg, genotype = factorIds, n = 5L)),
    `genotype: no rows` = fast(pedArgs(pg, genotype = codes[0L, ], n = 5L)),
    `genotype: no second column` =
      general(pedArgs(pg, genotype = codes[, c("id", "first")], n = 5L)),
    `genotype: a genotyped animal on two rows` =
      general(pedArgs(pg, genotype = rbind(codes, codes[known, ]), n = 5L)),
    `genotype: a missing id on a used row` =
      general(pedArgs(pg, genotype = usedNA, n = 5L)),
    `genotype: a missing id, and its animal's row gone` =
      general(pedArgs(pg, genotype = missingAnimal, n = 5L)),
    `genotype: an id twice, not in the pedigree` =
      fast(pedArgs(pg, genotype = rbind(codes, twiceOutside), n = 5L))
  )
}

test_that("geneDrop() gives the frozen copy's table on the plan's grid", {
  expectGridMatchesReference()
})

test_that("the plan's grid takes the fast path, never today's code", {
  local_mocked_bindings(
    geneDropGeneral = function(...) stop("geneDropGeneral() was called")
  )
  expectGridMatchesReference()
})

test_that("unusual inputs give the frozen copy's table, or its error", {
  cases <- unusualInputs()
  expect_length(cases, 36L)
  for (name in names(cases)) {
    expect_identical(outcome(geneDrop, cases[[name]]$args),
                     outcome(geneDropReference, cases[[name]]$args),
                     info = name)
  }
})

test_that("an unusual input goes to today's code unless the fast path is safe", {
  cases <- unusualInputs()
  general <- geneDropGeneral
  current <- NULL
  used <- character()
  local_mocked_bindings(geneDropGeneral = function(...) {
    used <<- c(used, current)
    general(...)
  })
  for (name in names(cases)) {
    current <- name
    outcome(geneDrop, cases[[name]]$args)
  }
  paths <- vapply(cases, `[[`, character(1L), "path")
  expect_identical(used, names(cases)[paths == "general"])
  expect_identical(sum(paths == "fast"), 17L)
  expect_identical(sum(paths == "general"), 19L)
})
