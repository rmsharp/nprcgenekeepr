## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## BACKLOG.md "Performance and memory campaign: Phase 4, group formation"
## (owner pick S1056; plan docs/planning/performance-memory-campaign-plan.md,
## Phase 4 and section 5.1). groupAddAssign() must give exactly today's result
## for the same inputs and seed (decision D1): its whole result is compared
## with groupAddAssignReference() (helper-perfReference.R: groupAddAssign()
## run on the frozen copies of today's fillGroupMembers() and
## fillGroupMembersWithSexRatio()) using identical().
##
## The new code fills the groups from a true/false table of the animals each
## group may still take, with each animal's relatives as row numbers and, with a
## sex ratio, each group's males and other animals as running counts (owner
## ruling S1056). An input it does not admit runs today's code word for word:
## fillGroupMembersGeneral() and fillGroupMembersWithSexRatioGeneral() (owner
## ruling S1056, as in Phases 1-3). The odd inputs below were probed before RED
## (S1056) against the new code with no admission checks: the ones marked
## "today's code" gave a different result there (one looped for ever), so each
## check the new code makes has an input that needs it.

seeds <- c(1L, 7L, 2026L)

breedersPed <- nprcgenekeepr::pedWithGenotype
breeders <- nprcgenekeepr::qcBreeders
breedersKmat <- nprcgenekeepr::pedWithGenotypeReport$kinship

## The example ancestry pedigree and its rules
## (test_groupAddAssignAncestry.R reads them the same way).
ancestryInput <- local({
  input <- NULL
  function() {
    if (is.null(input)) {
      raw <- utils::read.csv(
        system.file("extdata", "examples", "example_ancestry_pedigree.csv",
                    package = "nprcgenekeepr"),
        stringsAsFactors = FALSE, na.strings = c("", "NA")
      )
      ped <- qcStudbook(raw, minSireAge = 2, minDamAge = 2,
                        reportChanges = FALSE, reportErrors = FALSE)
      input <<- list(
        ped = ped,
        kmat = kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE),
        rules = checkAncestryRules(readAncestryRules(system.file(
          "extdata", "examples", "example_ancestry_rules.csv",
          package = "nprcgenekeepr"
        )))
      )
    }
    input
  }
})

## groupAddAssign()'s arguments for each grid case: three inputs x {plain,
## harem, sex ratio, seeded current groups, ancestry rules, exhaustive}.
gridCases <- function() {
  ex <- exampleGroupInput()
  anc <- ancestryInput()
  breedersArgs <- function(...) {
    list(candidates = breeders, kmat = breedersKmat, ped = breedersPed,
         iter = 10L, ...)
  }
  exampleArgs <- function(...) {
    list(candidates = ex$candidates, kmat = ex$kmat, ped = ex$ped,
         iter = 5L, ...)
  }
  ancestryArgs <- function(...) {
    list(candidates = anc$ped$id, kmat = anc$kmat, ped = anc$ped,
         iter = 10L, ancestryRules = anc$rules, ...)
  }
  exSire <- getPotentialSires(ex$candidates, ex$ped, 1.0)[[1L]]
  list(
    `breeders, 2 groups` = breedersArgs(numGp = 2L),
    `breeders, 1 group seeded with 3` = breedersArgs(
      numGp = 1L, currentGroups = list(breeders[1L:3L]), ignore = NULL
    ),
    `breeders, 2 harems` = breedersArgs(numGp = 2L, harem = TRUE),
    `breeders, sex ratio 1, 2 groups` = breedersArgs(numGp = 2L,
                                                     sexRatio = 1.0),
    `breeders, sex ratio 2, a seeded group` = breedersArgs(
      numGp = 2L, sexRatio = 2.0, currentGroups = list(breeders[1L:2L])
    ),
    `breeders, kinship kept, 3 retained` = breedersArgs(
      numGp = 2L, withKin = TRUE, maxCandidates = 3L
    ),
    `breeders, exhaustive` = list(
      candidates = breeders[1L:8L], kmat = breedersKmat, ped = breedersPed,
      numGp = 1L, exhaustive = TRUE
    ),
    `example, 6 groups` = exampleArgs(numGp = 6L),
    `example, 6 harems` = exampleArgs(numGp = 6L, harem = TRUE),
    `example, sex ratio 9, 6 groups` = exampleArgs(numGp = 6L, sexRatio = 9.0),
    `example, sex ratio 0.5, 3 groups` = exampleArgs(numGp = 3L,
                                                     sexRatio = 0.5),
    `example, 2 seeded groups of 4` = exampleArgs(
      numGp = 3L,
      currentGroups = list(ex$candidates[1L:4L], ex$candidates[5L:8L])
    ),
    `example, 3 harems, one seeded with a sire` = exampleArgs(
      numGp = 3L, harem = TRUE, currentGroups = list(exSire)
    ),
    `example, sex ratio 3, a seeded group` = exampleArgs(
      numGp = 2L, sexRatio = 3.0, currentGroups = list(ex$candidates[1L:3L])
    ),
    `ancestry rules, 2 groups` = ancestryArgs(numGp = 2L),
    `ancestry rules, sex ratio 1, 2 groups` = ancestryArgs(numGp = 2L,
                                                           sexRatio = 1.0),
    `ancestry rules, 2 harems` = ancestryArgs(numGp = 2L, harem = TRUE)
  )
}

