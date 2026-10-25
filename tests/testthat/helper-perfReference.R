## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Frozen copies of functions the performance and memory campaign changes
## (docs/planning/performance-memory-campaign-plan.md section 5.1, decision
## D1: every phase gives exactly today's results for the same inputs and
## seed). Each copy is the function's text at commit 520bd5dc8, the last
## commit before the campaign changed package code (`git show
## 520bd5dc8:R/<file>.R`), renamed <name>Reference(); the only other edits
## point a copy's calls at the other frozen copies, so the oracle never runs
## the code under test. The equivalence tests compare the new code with
## these copies using identical(). Never edit a copy to make a test pass.

## Phase 1 (genome uniqueness): R/calcA.R at 520bd5dc8.
calcAReference <- function(alleles, threshold = 1L, byID = FALSE) {
  ids <- alleles$id
  alleles <- alleles[, !(names(alleles) %in% c("id", "parent"))]

  countRare <- function(a) {
    if (byID) {
      f <- alleleFreq(a, ids)
    } else {
      f <- alleleFreq(a)
    }
    rareAlleles <- f$allele[f$freq <= threshold]
    a <- (a %in% rareAlleles)
    tapply(a, ids, sum)
  }

  # S925: cbind keeps one row per animal; apply()'s own simplification turned
  # a single animal's row into a bare vector and dropped its id.
  do.call(cbind, apply(alleles, 2L, countRare, simplify = FALSE))
}

## Phase 1 (genome uniqueness): R/calcGU.R at 520bd5dc8.
calcGUReference <- function(alleles, threshold = 1L, byID = FALSE, pop = NULL) {
  if (!is.null(pop)) {
    alleles <- alleles[alleles$id %in% pop, ]
  }

  # Calculate the number of an individual's alleles that are rare in
  # each simulation and average across all simulated alleles.
  rare <- calcAReference(alleles, threshold, byID)
  iterations <- sum(!(colnames(alleles) %in% c("id", "parent")))
  gu <- rowSums(rare) / (2L * iterations)

  # convert to a percentage
  gu <- gu * 100L
  gu <- as.data.frame(gu)

  gu
}

## Phase 1 (genome uniqueness): R/calcGUSE.R at 520bd5dc8.
calcGUSEReference <- function(alleles, threshold = 1L, byID = FALSE, pop = NULL) {
  if (!is.null(pop)) {
    alleles <- alleles[alleles$id %in% pop, ]
  }

  # The per-iteration rare-allele counts calcGU() averages. m_ik = rare[i, k]/2
  # is the iteration-k value whose mean over iterations equals gu_i / 100.
  rare <- calcAReference(alleles, threshold, byID)
  iterations <- sum(!(colnames(alleles) %in% c("id", "parent")))
  perColumn <- rare / 2L

  # Exact Monte Carlo standard error of the mean, on the gu percentage scale.
  guSE <- sqrt(apply(perColumn, 1L, stats::var) / iterations) * 100L
  guSE <- as.data.frame(guSE)

  guSE
}

