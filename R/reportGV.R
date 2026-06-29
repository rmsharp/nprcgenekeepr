#' Generates a genetic value report for a provided pedigree
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#' This is the main function for the Genetic Value Analysis.
#'
#' Reported genome uniqueness (\code{gu}) is set to 0 for "Undetermined"
#' animals -- those with both parents unknown (U-id aware) and no recorded
#' origin -- because their apparent uniqueness is an artifact of unknown
#' parentage (decline-to-credit policy). Imports (both parents
#' unknown but with a recorded origin) and all other animals are unaffected,
#' and \code{\link{calcGU}} itself is unchanged.
#'
#' @return An object of class \code{nprcgenekeeprGV}: a list with elements
#' \code{report} (a dataframe with the genetic value report, with animals
#' ranked in order of descending value; it carries both a \code{gu} column and a
#' \code{guSE} column -- the Monte Carlo sampling standard error of each genome
#' uniqueness estimate, see \code{\link{calcGUSE}}), \code{kinship} (the kinship
#' matrix), \code{gu} (a dataframe with a \code{gu} column of genome uniqueness
#' values and a \code{guSE} column of their standard errors; \code{gu} and
#' \code{guSE} are reported as 0 for unknown-origin both-unknown "Undetermined"
#' animals, whose apparent uniqueness is an artifact of unknown parentage),
#' \code{fe} (founder equivalents),
#' \code{fg} (founder genome equivalents), \code{fgSE} (the Monte Carlo sampling
#' standard error of \code{fg}, computed from the same gene drop; a single
#' colony-level number, \code{NA} when a contributing founder is retained in
#' zero gene-drop iterations -- see \code{\link{calcFGSE}}), \code{maleFounders}
#' and
#' \code{femaleFounders} (dataframes of the known male and female founder
#' records), \code{nMaleFounders} and \code{nFemaleFounders} (the counts of
#' those founders), and \code{total} (the total number of known founders).
#'
#' @param ped The pedigree information in data.frame format
#' @param guIter Integer indicating the number of iterations for the gene-drop
#'  analysis. Default is 1000 iterations
#' @param guThresh Integer indicating the threshold number of animals for
#' defining a unique allele. Default considers an allele "unique"
#' if it is found in only 1 animal.
#' @param pop Character vector with animal IDs to consider as the population of
#' interest. The default is NULL.
#' @param byID Logical variable of length 1 that is passed through to
#' eventually be used by \code{alleleFreq()}, which calculates the count of each
#'  allele in the provided vector. If \code{byID} is TRUE and ids are provided,
#'  the function will only count the unique alleles for an individual
#'   (homozygous alleles will be counted as 1).
#' @param updateProgress Function or NULL. If this function is defined, it
#' will be called during each iteration to update a
#' \code{shiny::Progress} object.
#' @param breedingTable Optional data.frame overriding the bundled per-species
#' minimum breeding ages used by the unknown-parent mean-kinship correction.
#' \code{NULL} (the default) uses the bundled
#' \code{\link{speciesGestation}} table.
#' @param gestationTable Optional data.frame overriding the bundled per-species
#' gestation windows used by the correction's conception window. \code{NULL}
#' uses the bundled table.
#' @param breedingAgeDefault Optional numeric fallback minimum breeding age
#' (years) for species absent from the table. \code{NULL} uses the built-in
#' 2 years.
#' @param gestationDefault Optional integer fallback gestation window (days) for
#' species absent from the table. \code{NULL} uses the built-in 210 days.
#' @param kinshipOverrides Optional data.frame of outside-information kinship
#' overrides (\code{id1}, \code{id2}, \code{kinship}; the coefficient \emph{f},
#' not relatedness \emph{r}) applied to the kinship matrix before mean kinship
#' and the unknown-parent correction. \code{NULL} (the default)
#' leaves the pedigree-derived matrix unchanged. Ids outside the analysis
#' set are warn-dropped (the run is not aborted). An override REFINES the
#' named kinship cell; it does not suppress the \code{+ sexMean / 2}
#' unknown-parent correction, which is kept for every animal missing one
#' parent. See \code{\link{applyKinshipOverrides}}.
#' @export
#' @examples
#' library(nprcgenekeepr)
#' examplePedigree <- nprcgenekeepr::examplePedigree
#' breederPed <- qcStudbook(examplePedigree,
#'   minParentAge = 2,
#'   reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#' focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
#'   is.na(breederPed$dam)) &
#'   is.na(breederPed$exit)]
#' ped <- setPopulation(ped = breederPed, ids = focalAnimals)
#' trimmedPed <- trimPedigree(focalAnimals, breederPed)
#' probands <- ped$id[ped$population]
#' ped <- trimPedigree(probands, ped,
#'   removeUninformative = FALSE,
#'   addBackParents = FALSE
#' )
#' geneticValue <- reportGV(ped,
#'   guIter = 50, # should be >= 1000
#'   guThresh = 3,
#'   byID = TRUE,
#'   updateProgress = NULL
#' )
#' trimmedGeneticValue <- reportGV(trimmedPed,
#'   guIter = 50, # should be >= 1000
#'   guThresh = 3,
#'   byID = TRUE,
#'   updateProgress = NULL
#' )
#' rpt <- trimmedGeneticValue[["report"]]
#' kmat <- trimmedGeneticValue[["kinship"]]
#' f <- trimmedGeneticValue[["total"]]
#' mf <- trimmedGeneticValue[["maleFounders"]]
#' ff <- trimmedGeneticValue[["femaleFounders"]]
#' nmf <- trimmedGeneticValue[["nMaleFounders"]]
#' nff <- trimmedGeneticValue[["nFemaleFounders"]]
#' fe <- trimmedGeneticValue[["fe"]]
#' fg <- trimmedGeneticValue[["fg"]]
reportGV <- function(ped, guIter = 1000L, guThresh = 1L, pop = NULL,
                     byID = TRUE, updateProgress = NULL,
                     breedingTable = NULL, gestationTable = NULL,
                     breedingAgeDefault = NULL, gestationDefault = NULL,
                     kinshipOverrides = NULL) {
  # Generates a genetic value report for a provided pedigree

  ## If user has limited the population of interest by defining 'pop',
  ## that information is incorporated via the 'population' column.
  ped$population <- getGVPopulation(ped, pop)

  # Get the list of animals in the population to consider
  probands <- as.character(ped$id[ped$population])

  ## Extract genotype data if available otherwise NULL is returned.
  genotype <- getGVGenotype(ped)

  # Generate the kinship matrix and filter down to the animals of interest
  kmat <- filterKinMatrix(probands, kinship(
    ped$id, ped$sire, ped$dam,
    ped$gen
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
  indivMeanKin <-
    correctUnknownParentMeanKinship(indivMeanKin, ped,
      gestationTable = gestationTable,
      breedingTable = breedingTable,
      breedingAgeDefault = breedingAgeDefault,
      gestationDefault = gestationDefault
    )$indivMeanKin

  zScores <- scale(indivMeanKin)

  # Perform the gene drop simulation
  alleles <- geneDrop(
    ids = ped$id, sires = ped$sire, dams = ped$dam,
    gen = ped$gen, genotype = genotype, n = guIter,
    updateProgress = updateProgress
  )

  if (!is.null(updateProgress)) {
    updateProgress(
      detail = "Calculating Genome Uniqueness", value = 1L,
      reset = TRUE
    )
  }

  # Calculate genome uniqueness and order the rows of the returned data.frame
  gu <- calcGU(alleles, threshold = guThresh, byID = byID, pop = probands)
  gu <- gu[probands, , drop = FALSE]

  # Issue #2 Slice 1: the per-animal Monte Carlo sampling standard error of the
  # gu estimate, computed from the same rare matrix calcGU() averages (so it is
  # correct for any guThresh / byID). Carried alongside gu into both the report
  # and the returned $gu element. (calcGUSE recomputes the rare matrix today;
  # factoring it out of calcA so gu and guSE share one build is Slice 2's job.)
  guSE <- calcGUSE(alleles, threshold = guThresh, byID = byID, pop = probands)
  guSE <- guSE[probands, , drop = FALSE]

  if (!is.null(updateProgress)) {
    updateProgress(
      detail = "Calculating Numbers of Offspring", value = 1L,
      reset = TRUE
    )
  }

  # Get a data.frame of offspring counts for the probands
  offspring <- offspringCounts(probands, ped, considerPop = TRUE)

  includeCols <- intersect(getIncludeColumns(), names(ped))

  # Subsetting out the needed demographic information from the pedigree.
  # sire and dam are included so the report shows which animals have unknown
  # (U-id) parents (issue #9 / S3). They are always present because kinship()
  # above requires ped$sire and ped$dam.
  rownames(ped) <- ped$id
  demographics <- ped[probands, c(includeCols, "sire", "dam")]

  if (!is.null(updateProgress)) {
    updateProgress(
      detail = "Calculating Founder Equivalents", value = 1L,
      reset = TRUE
    )
  }

  # Calculating founder equivalents and founder genome equivalents
  feFg <- calcFEFG(ped, alleles)

  # Issue #82 Slice 3: the Monte Carlo sampling standard error of the founder
  # genome equivalents (FG), computed from the SAME gene drop that produces fg
  # (as guSE reuses gu's alleles). FG is a colony-level scalar, so fgSE is one
  # number that rides next to fg -- it is NOT a per-animal report column. NA
  # (with a warning) when a contributing founder is retained in zero iterations,
  # the same degeneracy calcFEFG reports for FG itself.
  fgSE <- calcFGSE(ped, alleles)

  # Calculating known founders
  founders <- ped[isFounder(ped), ]
  males <- founders[(founders$sex == "M") &
    !isGeneratedUnknownId(founders$id), ]
  females <- founders[(founders$sex == "F") &
    !isGeneratedUnknownId(founders$id), ]

  # Issue #9 Slice 3: classify each proband's parentage (U-id aware) so the
  # report can flag both-unknown founders and the displayed rank can demote
  # those lacking a recorded origin. Both-known and one-unknown animals rank
  # normally; kinship() is untouched.
  parentage <- classifyParentage(demographics$sire, demographics$dam)

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
    demographics, indivMeanKin, zScores, gu, guSE, offspring, parentage
  )
  finalData <- list(
    report = orderReport(finalData, ped),
    kinship = kmat,
    gu = cbind(gu, guSE),
    fe = feFg$FE,
    fg = feFg$FG,
    fgSE = fgSE,
    maleFounders = males,
    femaleFounders = females,
    nMaleFounders = nrow(males),
    nFemaleFounders = nrow(females),
    total = (nrow(males) + nrow(females))
  )
  class(finalData) <- append(class(finalData), "nprcgenekeeprGV")

  finalData
}