## outcome() (helper-perfCampaign.R) under a time limit: a call that runs on
## (the new code without its repeated-id check loops for ever) fails the
## comparison instead of hanging the test.
boundedOutcome <- function(f, args, seed) {
  setTimeLimit(elapsed = 30, transient = TRUE)
  on.exit(setTimeLimit(elapsed = Inf), add = TRUE)
  outcome(f, args, seed)
}

expectSameOutcomes <- function(f, reference, cases) {
  for (name in names(cases)) {
    for (seed in seeds) {
      expect_identical(
        boundedOutcome(f, cases[[name]], seed),
        boundedOutcome(reference, cases[[name]], seed),
        info = sprintf("%s, seed %d", name, seed)
      )
    }
  }
}

## Today's outcomes on the grid, computed once for the two blocks below.
gridReference <- local({
  outcomes <- NULL
  function() {
    if (is.null(outcomes)) {
      outcomes <<- lapply(gridCases(), function(args) {
        lapply(seeds, function(seed) {
          boundedOutcome(groupAddAssignReference, args, seed)
        })
      })
    }
    outcomes
  }
})

expectGridMatches <- function() {
  cases <- gridCases()
  reference <- gridReference()
  for (name in names(cases)) {
    for (k in seq_along(seeds)) {
      expect_identical(
        boundedOutcome(groupAddAssign, cases[[name]], seeds[[k]]),
        reference[[name]][[k]],
        info = sprintf("%s, seed %d", name, seeds[[k]])
      )
    }
  }
}

test_that("groupAddAssign() gives today's whole result on the grid", {
  expectGridMatches()
})

test_that("the grid runs the new code: today's code mocked to stop changes nothing", {
  local_mocked_bindings(
    fillGroupMembersGeneral = function(...) {
      stop("fillGroupMembersGeneral() was called")
    },
    fillGroupMembersWithSexRatioGeneral = function(...) {
      stop("fillGroupMembersWithSexRatioGeneral() was called")
    }
  )
  expectGridMatches()
})

## The relatives list groupAddAssign() builds for the breeders and hands to
## fillGroupMembers().
breedersKin <- function(candidates = breeders) {
  kmat <- filterKinMatrix(candidates, breedersKmat)
  addAnimalsWithNoRelative(
    getAnimalsWithHighKinship(kmat, breedersPed, 0.015625,
                              list(character(0L)), list(c("F", "F")), 1.0),
    candidates
  )
}

## fillGroupMembers()'s arguments: ordinary values unless named.
fillArgs <- function(candidates = breeders,
                     currentGroups = list(character(0L)),
                     kin = breedersKin(), ped = breedersPed, harem = FALSE,
                     minAge = 1.0, numGp = 2L, sexRatio = 0.0) {
  list(candidates, currentGroups, kin, ped, harem, minAge, numGp, sexRatio)
}