## Phase 1 (genome uniqueness): R/reportGV.R at 520bd5dc8.
## Phase 2 points its two geneDrop() calls at geneDropReference().
## Phase 5 points its calcFEFG() and calcFGSE() calls at calcFEFGReference()
## and calcFGSEReference(), and Phase 6 its kinship() call at
## kinshipReference().
reportGVReference <- function(ped, guIter = 1000L, guThresh = 1L, pop = NULL,
                     byID = TRUE, updateProgress = NULL,
                     breedingTable = NULL, gestationTable = NULL,
                     breedingAgeDefault = NULL, gestationDefault = NULL,
                     kinshipOverrides = NULL, twinRelations = NULL,
                     guCutoff = NULL, zScoreCutoff = NULL,
                     axisPriority = NULL) {
  # Generates a genetic value report for a provided pedigree

  # NEW-28 (issue #123 XARCH-5 for 'sex'): name every missing required column
  # before any other work, rather than failing later with a base-R message
  # (id, sire, dam, gen: the kinship step) or after kinship() and geneDrop()
  # have run ('sex': the founder lists). Chosen on purpose (owner, S889): a
  # pedigree missing 'sex' that also has an animal with one known parent now
  # gets this message, not calcFEFG()'s partial-parentage one, which is why
  # the partial-parentage test in test_calcFEFG.R gives its pedigree a sex
  # column.
  assertRequiredColsPresent(
    names(ped), c("id", "sire", "dam", "gen", "sex"), "reportGV(ped)"
  )

  ## If user has limited the population of interest by defining 'pop',
  ## that information is incorporated via the 'population' column.
  ped$population <- getGVPopulation(ped, pop)

  # Get the list of animals in the population to consider
  probands <- as.character(ped$id[ped$population])
  # S924: a ranking needs at least 2 animals (with one, the report would run
  # but its z-score would be NaN), so a smaller population stops here, before
  # kinship(), with the count.
  assertPopulationSize(length(probands), "reportGV(ped)")

  ## Extract genotype data if available otherwise NULL is returned.
  genotype <- getGVGenotype(ped)

  # Generate the kinship matrix and filter down to the animals of interest
  kmat <- filterKinMatrix(probands, kinshipReference(
    ped$id, ped$sire, ped$dam,
    ped$gen,
    twinRelations = twinRelations
  ))

  # Issue 13 / issue 95 keep-all revert: validate the outside-information
  # overrides, warn-drop rows naming ids outside the proband matrix (D5), and
  # apply the survivors to the matrix BEFORE mean kinship and the issue-9
  # correction. The override REFINES the named kinship cell; it never suppresses
  # the +sexMean/2 unknown-parent prior, which is kept for every one-unknown
  # animal. Shared with gvaConvergence via prepareKinshipOverrides so the report
  # and the convergence diagnostic cannot drift. kinship is untouched.
  prepared <- prepareKinshipOverrides(kmat, kinshipOverrides)
  kmat <- prepared$kmat

  # Calculate the mean kinship, and convert to z-scores
  indivMeanKin <- meanKinship(kmat)
  indivMeanKin <- indivMeanKin[probands] # making sure the order is correct

  # Issue #9 Slice 2: raise the mean kinship of animals missing exactly one
  # parent toward the mean of their contemporaneous breeding-age peers of the
  # missing parent's sex (+ sexMean / 2), so a single unknown (U-id) parent no
  # longer falsely elevates an animal's genetic value. Known and both-unknown
  # animals are left unchanged. This feeds both the z-scores below and the
  # report column, so both rank paths reflect it; kinship() is untouched.
  mkCorrection <-
    correctUnknownParentMeanKinship(indivMeanKin, ped,
      gestationTable = gestationTable,
      breedingTable = breedingTable,
      breedingAgeDefault = breedingAgeDefault,
      gestationDefault = gestationDefault
    )
  indivMeanKin <- mkCorrection$indivMeanKin
  # nolint start: commented_code_linter.
  # Issue #127: probands %in% mkCorrection$flagged (not the reverse) keeps
  # flagged a plain logical vector in probands order, ready to cbind()
  # alongside indivMeanKin/zScores/gu/etc. with no name-alignment step.
  # nolint end
  flagged <- probands %in% mkCorrection$flagged

  zScores <- scale(indivMeanKin)

  # Perform the gene drop simulation
  alleles <- geneDropReference(
    ids = ped$id, sires = ped$sire, dams = ped$dam,
    gen = ped$gen, genotype = genotype, n = guIter,
    updateProgress = updateProgress
  )

  notifyProgress(
    updateProgress,
    detail = "Calculating Genome Uniqueness", value = 1L, reset = TRUE
  )

  # Calculate genome uniqueness and order the rows of the returned data.frame
  gu <- calcGUReference(alleles, threshold = guThresh, byID = byID, pop = probands)
  gu <- gu[probands, , drop = FALSE]

  # Issue #2 Slice 1: the per-animal Monte Carlo sampling standard error of the
  # gu estimate, computed from the same rare matrix calcGU() averages (so it is
  # correct for any guThresh / byID). Carried alongside gu into both the report
  # and the returned $gu element. (calcGUSE recomputes the rare matrix today;
  # factoring it out of calcA so gu and guSE share one build is Slice 2's job.)
  guSE <- calcGUSEReference(alleles, threshold = guThresh, byID = byID, pop = probands)
  guSE <- guSE[probands, , drop = FALSE]

  notifyProgress(
    updateProgress,
    detail = "Calculating Numbers of Offspring", value = 1L, reset = TRUE
  )

  # Get a data.frame of offspring counts for the probands
  offspring <- offspringCounts(probands, ped, considerPop = TRUE)

  includeCols <- intersect(getIncludeColumns(), names(ped))

  # Subsetting out the needed demographic information from the pedigree.
  # sire and dam are included so the report shows which animals have unknown
  # (U-id) parents (issue #9 / S3). They are always present because kinship()
  # above requires ped$sire and ped$dam.
  rownames(ped) <- ped$id
  demographics <- ped[probands, c(includeCols, "sire", "dam")]

  notifyProgress(
    updateProgress,
    detail = "Calculating Founder Equivalents", value = 1L, reset = TRUE
  )

  # S975 (BACKLOG.md:139): founder genome equivalents come from a gene drop that
  # ignores the genotypes. A genotyped animal starts from its own real alleles,
  # so a founder whose only descendants are genotyped passes no simulated allele
  # on, is retained in 0 iterations, and FG, fgSE and neGD were NA. The drop
  # above (which gu uses) is that drop when no animal has a code; otherwise a
  # second, silent one is made after it, so gu keeps its random numbers.
  hasCodes <- !is.null(genotype) &&
    any(!is.na(genotype$first) | !is.na(genotype$second))
  founderAlleles <- if (hasCodes) {
    geneDropReference(
      ids = ped$id, sires = ped$sire, dams = ped$dam,
      gen = ped$gen, genotype = NULL, n = guIter,
      updateProgress = NULL
    )
  } else {
    alleles
  }

  # Calculating founder equivalents and founder genome equivalents
  feFg <- calcFEFGReference(ped, founderAlleles)

  # Issue #82 Slice 3: the Monte Carlo sampling standard error of the founder
  # genome equivalents (FG), computed from the SAME gene drop that produces fg
  # (as guSE reuses gu's alleles). FG is a colony-level scalar, so fgSE is one
  # number that rides next to fg -- it is NOT a per-animal report column. NA
  # (with a warning) when a contributing founder is retained in zero iterations,
  # the same degeneracy calcFEFG reports for FG itself.
  fgSE <- calcFGSEReference(ped, founderAlleles)

  # Calculating known founders
  founders <- ped[isFounder(ped), ]
  males <- founders[(founders$sex == sexCodes[["male"]]) &
    !isGeneratedUnknownId(founders$id, ped = ped), ]
  females <- founders[(founders$sex == sexCodes[["female"]]) &
    !isGeneratedUnknownId(founders$id, ped = ped), ]

  # Issue #9 Slice 3: classify each proband's parentage (U-id aware) so the
  # report can flag both-unknown founders and the displayed rank can demote
  # those lacking a recorded origin. Both-known and one-unknown animals rank
  # normally; kinship() is untouched.
  parentage <- classifyParentage(demographics$sire, demographics$dam,
                                 ped = ped)

  # Issue #76 (Reading A): decline to credit genome uniqueness whose apparent
  # rarity is an artifact of unknown parentage. Both-unknown animals (U-id
  # aware, via parentage above) that lack a recorded origin -- the
  # "Undetermined" / noParentage set orderReport() demotes -- have both
  # gene-drop alleles minted from unknown-parent phantom founders, so their
  # reported genome uniqueness is set to 0. Imports (both-unknown WITH a
  # recorded origin) and all known / one-unknown animals are preserved.
  # calcGU() itself is unchanged; this is a report-layer colony policy.
  # Mutating gu here updates BOTH the report's gu column (via the cbind below)
  # and the returned $gu element.
  origin <- if ("origin" %in% names(demographics)) {
    demographics$origin
  } else {
    rep(NA_character_, nrow(demographics))
  }
  undetermined <- parentage == "both unknown" & is.na(origin)
  gu$gu[undetermined] <- 0.0
  # The de-inflated gu is a policy constant (issue #76), not a Monte Carlo
  # estimate, so its sampling standard error is identically 0.
  guSE$guSE[undetermined] <- 0.0

  finalData <- cbind(
    demographics, indivMeanKin, zScores, gu, guSE, offspring, parentage,
    flagged
  )
  finalData <- list(
    report = orderReport(finalData, ped,
                         guCutoff = guCutoff, zScoreCutoff = zScoreCutoff,
                         axisPriority = axisPriority),
    kinship = kmat,
    gu = cbind(gu, guSE),
    fe = feFg$FE,
    fg = feFg$FG,
    fgSE = fgSE,
    # Issue #118 Slice 1 (E1): gene diversity retained in the founding gene
    # pool, GD = 1 - 1/(2*FG), a deterministic colony-level scalar riding beside
    # fg (same analysis-set population as FG). NA propagates from a degenerate
    # (NA) FG.
    neGD = calcGeneDiversity(feFg$FG),
    # Issue #118 Slice 2 (E2): demographic sex-ratio effective size,
    # 4*nMale*nFemale/(nMale+nFemale), over the CURRENT LIVING BREEDERS in ped
    # -- a different population than fg/neGD (the analysis set). Deterministic
    # (no gene drop); 0 when a breeding sex is absent (see calcNeSexRatio).
    neSexRatio = calcNeSexRatio(ped),
    # Issue #118 Slice 3 (E3): variance effective size, the mean-adjusted
    # Crow-Kimura form (N*kbar - 1)/(kbar - 1 + Vk/kbar), over the SAME current
    # living breeders (all sexes). Deterministic; NA when fewer than 2 living
    # breeders (see calcNeVariance).
    neVariance = calcNeVariance(ped),
    maleFounders = males,
    femaleFounders = females,
    nMaleFounders = nrow(males),
    nFemaleFounders = nrow(females),
    total = (nrow(males) + nrow(females))
  )
  class(finalData) <- append(class(finalData), "nprcgenekeeprGV")

  finalData
}

