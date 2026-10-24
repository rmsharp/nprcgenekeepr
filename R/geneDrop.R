## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Simulate gene dropping through a pedigree
#'
#' Part of Genetic Value Analysis
#'
#' The gene dropping method from \emph{Pedigree analysis by computer simulation}
#' by Jean W MacCluer, John L Vandeberg, and Oliver A Ryder (1986)
#' <doi:10.1002/zoo.1430050209> is used in the genetic value calculations.
#'
#' Currently there is no means of handling knowing only one haplotype.
#' Another column could be added to handle situations where only one
#' allele is observed and it is not known to be homozygous or heterozygous. The
#' new fourth column could have a frequency for homozygosity that could be
#' used in the gene dropping algorithm.
#'
#' The genotypes are using indirection (integer instead of character) to
#' indicate the genes because the manipulation of character strings was found
#' to take 20-35 times longer to perform.
#'
#' Adding additional columns to \code{genotype} does not significantly affect
#' the time require. Thus, it is convenient to add the corresponding haplotype
#' names to the dataframe using \code{first_name} and \code{second_name}.
#'
#' Animal IDs (\code{ids}) must not contain a period ("."). A period is
#' disallowed because it causes problems across software environments (R
#' column-name and formula parsing, file-name extensions, programming-language
#' namespaces, and regular expressions); \code{geneDrop} additionally relies on
#' the period internally to recover the id and parent of each allele row, so a
#' period-bearing id would silently corrupt the result. IDs containing a period
#' are therefore rejected with an error. The same rule is enforced at data
#' input by \code{\link{qcStudbook}} and honored by all automatically generated
#' IDs.
#'
#' Animal IDs (\code{ids}) must also be unique. \code{geneDrop} indexes each
#' animal's parents and accumulates its simulated alleles by id, so duplicate
#' ids are rejected with an error. This invariant is established upstream by
#' \code{\link{qcStudbook}} (via \code{\link{removeDuplicates}}) and by
#' \code{\link{kinship}}, both of which require unique ids.
#'
#' @param ids A character vector of unique IDs for a set of animals.
#' @param sires A character vector with IDS of the sires for the set of
#'  animals. \code{NA} is used for missing sires.
#' @param dams A character vector with IDS of the dams for the set of
#'  animals. \code{NA} is used for missing dams.
#' @param gen An integer vector indicating the generation number for each
#' animal.
#' @param genotype A dataframe containing known genotypes. It has three
#' columns:  \code{id}, \code{first}, and \code{second}. The second and third
#' columns contain the integers indicating the observed genotypes. The codes
#' must not collide with the integer codes the function assigns to unknown
#' founder alleles (1, 2, 3, ...).
#'
#' @param n integer indicating the number of iterations to simulate.
#' Default is 1000.
#' @param updateProgress function or NULL. If this function is defined, it
#' will be called once at the start (with \code{reset = TRUE}) and then once
#' for each animal processed, to update a \code{shiny::Progress} object.
#'
#' @return A data.frame \code{V1 ... Vn, id, parent}
#' A data.frame providing the maternal and paternal alleles for an animal
#' for each iteration. The first \code{n} columns indicate the allele for
#' each iteration. These are followed by two columns: \code{id}, the
#' animal's ID, and \code{parent}, whether the allele came from the sire
#' (\code{"sire"}) or dam (\code{"dam"}). Each animal has two rows, and
#' the animals are ordered by generation, oldest first.
#'
#' @export
#' @examples
#' ## We usually define `n` to be >= 1000
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' allelesNew <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
#'   genotype = NULL, n = 50, updateProgress = NULL
#' )
#' genotype <- data.frame(
#'   id = ped$id,
#'   first_allele = c(
#'     NA, NA, "A001_B001", "A001_B002",
#'     NA, "A001_B002", "A001_B001"
#'   ),
#'   second_allele = c(
#'     NA, NA, "A010_B001", "A001_B001",
#'     NA, NA, NA
#'   ),
#'   stringsAsFactors = FALSE
#' )
#' pedWithGenotype <- addGenotype(ped, genotype)
#' pedGenotype <- getGVGenotype(pedWithGenotype)
#' allelesNewGen <- geneDrop(ped$id, ped$sire, ped$dam, ped$gen,
#'   genotype = pedGenotype,
#'   n = 5, updateProgress = NULL
#' )
geneDrop <- function(ids, sires, dams, gen, genotype = NULL, n = 1000L,
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
  plan <- geneDropPlan(ids, sires, dams, gen, genotype, n)
  if (is.null(plan)) {
    return(geneDropGeneral(ids, sires, dams, gen, genotype, n,
                           updateProgress))
  }
  ## Performance plan Phase 2: each animal's two alleles are two columns of one
  ## matrix (sire, then dam) in generation order, one row per iteration, and
  ## parents are found by position. The draws are today's, in today's order,
  ## so the table is today's for the same seed.
  nAnimals <- length(plan$id)
  alleles <- matrix(if (plan$isDouble) 0.0 else 0L, nrow = n,
                    ncol = 2L * nAnimals)
  nIter <- nrow(alleles)
  counter <- 1L
  parents <- list(plan$sire, plan$dam)
  codes <- list(plan$first, plan$second)

  notifyProgress(
    updateProgress,
    detail = "Performing Gene-drop Simulation", value = 0L, reset = TRUE
  )

  for (i in seq_len(nAnimals)) {
    for (side in 1L:2L) {
      col <- 2L * i - 2L + side
      code <- codes[[side]][i]
      parent <- parents[[side]][i]
      if (!is.na(code)) {
        # A known genotype allele, the same in every iteration.
        alleles[, col] <- code
      } else if (is.na(parent)) {
        # An unknown parent passes on a new allele of its own.
        alleles[, col] <- counter
        counter <- counter + 1L
      } else {
        # Mendelian sampling of the parent's two alleles, as chooseAlleles().
        s1 <- sample(c(0L, 1L), nIter, replace = TRUE)
        alleles[, col] <- (alleles[, 2L * parent - 1L] * s1) +
          (alleles[, 2L * parent] * (1L - s1))
      }
    }

    notifyProgress(updateProgress, n = nAnimals)
  }

  alleles <- as.data.frame(t(alleles))
  alleles$id <- rep(plan$id, each = 2L)
  alleles$parent <- rep(c("sire", "dam"), nAnimals)
  rownames(alleles) <- seq_len(nrow(alleles))
  alleles
}