## The breeders' relatives keyed and valued by their position numbers.
numberedKin <- function() {
  kin <- breedersKin()
  numbered <- lapply(kin, function(v) as.character(match(v, breeders)))
  names(numbered) <- as.character(match(names(kin), breeders))
  numbered
}

## The odd inputs: "today's code" marks those the new code must not admit.
fillCases <- function() {
  kin <- breedersKin()
  factorKin <- lapply(kin, function(v) if (is.character(v)) factor(v) else v)
  numberKin <- lapply(kin, function(v) {
    if (is.character(v)) as.numeric(factor(v)) else v
  })
  nullEntry <- kin
  nullEntry[breeders[[1L]]] <- list(NULL)
  list(
    `2 groups` = fillArgs(),
    `2 harems` = fillArgs(harem = TRUE),
    `a group seeded with 3` = fillArgs(currentGroups = list(breeders[1L:3L])),
    `factor candidates (today's code)` = fillArgs(candidates = factor(breeders)),
    `number candidates (today's code)` = fillArgs(
      candidates = seq_along(breeders), kin = numberedKin()
    ),
    `number candidates, one left (today's code)` = fillArgs(
      candidates = c(3, 5), kin = numberedKin()
    ),
    `a missing candidate (today's code)` = fillArgs(candidates = c(breeders,
                                                                   NA)),
    `a missing candidate alone (today's code)` = fillArgs(
      candidates = NA_character_, numGp = 1L
    ),
    `a missing candidate and one other (today's code)` = fillArgs(
      candidates = c(NA, breeders[[1L]]), numGp = 1L
    ),
    `a missing candidate and four others (today's code)` = fillArgs(
      candidates = c(NA, breeders[1L:4L]), numGp = 1L
    ),
    `an empty-text candidate` = fillArgs(
      candidates = c(breeders, ""), kin = c(kin, stats::setNames(list(NA), ""))
    ),
    `a candidate with no entry in kin` = fillArgs(kin = kin[-1L]),
    `named candidates` = fillArgs(
      candidates = stats::setNames(breeders, paste0("n", seq_along(breeders)))
    ),
    `repeated candidates` = fillArgs(candidates = c(breeders, breeders[1L:5L])),
    `candidates with an attribute` = fillArgs(
      candidates = structure(breeders, note = "an attribute")
    ),
    `candidates with a class` = fillArgs(
      candidates = structure(breeders, class = c("animalIds", "character"))
    ),
    `relatives as factors (today's code)` = fillArgs(kin = factorKin),
    `relatives as numbers (today's code)` = fillArgs(kin = numberKin),
    `kin with a repeated name` = fillArgs(
      kin = c(kin, stats::setNames(list(breeders[2L:9L]), breeders[[1L]]))
    ),
    `a NULL kin entry` = fillArgs(kin = nullEntry),
    `named relatives` = fillArgs(
      kin = lapply(kin, function(v) stats::setNames(v, seq_along(v)))
    ),
    `number seeds` = fillArgs(currentGroups = list(c(1, 2))),
    `a NULL seed group` = fillArgs(currentGroups = list(NULL, breeders[[1L]])),
    `more seeded groups than numGp` = fillArgs(
      currentGroups = list(breeders[[1L]], breeders[[2L]], breeders[[3L]])
    ),
    `numGp 2.5` = fillArgs(numGp = 2.5),
    `numGp 0 (today's code)` = fillArgs(numGp = 0),
    `numGp missing` = fillArgs(numGp = NA),
    `1 group` = fillArgs(numGp = 1L),
    `no candidates` = fillArgs(candidates = character(0L)),
    `one candidate` = fillArgs(candidates = breeders[[1L]])
  )
}

test_that("fillGroupMembers() gives today's outcome on odd inputs", {
  expectSameOutcomes(nprcgenekeepr:::fillGroupMembers,
                     fillGroupMembersReference, fillCases())
})

## The breeders by sex in the pedigree.
breedersOfSex <- function(sex) {
  breeders[breedersPed$sex[match(breeders, breedersPed$id)] %in% sex]
}

emptyGroups <- function(n = 2L, seeds = list()) {
  groups <- lapply(seq_len(n), function(i) vector())
  for (i in seq_along(seeds)) {
    groups[[i]] <- seeds[[i]]
  }
  groups
}