## Phase 2 (the gene drop): R/geneDrop.R at 520bd5dc8. It calls the live
## hasInvalidIdChar(), toCharacter(), notifyProgress(), assignAlleles() and
## getGenoDefinedParentGenotypes(), which Phase 2 does not change.
geneDropReference <- function(ids, sires, dams, gen, genotype = NULL, n = 1000L,
                     updateProgress = NULL) {
  badIds <- hasInvalidIdChar(as.character(ids))
  if (any(badIds)) {
    stop("geneDrop(): animal IDs must not contain a period ('.'); ",
         "offending id(s): ", toString(unique(as.character(ids)[badIds])))
  }
  dupIds <- duplicated(as.character(ids))
  if (any(dupIds)) {
    stop("geneDrop(): animal IDs must be unique; ",
         "duplicated id(s): ", toString(unique(as.character(ids)[dupIds])))
  }
  ## Sort the IDs by generation so older generations are first
  ped <- data.frame(
    id = ids, sire = sires, dam = dams, gen,
    stringsAsFactors = FALSE
  )
  ped <- toCharacter(ped, headers = c("id", "sire", "dam"))
  rownames(ped) <- ids
  ped <- ped[order(gen), ]
  if (!is.null(genotype)) {
    genotype <- genotype[!(is.na(genotype$first) & is.na(genotype$second)), ]
    genoDefined <- TRUE
  } else {
    genoDefined <- FALSE
  }

  alleles <- list(alleles = list(), counter = 1L)

  notifyProgress(
    updateProgress,
    detail = "Performing Gene-drop Simulation", value = 0L, reset = TRUE
  )

  ## Iterate through each ID and get the maternal and paternal alleles
  for (id in ped$id) {
    alleles$alleles[[id]] <- list()
    sire <- ped[id, "sire"]
    dam <- ped[id, "dam"]
    assigned <- FALSE
    if (genoDefined && any(genotype$id == id)) {
      alleles <- getGenoDefinedParentGenotypes(alleles, genotype, id, sire,
                                               dam, n)
      assigned <- TRUE
    }
    if (!assigned) {
      alleles <- assignAlleles(alleles, "sire", sire, id, n)
      alleles <- assignAlleles(alleles, "dam", dam, id, n)
    }

    notifyProgress(updateProgress, n = nrow(ped))
  }

  # Convert the list of alleles to a data.frame
  alleles <- as.data.frame(t(data.frame(alleles$alleles, check.names = FALSE)))
  keys <- strsplit(rownames(alleles), ".", fixed = TRUE)

  id <- character(0L)
  parent <- character(0L)
  for (i in seq_along(keys)) {
    key <- keys[[i]]
    id <- c(id, key[1L])
    parent <- c(parent, key[2L])
  }

  alleles$id <- id
  alleles$parent <- parent
  rownames(alleles) <- seq_len(nrow(alleles))
  alleles
}

## Phase 3 (the relationship table): R/convertRelationships.R at 520bd5dc8. It
## calls the live filterKinMatrix(), makeCEPH(), allTrueNoNA(), isEmpty(),
## relationClassNames and notifyProgress(), which Phase 3 does not change; its
## kinMatrix2LongForm() call is pointed at kinMatrix2LongFormReference(), since
## Phase 6 changes that function.
convertRelationshipsReference <- function(kmat, ped, ids = NULL, updateProgress = NULL) {
  if (!is.null(ids)) {
    kmat <- filterKinMatrix(ids, kmat)
  }
  # No id of `ids` is in `kmat`: a matrix with no cells has no pairs to name.
  if (length(kmat) == 0L) {
    return(data.frame(
      id1 = character(0L), id2 = character(0L), kinship = numeric(0L),
      relation = character(0L), stringsAsFactors = FALSE
    ))
  }
  kin <- kinMatrix2LongFormReference(kmat, removeDups = TRUE)
  ped <- makeCEPH(ped$id, ped$sire, ped$dam)
  r <- character(0L)

  for (i in seq_len(nrow(kin))) {
    id1 <- kin$id1[i]
    id2 <- kin$id2[i]

    ceph1 <- ped[[id1]]
    ceph2 <- ped[[id2]]

    if (id1 == id2) {
      relation <- relationClassNames[["self"]]
    } else if (allTrueNoNA(ceph1$parents == ceph2$parents)) {
      relation <- relationClassNames[["fullSiblings"]]
    } else if (id1 %in% ceph2$parents || id2 %in% ceph1$parents) {
      # one animal is the parent of the other
      relation <- relationClassNames[["parentOffspring"]]
    } else if (!isEmpty(intersect(ceph1$parents, ceph2$parents))) {
      # at least 1 parent is shared
      relation <- relationClassNames[["halfSiblings"]]
    } else if (id1 %in% c(ceph2$pgp, ceph2$mgp) ||
      id2 %in% c(ceph1$pgp, ceph1$mgp)) {
      # one animals is the grandparent of the other
      relation <- relationClassNames[["grandparentGrandchild"]]
    } else if (allTrueNoNA(ceph1$pgp == ceph2$pgp) ||
      allTrueNoNA(ceph1$pgp == ceph2$mgp) ||
      allTrueNoNA(ceph1$mgp == ceph2$pgp) ||
      allTrueNoNA(ceph1$mgp == ceph2$mgp)) {
      # When a full set of grandparents are shared
      relation <- relationClassNames[["fullCousins"]]
    } else if (!isEmpty(intersect(
      c(ceph1$pgp, ceph1$mgp),
      c(ceph2$pgp, ceph2$mgp)
    ))) {
      # When at least one grandparent is in common
      relation <- relationClassNames[["cousinOther"]]
    } else if (allTrueNoNA(ceph1$parents == ceph2$pgp) ||
      allTrueNoNA(ceph1$parents == ceph2$mgp) ||
      allTrueNoNA(ceph2$parents == ceph1$pgp) ||
      allTrueNoNA(ceph2$parents == ceph1$mgp)) {
      # When parents of one proband are the grandparents of the other
      relation <- relationClassNames[["fullAvuncular"]]
    } else if (!isEmpty(intersect(ceph1$parents, c(ceph2$pgp, ceph2$mgp))) ||
      !isEmpty(intersect(ceph2$parents, c(ceph1$pgp, ceph1$mgp)))) {
      # When at least one parent of a proband is the grandparent of the other
      relation <- relationClassNames[["avuncularOther"]]
    } else if (kin$kinship[i] > 0L) {
      relation <- relationClassNames[["other"]]
    } else {
      relation <- relationClassNames[["noRelation"]]
    }

    r <- c(r, relation)

    notifyProgress(updateProgress)
  }
  kin["relation"] <- r
  kin
}