#' An ordinary pedigree, laid out for geneDrop()'s fast path, or NULL
#'
#' \code{geneDrop()}'s fast path gives today's table only where that can be
#' shown (performance plan Phase 2, decision D1). So \code{ids},
#' \code{sires}, \code{dams} and \code{gen} must be plain vectors of one
#' length, with at least one animal; \code{n} one whole number of at least 1;
#' no id missing or empty; every known parent an animal earlier in the
#' generation order, so its alleles exist before its offspring draw from them;
#' and \code{genotype} NULL or a dataframe with \code{id}, \code{first} and
#' \code{second} columns, numeric codes, no missing id on a row it keeps and
#' no animal on two rows it keeps. Any other input gives NULL, and
#' \code{geneDrop()} runs today's code, \code{geneDropGeneral()} (owner ruling
#' S1054).
#'
#' @inheritParams geneDrop
#' @return NULL, or a list: \code{id}, the ids in generation order;
#' \code{sire} and \code{dam}, each parent's position in \code{id}, NA for an
#' unknown parent; \code{first} and \code{second}, each animal's known
#' genotype codes, NA where its allele is drawn; and \code{isDouble}, TRUE
#' when a double code is used, which makes today's table double.
#' @noRd
geneDropPlan <- function(ids, sires, dams, gen, genotype, n) {
  nAnimals <- length(ids)
  isColumn <- function(x) {
    is.atomic(x) && is.null(dim(x)) && length(x) == nAnimals
  }
  if (nAnimals == 0L || !isColumn(ids) || !isColumn(sires) ||
        !isColumn(dams) || !isColumn(gen) || !is.numeric(n) ||
        length(n) != 1L || is.na(n) || n < 1L || n != trunc(n)) {
    return(NULL)
  }
  ord <- order(gen)
  id <- as.character(ids)[ord]
  if (anyNA(id) || !all(nzchar(id))) {
    return(NULL)
  }
  sireIds <- as.character(sires)[ord]
  damIds <- as.character(dams)[ord]
  sire <- match(sireIds, id)
  dam <- match(damIds, id)
  # A known parent must come earlier, so its alleles exist when drawn from.
  position <- seq_len(nAnimals)
  if (!all(is.na(sireIds) | (!is.na(sire) & sire < position)) ||
        !all(is.na(damIds) | (!is.na(dam) & dam < position))) {
    return(NULL)
  }
  first <- rep(NA_integer_, nAnimals)
  second <- rep(NA_integer_, nAnimals)
  isDouble <- FALSE
  if (!is.null(genotype)) {
    if (!is.data.frame(genotype) ||
          !all(c("id", "first", "second") %in% names(genotype))) {
      return(NULL)
    }
    genotype <- genotype[!(is.na(genotype$first) & is.na(genotype$second)), ]
    if (!is.numeric(genotype$first) || !is.numeric(genotype$second) ||
          anyNA(genotype$id) ||
          anyDuplicated(genotype$id[genotype$id %in% id]) > 0L) {
      return(NULL)
    }
    rows <- match(id, genotype$id)
    first <- genotype$first[rows]
    second <- genotype$second[rows]
    isDouble <- (is.double(first) && !all(is.na(first))) ||
      (is.double(second) && !all(is.na(second)))
  }
  list(id = id, sire = sire, dam = dam, first = first, second = second,
       isDouble = isDouble)
}

#' Today's gene drop, for any input
#'
#' \code{geneDrop()}'s code before performance plan Phase 2, word for word
#' after its two id checks: each animal's alleles kept in a list, its parents
#' looked up by row name, \code{assignAlleles()} for each parent.
#' \code{geneDrop()} calls it for an input \code{geneDropPlan()} does not
#' admit, which keeps that input's table, error and warnings.
#'
#' @inheritParams geneDrop
#' @return As \code{geneDrop()}.
#' @noRd
geneDropGeneral <- function(ids, sires, dams, gen, genotype, n,
                            updateProgress) {
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