## fillGroupMembersWithSexRatio()'s arguments: ordinary values unless named.
sexRatioArgs <- function(candidates = breeders, groupMembers = emptyGroups(),
                         grpNum = makeGroupNum(2L), kin = breedersKin(),
                         ped = breedersPed, minAge = 1.0, numGp = 2L,
                         sexRatio = 1.0) {
  list(candidates, groupMembers, grpNum, kin, ped, minAge, numGp, sexRatio)
}

sexRatioCases <- function() {
  kin <- breedersKin()
  females <- breedersOfSex("F")
  sires <- getPotentialSires(breeders, breedersPed, 1.0)
  oneGroup <- list(numGp = 1L, grpNum = makeGroupNum(1L),
                   groupMembers = emptyGroups(1L))
  factorIds <- breedersPed
  factorIds$id <- factor(factorIds$id)
  repeatedMales <- rbind(
    breedersPed,
    breedersPed[breedersPed$id %in% sires, ][1L:2L, ]
  )
  repeatedFemales <- rbind(
    breedersPed,
    breedersPed[breedersPed$id %in% females, ][1L:2L, ]
  )
  unknownSires <- breedersPed
  unknownSires$sex[unknownSires$id %in% breeders][1L:3L] <- NA
  missingIds <- breedersPed
  missingIds$id[!(missingIds$id %in% breeders)][1L:2L] <- NA
  textSex <- breedersPed
  textSex$sex <- as.character(textSex$sex)
  ## two females of unknown sex and no birth date: in the female pool, never
  ## potential sires, counted as males and as other animals
  unknownFemales <- breedersPed
  unknownFemales$sex[unknownFemales$id %in% females[1L:2L]] <- NA
  unknownFemales$birth[unknownFemales$id %in% females[1L:2L]] <- NA
  numberKin <- stats::setNames(lapply(seq_along(breeders), function(i) NA),
                               seq_along(breeders))
  c(
    lapply(stats::setNames(c(0.5, 1.0, 3.0, 9.0),
                           paste("ratio", c(0.5, 1.0, 3.0, 9.0))),
           function(r) sexRatioArgs(sexRatio = r)),
    list(
      `seeded groups` = sexRatioArgs(
        groupMembers = emptyGroups(2L, list(breeders[1L:2L], breeders[[3L]]))
      ),
      `seeds that are also candidates` = sexRatioArgs(
        groupMembers = emptyGroups(2L, list(breeders[1L:4L]))
      ),
      `number seeds` = sexRatioArgs(
        groupMembers = emptyGroups(2L, list(c(1, 2)))
      ),
      `a seed not in the pedigree` = sexRatioArgs(
        groupMembers = emptyGroups(2L, list("NOT_IN_PED"))
      ),
      `a missing seed` = sexRatioArgs(
        groupMembers = emptyGroups(2L, list(NA_character_))
      ),
      `an unknown-sex seed` = sexRatioArgs(
        ped = unknownFemales,
        groupMembers = emptyGroups(2L, list(females[[1L]]))
      ),
      `factor candidates (today's code)` = sexRatioArgs(
        candidates = factor(breeders)
      ),
      `number candidates (today's code)` = sexRatioArgs(
        candidates = seq_along(breeders)
      ),
      `number candidates, one female (today's code)` = sexRatioArgs(
        candidates = 5, kin = numberKin
      ),
      `a missing candidate (today's code)` = sexRatioArgs(
        candidates = c(breeders, NA)
      ),
      `a missing candidate and one female (today's code)` = do.call(
        sexRatioArgs, c(list(candidates = c(NA, females[[1L]])), oneGroup)
      ),
      `a missing candidate with males left (today's code)` = sexRatioArgs(
        candidates = c(NA, females[1L:3L], sires), sexRatio = 0.5
      ),
      `a candidate not in the pedigree` = sexRatioArgs(
        candidates = c(breeders, "NOT_IN_PED"),
        kin = c(kin, list(NOT_IN_PED = NA))
      ),
      `named candidates` = sexRatioArgs(
        candidates = stats::setNames(breeders,
                                     paste0("n", seq_along(breeders)))
      ),
      `repeated candidates` = sexRatioArgs(
        candidates = c(breeders, breeders[1L:8L])
      ),
      `pedigree ids as a factor (today's code)` = sexRatioArgs(ped = factorIds),
      `a repeated male id in the pedigree (today's code)` = sexRatioArgs(
        ped = repeatedMales
      ),
      `a repeated female id in the pedigree (today's code)` = sexRatioArgs(
        ped = repeatedFemales
      ),
      `unknown sex among potential sires (today's code)` = sexRatioArgs(
        ped = unknownSires
      ),
      `unknown sex and no birth date` = sexRatioArgs(ped = unknownFemales),
      `unknown sex and no birth date, ratio 3` = sexRatioArgs(
        ped = unknownFemales, sexRatio = 3.0
      ),
      `missing pedigree ids (today's code)` = sexRatioArgs(ped = missingIds),
      `sex as text` = sexRatioArgs(ped = textSex),
      `fewer groups than numGp` = sexRatioArgs(groupMembers = emptyGroups(1L)),
      `a subset of the group numbers` = sexRatioArgs(grpNum = list(2L)),
      `repeated group numbers` = sexRatioArgs(grpNum = list(1L, 1L, 2L)),
      `a missing group number (today's code)` = sexRatioArgs(
        grpNum = list(1L, NA_integer_)
      ),
      `group number 0 (today's code)` = sexRatioArgs(grpNum = list(0L, 1L)),
      `a group number above numGp (today's code)` = sexRatioArgs(
        grpNum = list(1L, 3L)
      ),
      `group numbers as a vector` = sexRatioArgs(grpNum = 1L:2L),
      `one group number, not in a list` = sexRatioArgs(grpNum = 2L),
      `no females to start` = sexRatioArgs(candidates = breedersOfSex("M")),
      `no males to start` = sexRatioArgs(
        candidates = breeders[!(breeders %in% breedersOfSex("M"))]
      ),
      `no candidates` = sexRatioArgs(candidates = character(0L)),
      `a missing sexRatio` = sexRatioArgs(sexRatio = NA),
      `relatives as factors (today's code)` = sexRatioArgs(
        kin = lapply(kin, function(v) if (is.character(v)) factor(v) else v)
      ),
      `numGp 0 (today's code)` = sexRatioArgs(numGp = 0, grpNum = list()),
      `groupMembers not a list` = sexRatioArgs(groupMembers = c("a", "b")),
      `minAge 0` = sexRatioArgs(minAge = 0),
      `1 group` = do.call(sexRatioArgs, oneGroup)
    )
  )
}