## Phase 4 (group formation): R/fillGroupMembers.R at 520bd5dc8, its
## fillGroupMembersWithSexRatio() call pointed at
## fillGroupMembersWithSexRatioReference(). It calls the live
## makeGroupMembers(), makeGroupNum(), removePotentialSires(), makeAvailable(),
## removeGroupIfNoAvailableAnimals(),
## removeSelectedAnimalFromAvailableAnimals() and isEmpty(), which Phase 4
## does not change.
fillGroupMembersReference <- function(candidates,
                                      currentGroups,
                                      kin,
                                      ped,
                                      harem,
                                      minAge,
                                      numGp,
                                      sexRatio) {
  groupMembers <- makeGroupMembers(
    numGp, currentGroups, candidates, ped,
    harem, minAge
  )
  grpNum <- makeGroupNum(numGp)

  if (harem) {
    # Sires were added to groupMembers
    candidates <- removePotentialSires(candidates, minAge, ped)
  }
  if (sexRatio != 0.0) {
    groupMembers <- fillGroupMembersWithSexRatioReference(
      candidates,
      groupMembers,
      grpNum,
      kin,
      ped,
      minAge,
      numGp,
      sexRatio
    )
    return(groupMembers)
  }
  available <- makeAvailable(candidates, numGp)

  # Whoever is already in a group (a harem's sampled sire, a supplied seed
  # animal) keeps his relatives out of that group's pool, as an animal the
  # loop places does below; a group left with no pool is finished. `[`, not
  # `[[`: a member with no relatives is absent from `kin` and gives nothing.
  for (i in seq_len(numGp)) {
    available[[i]] <- setdiff(available[[i]], unlist(kin[groupMembers[[i]]]))
  }
  grpNum <- removeGroupIfNoAvailableAnimals(grpNum, available)

  repeat {
    if (isEmpty(grpNum)) {
      break
    }

    # Select a group at random
    i <- sample(grpNum, 1L)[[1L]]

    # Select an animal that can be added to this group and add it
    id <- sample(available[[i]], 1L)
    groupMembers[[i]] <- c(groupMembers[[i]], id)
    available <-
      removeSelectedAnimalFromAvailableAnimals(available, id, numGp)

    # Remove all relatives from consideration for the group it was added to
    available[[i]] <- setdiff(available[[i]], kin[[id]])
    grpNum <- removeGroupIfNoAvailableAnimals(grpNum, available)
  }
  groupMembers
}

## Phase 4 (group formation): R/fillGroupMembersWithSexRatio.R at 520bd5dc8. It
## calls the live getPotentialSires(), makeAvailable(), calculateSexRatio(),
## removeSelectedAnimalFromAvailableAnimals(),
## removeGroupIfNoAvailableAnimals(), isEmpty() and sexCodes, which Phase 4
## does not change.
fillGroupMembersWithSexRatioReference <-
  function(candidates, groupMembers, grpNum, kin, ped, minAge, numGp,
           sexRatio) {
    potentialSires <- getPotentialSires(candidates, ped, minAge)
    # A male who is not a potential sire (under minAge, or with no birth date)
    # is placed nowhere: calculateSexRatio() counts every male as a male, so he
    # must not fill the female pool.
    males <- ped$id[ped$sex %in% sexCodes[["male"]]]
    availableMales <- makeAvailable(potentialSires, numGp)
    availableFemales <- makeAvailable(setdiff(candidates, males), numGp)

    repeat {
      if (isEmpty(grpNum)) {
        break
      }

      # Select a group at random
      i <- sample(grpNum, 1L)[[1L]]

      # Select an animal that can be added to this group and add it
      ratio <- calculateSexRatio(groupMembers[[i]], ped)
      if (is.na(ratio)) {
        ratio <- 0.0
      } ## no seed animals

      if (ratio < sexRatio) { ## need female
        id <- sample(availableFemales[[i]], 1L)
        availableFemales <-
          removeSelectedAnimalFromAvailableAnimals(availableFemales, id, numGp)
      } else if (abs(sexRatio - calculateSexRatio(groupMembers[[i]], ped,
        additionalMales = 1L
      )) <
        abs(sexRatio - calculateSexRatio(groupMembers[[i]], ped,
          additionalFemales = 1L
        ))) { # may need male
        id <- sample(availableMales[[i]], 1L)
        availableMales <-
          removeSelectedAnimalFromAvailableAnimals(availableMales, id, numGp)
      } else {
        id <- sample(availableFemales[[i]], 1L)
        availableFemales <-
          removeSelectedAnimalFromAvailableAnimals(availableFemales, id,
                                                   numGp)
      }
      groupMembers[[i]] <- c(groupMembers[[i]], id)
      # Remove all relatives from consideration for the group it was added to
      availableMales[[i]] <- setdiff(availableMales[[i]], kin[[id]])
      availableFemales[[i]] <- setdiff(availableFemales[[i]], kin[[id]])
      grpNum <- removeGroupIfNoAvailableAnimals(grpNum, availableMales)
      grpNum <- removeGroupIfNoAvailableAnimals(grpNum, availableFemales)
    }
    groupMembers
  }

