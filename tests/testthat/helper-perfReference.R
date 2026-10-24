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
  kmat <- filterKinMatrix(probands, kinship(
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
  feFg <- calcFEFG(ped, founderAlleles)

  # Issue #82 Slice 3: the Monte Carlo sampling standard error of the founder
  # genome equivalents (FG), computed from the SAME gene drop that produces fg
  # (as guSE reuses gu's alleles). FG is a colony-level scalar, so fgSE is one
  # number that rides next to fg -- it is NOT a per-animal report column. NA
  # (with a warning) when a contributing founder is retained in zero iterations,
  # the same degeneracy calcFEFG reports for FG itself.
  fgSE <- calcFGSE(ped, founderAlleles)

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
## calls the live filterKinMatrix(), kinMatrix2LongForm(), makeCEPH(),
## allTrueNoNA(), isEmpty(), relationClassNames and notifyProgress(), which
## Phase 3 does not change.
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
  kin <- kinMatrix2LongForm(kmat, removeDups = TRUE)
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