test_that("fillGroupMembersWithSexRatio() gives today's outcome on odd inputs", {
  expectSameOutcomes(fillGroupMembersWithSexRatio,
                     fillGroupMembersWithSexRatioReference, sexRatioCases())
})

## Which code a call ran: "today's" when it reached fillGroupMembersGeneral()
## or fillGroupMembersWithSexRatioGeneral(), "new" when it reached neither.
pathTaken <- function(f, args) {
  reached <- FALSE
  local_mocked_bindings(
    fillGroupMembersGeneral = function(...) {
      reached <<- TRUE
      stop("today's code")
    },
    fillGroupMembersWithSexRatioGeneral = function(...) {
      reached <<- TRUE
      stop("today's code")
    }
  )
  try(withr::with_seed(1L, do.call(f, args)), silent = TRUE)
  if (reached) "today's" else "new"
}

test_that("ordinary inputs run the new code and the odd ones today's", {
  expectPaths <- function(f, cases) {
    ## a call that stops before it fills any group reaches neither function
    stopsFirst <- c("numGp missing")
    for (name in setdiff(names(cases), stopsFirst)) {
      expected <- if (grepl("(today's code)", name, fixed = TRUE)) {
        "today's"
      } else {
        "new"
      }
      expect_identical(pathTaken(f, cases[[name]]), expected, info = name)
    }
  }
  expectPaths(nprcgenekeepr:::fillGroupMembers, fillCases())
  expectPaths(fillGroupMembersWithSexRatio, sexRatioCases())
})