## Phase 4 (group formation): groupAddAssign() itself does not change, so its
## result from today's code is groupAddAssign() with fillGroupMembers() swapped
## for the frozen copy above (which calls the frozen sex-ratio copy). Phase 6
## swaps its getAnimalsWithHighKinship() for the frozen copy below as well.
groupAddAssignReference <- function(...) {
  testthat::with_mocked_bindings(
    groupAddAssign(...),
    fillGroupMembers = fillGroupMembersReference,
    getAnimalsWithHighKinship = getAnimalsWithHighKinshipReference,
    .package = "nprcgenekeepr"
  )
}

## Phase 5 (founder statistics): R/calcFounderContributions.R,
## R/calcRetention.R, R/calcFE.R, R/calcFG.R, R/calcFEFG.R and R/calcFGSE.R at
## 520bd5dc8, their calls to each other pointed at these copies. They call the
## live toCharacter(), getFounders() and checkFgDegeneracy(), which Phase 5
## does not change.
calcFounderContributionsReference <- function(ped, caller = "calcFEFG") {
  ped <- toCharacter(ped, headers = c("id", "sire", "dam"))
  partial <- xor(is.na(ped$sire), is.na(ped$dam))
  if (any(partial)) {
    stop(caller, " requires complete parentage (no partial parentage): ",
         "id(s) with exactly one known parent: ", toString(ped$id[partial]),
         ". Resolve partial parentage upstream ",
         "(e.g., qcStudbook() or addUIds()) before calling ", caller, "().")
  }
  founders <- getFounders(ped)
  descendants <- ped$id[!(ped$id %in% founders)]

  d <- matrix(0L, nrow = length(descendants), ncol = length(founders))
  colnames(d) <- founders
  rownames(d) <- descendants

  founderMatrix <- diag(length(founders))
  colnames(founderMatrix) <- rownames(founderMatrix) <- founders

  d <- rbind(founderMatrix, d)
  ## Free the founders-by-founders identity block before the generation loop:
  ## it has been copied into d above and is never referenced again.
  founderMatrix <- NULL
  ## Note: skips generation 0.
  ## The references inside matrix d do not work if ped$sire and ped$dam and
  ## thus gen$sire and gen$dam are factors. See test_calcFE.R
  for (i in seq_len(max(ped$gen))) {
    gen <- ped[(ped$gen == i), ]

    for (j in seq_len(nrow(gen))) {
      ego <- gen$id[j]
      sire <- gen$sire[j]
      dam <- gen$dam[j]
      ## Mendelian 1/2: an individual's founder contributions are the mean of
      ## its two parents' (each parent transmits half of its genome).
      d[ego, ] <- (d[sire, ] + d[dam, ]) / 2L
    }
  }

  currentDesc <- ped$id[ped$population & !(ped$id %in% founders)]
  ## drop = FALSE keeps a single living descendant a one-row matrix (S925).
  d <- d[currentDesc, , drop = FALSE]
  p <- colMeans(d)

  list(p = p, ped = ped)
}

calcRetentionReference <- function(ped, alleles) {
  # ASSUME: Pedigree has no partial parentage
  founders <- getFounders(ped)
  descendants <- ped$id[ped$population & !(ped$id %in% founders)]

  founders <- alleles[(alleles$id %in% founders), c("id", "V1")]
  colnames(founders) <- c("id", "allele")

  alleles <- alleles[
    (alleles$id %in% descendants),
    !(colnames(alleles) %in% c("id", "parent"))
  ]

  retained <- apply(alleles, 2L, function(a) {
    founders$allele %in% a
  })
  retained <- rowSums(retained, na.rm = TRUE) / ncol(retained)
  founders <- cbind(founders, retained)

  founders <- tapply(founders$retained, founders$id, mean)
  founders
}

calcFEFGReference <- function(ped, alleles) {
  ## Founder-contribution algorithm + partial-parentage guard are shared with
  ## calcFE()/calcFG() via calcFounderContributions() (NEW-13/NEW-23). fc$ped is
  ## the toCharacter()-coerced pedigree, fed to calcRetention() exactly as the
  ## pre-refactor code did.
  fc <- calcFounderContributionsReference(ped, "calcFEFG") # nolint: object_usage_linter
  r <- calcRetentionReference(fc$ped, alleles)
  ## Align retention to contributions by NAME before dividing (issue #86,
  ## Dragon D-3): r is id-sorted while fc$p is in getFounders() pedigree-row
  ## order, so a positional p^2 / r yields a silently wrong FG on any
  ## unsorted-founder pedigree. FE (1 / sum(p^2)) has no retention term and is
  ## unaffected by the ordering.
  r <- r[names(fc$p)]
  fe <- 1L / sum(fc$p^2L)
  ## FE is deterministic and always returned; FG hard-fails (NA + warning)
  ## on the same zero-retention silent collapse calcFG guards against.
  if (checkFgDegeneracy(fc$p, r)) {
    return(list(FE = fe, FG = NA_real_))
  }
  list(FE = fe, FG = 1L / sum((fc$p^2L) / r, na.rm = TRUE))
}

calcFGSEReference <- function(ped, alleles) {
  ## Founder contributions (deterministic) and the toCharacter()-coerced
  ## pedigree, shared with calcFG()/calcFEFG() via calcFounderContributions().
  fc <- calcFounderContributionsReference(ped, "calcFG")
  pedc <- fc$ped
  founders <- getFounders(pedc)
  descendants <- pedc$id[pedc$population & !(pedc$id %in% founders)]

  ## Rebuild the per-iteration retention matrix calcRetention() averages: for
  ## each founder allele copy, a 0/1 indicator of presence among the descendant
  ## alleles in each iteration column.
  founderAlleles <- alleles[alleles$id %in% founders, c("id", "V1")]
  colnames(founderAlleles) <- c("id", "allele")
  descAlleles <- alleles[
    alleles$id %in% descendants,
    !(colnames(alleles) %in% c("id", "parent"))
  ]
  retained <- apply(descAlleles, 2L, function(a) founderAlleles$allele %in% a)
  storage.mode(retained) <- "numeric"
  ## Collapse the two copies per founder: F x K matrix in {0, 0.5, 1}; its row
  ## means equal calcRetention() and its rows are founder-id-sorted.
  retentionMatrix <- rowsum(retained, founderAlleles$id) / 2L
  rhat <- rowMeans(retentionMatrix)
  p <- fc$p[names(rhat)] # align contributions to retention rows by NAME
  k <- ncol(retentionMatrix)

  ## Hard-fail: a contributing founder retained in zero drops leaves FG
  ## (and its gradient) undefined -- return NA rather than a finite SE for
  ## a collapsed FG.
  if (checkFgDegeneracy(p, rhat)) {
    return(NA_real_)
  }

  ## Drop non-contributing (p == 0 -> 0/0) and any missing-retention founders so
  ## the SE refers to the same founder set as FG.
  keep <- !is.na(rhat) & rhat > 0L & !is.na(p)
  fg <- 1L / sum((p[keep]^2L) / rhat[keep])
  gradient <- numeric(length(rhat))
  gradient[keep] <- fg^2L * (p[keep]^2L) / (rhat[keep]^2L)
  influence <- as.numeric(crossprod(gradient, retentionMatrix)) # length K
  stats::sd(influence) / sqrt(k)
}

calcFEReference <- function(ped) {
  ## Founder-contribution algorithm + partial-parentage guard are shared with
  ## calcFG()/calcFEFG() via calcFounderContributions() (NEW-13/NEW-23).
  1L / sum(calcFounderContributionsReference(ped, "calcFE")$p^2L) # nolint: object_usage_linter
}

calcFGReference <- function(ped, alleles) {
  ## Founder-contribution algorithm + partial-parentage guard are shared with
  ## calcFE()/calcFEFG() via calcFounderContributions() (NEW-13/NEW-23). fc$ped
  ## is the toCharacter()-coerced pedigree, fed to calcRetention() as before.
  fc <- calcFounderContributionsReference(ped, "calcFG") # nolint: object_usage_linter
  r <- calcRetentionReference(fc$ped, alleles)
  ## Align retention to contributions by NAME before dividing (issue #86,
  ## Dragon D-3): calcRetention() returns r id-sorted (tapply) while fc$p is in
  ## getFounders() pedigree-row order, so a positional p^2 / r pairs the wrong
  ## founders -- a silently wrong FG (e.g. a collapse to 0) on any pedigree
  ## whose founders are not already in sorted id order.
  r <- r[names(fc$p)]
  ## Hard-fail (NA + warning) the silent FG collapse when a contributing founder
  ## is retained in zero drops; the point estimate is unchanged otherwise.
  if (checkFgDegeneracy(fc$p, r)) {
    return(NA_real_)
  }
  1L / sum((fc$p^2L) / r, na.rm = TRUE)
}

## Phase 6 (kinship memory): R/kinship.R, R/kinMatrix2LongForm.R and
## R/getAnimalsWithHighKinship.R at 520bd5dc8, getAnimalsWithHighKinship()'s
## kinMatrix2LongForm() call pointed at kinMatrix2LongFormReference(). They
## call the live sexCodes, filterThreshold(), filterPairs() and filterAge(),
## which Phase 6 does not change.
kinshipReference <- function(id, father.id, mother.id, pdepth, sparse = FALSE, # nolint: object_name_linter
                              twinRelations = NULL, chrtype = "autosome", sex = NULL) {
  # Returns: Matrix (row and col names are 'id')
  n <- length(id)
  if (anyDuplicated(id)) {
    stop("All id values must be unique")
  }
  chrtype <- match.arg(casefold(chrtype), c("autosome", "x"))

  # id number "n + 1" is a placeholder for missing parents
  mrow <- match(mother.id, id, nomatch = n + 1L) # row number of the mother
  drow <- match(father.id, id, nomatch = n + 1L) # row number of the dad

  if (chrtype == "x") {
    if (is.null(sex) || length(sex) != n) {
      stop("invalid sex vector")
    }
    ## X-linked founder self-kinship: males are hemizygous (a single X copy,
    ## so self-kinship = 1); females follow the usual non-inbred 0.5. Unknown
    ## sex gets NA. The "n + 1" placeholder row/col (missing-parent stand-in)
    ## is appended as 0, matching the autosomal branch's own placeholder
    ## treatment below.
    sexNum <- c(1L, 2L)[match(sex, c(sexCodes[["male"]], sexCodes[["female"]]))] # nolint: object_name_linter
    founderDiag <- ifelse(is.na(sexNum), NA_real_, (3L - sexNum) / 2L) # nolint: object_name_linter
    if (sparse) {
      kmat <- Diagonal(x = c(founderDiag, 0.0))
    } else {
      kmat <- diag(c(founderDiag, 0.0))
    }
  } else {
    ## Mendelian 1/2: a non-inbred animal's self-kinship is 1/2, so kmat
    ## starts as one-half of the identity matrix (each founder's self-kinship
    ## is 0.5).
    if (sparse) {
      kmat <- Diagonal(n + 1L) / 2L
    } else {
      kmat <- diag(n + 1L) / 2L
    }

    kmat[n + 1L, n + 1L] <- 0L # if A and B both have "unknown" dad, this
    # ensures that they won't end up 'related' in the matrix
  }

  ## MZ-twin transitive-identity correction (ported from kinship2's own
  ## mzgrp/mzindex mechanism -- see
  ## docs/planning/twin-relations-kinship-computation-plan.md §2.1). Built
  ## once, up front: mzgrp is a union-find grouping of chained MZ
  ## declarations (A-B, B-C => {A,B,C} one group) and mzindex expands each
  ## group to every ordered off-diagonal pair within it -- the matrix cells
  ## the depth loop below must overwrite. Applying this inside the depth
  ## loop (not as a post-hoc pass on the finished matrix) is required for
  ## the correction to propagate to relatives computed at a later depth --
  ## see the plan's §2.2 for the mathematical argument.
  havemz <- FALSE
  if (!is.null(twinRelations)) {
    mzRows <- twinRelations[twinRelations$code == "MZ twin", , drop = FALSE]
    if (nrow(mzRows) > 0L) {
      mzId1 <- match(mzRows$id1, id)
      mzId2 <- match(mzRows$id2, id)
      if (anyNA(c(mzId1, mzId2))) {
        # nolint start: nonportable_path_linter.
        stop("All twinRelations id1/id2 values must be present in id.")
        # nolint end: nonportable_path_linter.
      }
      havemz <- TRUE
      mzmat <- cbind(mzId1, mzId2)
      mzgrp <- seq_len(max(mzmat))
      repeat {
        if (all(mzgrp[mzmat[, 1L]] == mzgrp[mzmat[, 2L]])) {
          break
        }
        for (i in seq_len(nrow(mzmat))) {
          mzgrp[mzmat[i, 1L]] <- mzgrp[mzmat[i, 2L]] <- min(mzgrp[mzmat[i, ]])
        }
      }
      mzindex <- cbind(
        unlist(tapply(mzmat, mzgrp[mzmat], function(x) {
          z <- unique(x)
          rep(z, length(z))
        })),
        unlist(tapply(mzmat, mzgrp[mzmat], function(x) {
          z <- unique(x)
          rep(z, each = length(z))
        }))
      )
      mzindex <- mzindex[mzindex[, 1L] != mzindex[, 2L], , drop = FALSE]
    }
  }

  # Those at depth == 0 don't need to be processed
  # Subjects with depth = i must be processed before those at depth i + 1.
  # Any parent is guarranteed to be at a lower depth than their children
  #  The inner loop on "i" can NOT be replaced with a vectorized expression:
  # sibs' effect on each other is cumulative.
  for (depth in 1L:max(pdepth, na.rm = TRUE)) {
    indx <- (1L:n)[pdepth == depth]
    for (i in indx) {
      mom <- mrow[i]
      dad <- drow[i]
      if (chrtype == "x" && !is.na(sexNum[i]) && sexNum[i] == 1L) {
        ## Male: X comes from the mother only.
        kmat[i, ] <- kmat[, i] <- kmat[mom, ]
        kmat[i, i] <- 1L
      } else if (chrtype == "x" && is.na(sexNum[i])) {
        ## Unknown sex: no defensible X-linked value.
        kmat[i, ] <- kmat[, i] <- NA
        kmat[i, i] <- NA
      } else {
        ## Autosomal, or X-linked female (same average-of-parents formula).
        ## Mendelian 1/2: i's kinship with any j is the average of its two
        ## parents' kinships with j; i's self-kinship is half of one plus its
        ## own inbreeding coefficient (the kinship between its two parents).
        kmat[i, ] <- kmat[, i] <- (kmat[mom, ] + kmat[dad, ]) / 2L
        kmat[i, i] <- (1L + kmat[mom, dad]) / 2L
      }
    }
    if (havemz) {
      kmat[mzindex] <- (diag(kmat))[mzindex[, 1L]]
    }
  }

  ## drop = FALSE keeps a single animal a 1 x 1 matrix (S925).
  kmat <- kmat[1L:n, 1L:n, drop = FALSE]
  dimnames(kmat) <- list(id, id)
  kmat
}

kinMatrix2LongFormReference <- function(kinMatrix, removeDups = FALSE) {
  if (removeDups) {
    kinMatrix[upper.tri(kinMatrix)] <- NA
  }

  kmat <- as.data.frame(kinMatrix)
  k <- stack(kmat)
  k["id2"] <- row.names(kmat)

  colnames(k) <- c("kinship", "id1", "id2")
  k$id1 <- as.character(k$id1)

  k <- k[!is.na(k$kinship), ]

  k[, c("id1", "id2", "kinship")]
}

getAnimalsWithHighKinshipReference <- function(kmat, ped, threshold,
                                               currentGroups, ignore, minAge) {
  kin <- kinMatrix2LongFormReference(kmat)

  kin <- filterThreshold(kin, threshold = threshold)
  kin <- filterPairs(kin, ped, ignore = ignore)
  kin <- filterAge(kin, ped, minAge = minAge)

  # Filter out self kinships
  kin <- kin[(kin$id1 != kin$id2), ]

  # Ignore kinship between current group members
  kin <- kin[!((kin$id1 %in% unlist(currentGroups)) &
    (kin$id2 %in% unlist(currentGroups))), ]

  # Converting the kinships to a list
  kin <- tapply(kin$id2, kin$id1, c)
  kin
}

## Phase 7 (the diagram's solver): .solveJointQP() from
## R/makePedigreeDiagramData.R at 520bd5dc8. It calls the live
## .nonAnchorNodeResolver() and quadprog::solve.QP(), which Phase 7 does not
## change; only the copy's name and its signature's line breaks differ.
solveJointQPReference <- function(provisionalPos, matingUnits, duplicates,
                                  childEdges, wSpouse = 2.0, alignChild = 1.5,
                                  wUnion = 2.0, wDup = 1.0, minSep = 1.0) {
  ids <- provisionalPos$id
  n <- length(ids)
  varIndex <- stats::setNames(seq_len(n), ids)
  isUnion <- ids %in% matingUnits$id
  kind <- stats::setNames(ifelse(isUnion, "union", "individual"), ids)

  ## Decision 3 as AMENDED S675 (Migration Path Phase 3, owner-ratified via
  ## AskUserQuestion after seeing the real 375-fixture render): the floors
  ## are SPACING values keyed to the engine's own minSep (1 raw unit = 120
  ## px -- .positionMatingUnitForest()'s Tier-1 spacing and kinship2's own
  ## uniform alignped4 floor), NOT the render-layer symbol-tangent
  ## clearances the design originally repurposed ((25+25)/120, (25+6)/120,
  ## (6+6)/120 -- still what .resolveEdgeNodeCollisions() uses, for what
  ## they are: collision thresholds). Under the tangent floors the
  ## objective compressed 684 of the real fixture's 705 adjacent pairs to
  ## exactly the floor -- symbols touching, labels overlapping into a band
  ## -- and the census's class (a) read 90 sub-microscopic (<= 1.3e-6 px)
  ## solver shortfalls at its 1e-9 px epsilon. Individual-individual =
  ## minSep; individual-union = minSep / 2 (the S666 qualifying-pair
  ## geometry: mates 1.0 apart, dot centred); union-union = minSep / 4.
  floorIndividualIndividual <- minSep
  floorIndividualUnion <- minSep / 2.0
  floorUnionUnion <- minSep / 4.0
  minSepFor <- function(k1, k2) {
    if (k1 == "union" && k2 == "union") return(floorUnionUnion)
    if (k1 == "union" || k2 == "union") return(floorIndividualUnion)
    floorIndividualIndividual
  }

  amatCols <- list()
  bvec <- numeric(0L)
  for (g in sort(unique(provisionalPos$gen))) {
    rowIds <- ids[provisionalPos$gen == g]
    if (length(rowIds) < 2L) next
    rowX <- provisionalPos$x[match(rowIds, ids)]
    rowIds <- rowIds[order(rowX, rowIds, method = "radix")]
    for (i in seq_len(length(rowIds) - 1L)) {
      a <- rowIds[i]
      b <- rowIds[i + 1L]
      col <- numeric(n)
      col[[varIndex[[b]]]] <- 1.0
      col[[varIndex[[a]]]] <- -1.0
      amatCols[[length(amatCols) + 1L]] <- col
      bvec <- c(bvec, minSepFor(kind[[a]], kind[[b]]))
    }
  }
  Amat <- if (length(amatCols) > 0L) {
    do.call(cbind, amatCols)
  } else {
    matrix(numeric(0L), nrow = n, ncol = 0L)
  }

  ## Decision 4: objective. e(id) is the unit basis vector at id's own
  ## column; pmatRows accumulates one row per penalty term, squared later
  ## via t(pmat) %*% pmat (kinship2's alignped4 builds its own pmat the
  ## same way).
  e <- function(id) {
    v <- numeric(n)
    v[[varIndex[[id]]]] <- 1.0
    v
  }
  resolveNnode <- .nonAnchorNodeResolver(duplicates)
  anchoredUnits <- matingUnits[!is.na(matingUnits$anchor), , drop = FALSE]
  pmatRows <- list()
  for (i in seq_len(nrow(anchoredUnits))) {
    u <- anchoredUnits$id[i]
    anchor <- anchoredUnits$anchor[i]
    Nnode <- resolveNnode(anchoredUnits$nonAnchor[i], u)
    ## Migration Path Phase 2 fix (found live wiring this function into
    ## production): a dangling non-anchor's FREE (non-duplicated)
    ## occurrence has no rendered node at all (.buildMatingUnitForest()'s
    ## own contract) -- resolveNnode() then returns the dangling id
    ## itself, unresolved, outside this QP's own variable set. Generalizes
    ## the already-established orphan-unit exclusion (anchoredUnits itself
    ## already excludes anchor == NA) to "anchor OR Nnode has no rendered
    ## node": skip terms 1-3 for this unit entirely -- its children get no
    ## centering pull from this unit, matching the orphan-unit treatment.
    if (!(Nnode %in% ids)) next

    ## Term 1: spousal pull (kinship2's own align[2] term).
    pmatRows[[length(pmatRows) + 1L]] <-
      sqrt(wSpouse) * (e(anchor) - e(Nnode))

    ## Term 3 (NEW): union centering -- targets census Finding #1.
    pmatRows[[length(pmatRows) + 1L]] <-
      sqrt(wUnion) * (e(u) - 0.5 * e(anchor) - 0.5 * e(Nnode))

    ## Term 2: child centering (kinship2's own align[1] term) -- one row
    ## per real child, weighted by sibship size k^-alignChild.
    kids <- childEdges$to[childEdges$from == u]
    kids <- kids[kids %in% ids]
    k <- length(kids)
    if (k > 0L) {
      childWeight <- sqrt(k^(-alignChild))
      for (child in kids) {
        pmatRows[[length(pmatRows) + 1L]] <-
          childWeight * (e(child) - 0.5 * e(anchor) - 0.5 * e(Nnode))
      }
    }
  }

  ## Term 4 (NEW): duplicate proximity -- polygamy (B1) duplicates ONLY.
  ## kinship2 has no analogue (S670 report Sec. 3). S683 (the
  ## owner-ratified amendment to the S675 no-weight-tuning mandate; the
  ## wDup-on-spouse-duplicates BACKLOG item, design Open Question 2):
  ## a spouse (B2) duplicate -- one whose realId has its own place in
  ## the tree (an own parent edge, or an own single-parent direct
  ## child) -- contributes NO proximity row. Measured on the real 375
  ## fixture, the pull dragged each marry-in mate's __dup_* node (and
  ## its whole anchor--dot--mate triple) toward the mate's distant real
  ## occurrence, beating term 2's child centering (the owner-flagged
  ## ~950/1190 px P49ZD1 drop jogs), and CAUSED the census's one class-
  ## (d) dup-adjacent-to-real case rather than preventing it (d 1 -> 0,
  ## jogs 165 -> 95, c2 105 -> 29 under the skip). The curved duplicate
  ## connector, not proximity, links a spouse duplicate to its real
  ## occurrence -- exactly kinship2's own convention. The pull stays
  ## for polygamy (B1) duplicates, keeping one individual's occurrences
  ## near each other (test_solveJointQP.R's S683 boundary guard).
  ##
  ## B2-shape is derived from this component's own childEdges -- realId
  ## has an own parent edge (a childEdges$to entry) or is itself a
  ## single parent with a direct child edge (a non-union
  ## childEdges$from) -- the same structural test
  ## .buildMatingUnitForest()'s Decision-2 spouse duplication applies
  ## to 'ped' at mint time, re-expressed over the arguments this
  ## function actually receives (asserted identical over every dup
  ## realId of the real fixture, S683); deriving it here keeps the
  ## 'duplicates' argument contract unchanged for direct callers
  ## handing hand-built legacy shapes (Learning 736).
  if (nrow(duplicates) > 0L) {
    singleParents <- setdiff(childEdges$from, matingUnits$id)
    b2Set <- unique(c(childEdges$to, singleParents))
    for (i in seq_len(nrow(duplicates))) {
      dupId <- duplicates$id[i]
      realId <- duplicates$realId[i]
      ## Migration Path Phase 2 fix (companion to the dangling-non-anchor
      ## fix above): a duplicate whose own realId is a dangling parent's
      ## FREE occurrence has no rendered node to pull toward either --
      ## skip this duplicate's proximity term.
      if (!(realId %in% ids)) next
      ## S683: spouse (B2) duplicate -- no proximity row (see above).
      if (realId %in% b2Set) next
      pmatRows[[length(pmatRows) + 1L]] <-
        sqrt(wDup) * (e(dupId) - e(realId))
    }
  }

  ## Term 5: anti-degeneracy, breaking translation invariance (pmat alone
  ## has a 0 unconstrained minimum at "shift everything by the same
  ## constant") -- matches kinship2's own identical fix. Reference
  ## variable: the widest row's first node in provisional order (radix
  ## tie-break), an arbitrary but deterministic choice.
  genCounts <- table(provisionalPos$gen)
  widestGen <- as.numeric(names(genCounts))[which.max(genCounts)]
  widestRowIds <- ids[provisionalPos$gen == widestGen]
  widestRowX <- provisionalPos$x[match(widestRowIds, ids)]
  refId <- widestRowIds[order(widestRowX, widestRowIds, method = "radix")][1L]
  antiDeg <- numeric(n)
  antiDeg[[varIndex[[refId]]]] <- 1e-5
  pmatRows[[length(pmatRows) + 1L]] <- antiDeg

  pmat <- do.call(rbind, pmatRows)
  Dmat <- t(pmat) %*% pmat + 1e-8 * diag(n)

  fit <- quadprog::solve.QP(Dmat = Dmat, dvec = rep(0.0, n), Amat = Amat,
                             bvec = bvec, meq = 0L)

  data.frame(id = ids, x = fit$solution, gen = provisionalPos$gen,
             stringsAsFactors = FALSE)
}
