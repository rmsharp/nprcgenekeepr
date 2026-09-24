## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Report eligible individual mate pairs with kinship and genetic-value context
#'
#' Issue #151 Slice 1: composes the existing pair-eligibility pipeline
#' (\code{\link{kinMatrix2LongForm}}, \code{\link{filterPairs}},
#' \code{filterAge()}, \code{\link{filterKinMatrix}} -- all unmodified)
#' into a report of opposite-sex, minimum-age-eligible mate-pair candidates,
#' each row optionally enriched with marker-based kinship
#' (\code{\link{markerKinship}}) and per-parent genetic-value context
#' (\code{\link{reportGV}}'s \code{indivMeanKin}/\code{gu}) when available.
#' No composite/blended ranking score is computed -- callers sort/filter the
#' raw columns themselves (see
#' \code{docs/planning/issue151-individual-mate-pair-analysis-plan.md}
#' Section 3, decision D3).
#'
#' @details
#' \strong{Population scoping (D4).} \code{minAge} alone does not bound the
#' candidate-pair table on real, imperfectly-curated data: a missing age
#' \emph{passes} \code{filterAge()}'s screen rather than being excluded
#' by it (see that function's own semantics), so long-retired or
#' never-dated individuals can still appear. \code{populationIds}, applied
#' via \code{\link{filterKinMatrix}} \emph{before} the pair-reshape, is the
#' mechanism that actually bounds both correctness and table size; the
#' default \code{NULL} performs no scoping (every individual in \code{kmat}
#' is a candidate). An explicit \code{character(0)} is a valid, distinct
#' input -- "scope to nobody" -- and returns a zero-row \code{pairs} frame
#' with the full column shape, not an error.
#'
#' \strong{Exclusion transparency (D5).} Two independent screens produce
#' \code{excluded} rows: the age screen (\code{"under minimum age"}) and the
#' caller-supplied \code{exclude} id list (\code{"user-excluded"}). A pair
#' failing the age screen is reported with that reason and never reaches the
#' user-exclude screen, so each dropped pair carries exactly one reason from
#' this closed, enumerable vocabulary.
#'
#' \strong{Graceful degradation.} \code{markerKmat} and \code{geneticValues}
#' are both \code{NULL}-safe: when absent (or when a specific pair is not
#' covered by them), the corresponding columns are \code{NA} for that row --
#' the pair itself is never dropped or the call errored, mirroring
#' \code{modMarkerGeneticsServer}'s own "not yet uploaded" contract.
#'
#' \strong{Ancestry rules (issue #169).} \code{ancestryRules} applies the
#' same center-configurable rules table as the Breeding Groups ancestry
#' guardrails (\code{\link{checkAncestryRules}}) to individual pairs; a rule
#' matches a pair whichever animal is the sire and whichever the dam. A
#' \code{block} rule moves the matching pair out of \code{pairs} and into
#' \code{excluded} with the reason \code{"ancestry rule"} (here "block" means
#' "not listed as eligible", not "never placed together"); a \code{flag} rule
#' keeps the pair in \code{pairs} and annotates it. Naming a block rule in
#' \code{overriddenRules} keeps its pairs in \code{pairs}, marked
#' \code{"overridden"} -- never silently absent. The ancestry screen runs
#' last: a pair that already failed the age or user-exclude screen keeps that
#' reason. Rules only move and label pairs; every pair is either in
#' \code{pairs} or in \code{excluded}, with or without rules. An animal whose
#' ancestry no rule names, or is missing, matches nothing. With
#' \code{ancestryRules = NULL} (the default) the result is unchanged, and
#' \code{ped} needs no \code{ancestry} column.
#'
#' @param ped Pedigree data.frame with at least \code{id}, \code{sire},
#' \code{dam}, \code{sex}, and \code{age} columns.
#' @param kmat Pedigree kinship matrix (e.g. as returned by
#' \code{\link{kinship}}), \code{id} x \code{id}, covering every id
#' considered.
#' @param markerKmat Optional genotype-only KING-robust kinship matrix (e.g.
#' as returned by \code{\link{markerKinship}}), \code{id} x \code{id}, which
#' may cover only a subset of \code{ped$id} (not every animal is
#' genotyped). \code{NULL} (the default) leaves \code{markerKinship} as
#' \code{NA} for every pair.
#' @param geneticValues Optional \code{\link{reportGV}}-shaped list (only
#' \code{$report}, with \code{id}, \code{indivMeanKin}, and \code{gu}
#' columns, is used). \code{NULL} (the default) leaves the four per-parent
#' genetic-value columns \code{NA} for every pair.
#' @param minAge Numeric scalar, the minimum age (in the same units as
#' \code{ped$age}) for an individual to be pair-eligible. Default \code{1},
#' mirroring Breeding Groups' own scalar convention. A missing (\code{NA})
#' age passes this screen (see Details) -- use \code{populationIds} to
#' actually bound the candidate population.
#' @param populationIds Optional character vector of ids to which the
#' analysis is scoped, applied before the pair-reshape (D4, see Details).
#' \code{NULL} (the default) performs no scoping; \code{character(0)} scopes
#' to nobody and returns a zero-row result.
#' @param exclude Character vector of ids to drop entirely, regardless of
#' any other eligibility screen. Default \code{character(0)} (no
#' caller-supplied exclusions).
#' @param ancestryRules Optional data frame of ancestry compatibility rules
#' in \code{\link{checkAncestryRules}}'s shape (\code{ancestry1},
#' \code{ancestry2}, \code{severity}); validated here. \code{ped} must then
#' carry an \code{ancestry} column, or the call stops. \code{NULL} (the
#' default) applies no ancestry screen. A valid zero-rule table is accepted:
#' the result then has the ancestry columns, with nothing moved.
#' @param overriddenRules Optional data frame with \code{ancestry1} and
#' \code{ancestry2} columns naming \code{block} rules to override for this
#' call (unordered, case-insensitive match, as in
#' \code{\link{reportAncestryViolations}}); a \code{reason} column is
#' accepted and ignored. An override naming no rule in \code{ancestryRules},
#' a \code{flag} rule, or the same rule twice is an error, as is giving
#' overrides without \code{ancestryRules}. \code{NULL} or zero rows: none.
#' @return A list with two data.frames (three when \code{ancestryRules} is
#' given):
#' \item{pairs}{One row per eligible opposite-sex pair surviving every
#' screen: \code{sireId}, \code{damId}, \code{kinship}, \code{markerKinship}
#' (\code{NA} if unavailable), \code{sireIndivMeanKin}, \code{sireGu},
#' \code{damIndivMeanKin}, \code{damGu} (the latter four \code{NA} if
#' \code{geneticValues} is not supplied or the parent is absent from its
#' report). With \code{ancestryRules}, three columns follow:
#' \code{ancestryRule} (the matched rule as a sorted \code{"LEVEL-LEVEL"}
#' string), \code{ancestrySeverity} (\code{"flag"} or \code{"block"}) and
#' \code{ancestryStatus} (\code{"violation"}, or \code{"overridden"} for an
#' overridden block rule), all \code{NA} for a pair no rule matches.}
#' \item{excluded}{One row per pair dropped by the age, user-exclude or
#' ancestry screen: \code{sireId}, \code{damId}, \code{reason} (\code{"under
#' minimum age"}, \code{"user-excluded"} or, with \code{ancestryRules},
#' \code{"ancestry rule"}). With \code{ancestryRules} an \code{ancestryRule}
#' column follows: the matched rule for an ancestry exclusion, \code{NA}
#' otherwise.}
#' \item{ancestryCoverage}{Only with \code{ancestryRules}: one row per
#' standardized ancestry level (CHINESE, INDIAN, HYBRID, JAPANESE, OTHER,
#' UNKNOWN) with \code{ancestry}, \code{n} (distinct animals at that level in
#' \code{pairs} and \code{excluded}) and \code{covered} (\code{TRUE} when a
#' rule names the level), so a level no rule covers is visible.}
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- data.frame(
#'   id = c("S1", "D1", "A", "B"),
#'   sire = c(NA, NA, "S1", NA),
#'   dam = c(NA, NA, "D1", NA),
#'   sex = c("M", "F", "M", "F"),
#'   age = c(10, 10, 5, 5),
#'   stringsAsFactors = FALSE
#' )
#' ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
#' kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
#' result <- reportMatePairs(ped, kmat, minAge = 1)
#' result$pairs
#'
#' # Ancestry rules (issue #169): the example rules block INDIAN x CHINESE
#' # and INDIAN x HYBRID pairs and flag INDIAN x UNKNOWN / INDIAN x OTHER
#' ancPed <- qcStudbook(
#'   read.csv(
#'     system.file("extdata", "examples", "example_ancestry_pedigree.csv",
#'       package = "nprcgenekeepr"
#'     ),
#'     stringsAsFactors = FALSE, na.strings = c("", "NA")
#'   ),
#'   minSireAge = 2, minDamAge = 2, reportChanges = FALSE,
#'   reportErrors = FALSE
#' )
#' ancPed$gen <- findGeneration(ancPed$id, ancPed$sire, ancPed$dam)
#' ancKmat <- kinship(ancPed$id, ancPed$sire, ancPed$dam, ancPed$gen)
#' rules <- checkAncestryRules(readAncestryRules(
#'   system.file("extdata", "examples", "example_ancestry_rules.csv",
#'     package = "nprcgenekeepr"
#'   )
#' ))
#' ancResult <- reportMatePairs(ancPed, ancKmat, ancestryRules = rules)
#' ancResult$excluded
#' ancResult$ancestryCoverage
#' # overriding one block rule keeps its pairs listed, marked "overridden"
#' overridden <- reportMatePairs(ancPed, ancKmat,
#'   ancestryRules = rules,
#'   overriddenRules = data.frame(ancestry1 = "CHINESE", ancestry2 = "INDIAN")
#' )
#' overridden$pairs[
#'   which(overridden$pairs$ancestryStatus == "overridden"),
#'   c("sireId", "damId", "ancestryRule", "ancestryStatus")
#' ]
reportMatePairs <- function(ped, kmat, markerKmat = NULL, geneticValues = NULL,
                             minAge = 1L, populationIds = NULL,
                             exclude = character(0L),
                             ancestryRules = NULL, overriddenRules = NULL) {
  assertRequiredColsPresent(
    names(ped), c("id", "sire", "dam", "sex", "age"),
    "reportMatePairs(ped)"
  )
  if (!is.matrix(kmat)) {
    stop("nprcgenekeepr: kmat must be a matrix, as returned by kinship().",
         call. = FALSE)
  }

  # Validated up front and once, so a bad rules argument fails identically on
  # every path below -- including the two early returns. NULL when no rules
  # were given: every ancestry branch below is then skipped.
  ancestry <- checkMatePairAncestryArgs(ped, ancestryRules, overriddenRules)

  if (!is.null(populationIds)) {
    kmat <- filterKinMatrix(populationIds, kmat)
  }

  if (nrow(kmat) == 0L || ncol(kmat) == 0L) {
    return(emptyMateResult(ped, ancestry))
  }

  kin <- kinMatrix2LongForm(kmat, removeDups = TRUE)
  kin <- filterPairs(kin, ped, ignore = list(
    c(sexCodes[["male"]], sexCodes[["male"]]),
    c(sexCodes[["female"]], sexCodes[["female"]])
  ))

  if (nrow(kin) == 0L) {
    return(emptyMateResult(ped, ancestry))
  }

  # Normalize id1/id2 (whichever happened to land where in the matrix) to
  # sireId (male) / damId (female) -- filterPairs() above guarantees every
  # surviving row is opposite-sex.
  sex1 <- ped$sex[match(kin$id1, ped$id)]
  isSire1 <- sex1 == sexCodes[["male"]]
  kin <- data.frame(
    sireId = ifelse(isSire1, kin$id1, kin$id2),
    damId = ifelse(isSire1, kin$id2, kin$id1),
    kinship = kin$kinship,
    stringsAsFactors = FALSE
  )
  # Every candidate pair, before any screen: its animals are the coverage
  # universe (the same animals as pairs + excluded, by conservation).
  candidateIds <- unique(c(kin$sireId, kin$damId))

  sireAge <- ped$age[match(kin$sireId, ped$id)]
  damAge <- ped$age[match(kin$damId, ped$id)]
  ageOk <- ((sireAge >= minAge) | is.na(sireAge)) &
    ((damAge >= minAge) | is.na(damAge))

  excludedAge <- kin[!ageOk, c("sireId", "damId"), drop = FALSE]
  excludedAge$reason <- rep("under minimum age", nrow(excludedAge))
  kin <- kin[ageOk, , drop = FALSE]

  userOk <- !(kin$sireId %in% exclude | kin$damId %in% exclude)
  excludedUser <- kin[!userOk, c("sireId", "damId"), drop = FALSE]
  excludedUser$reason <- rep("user-excluded", nrow(excludedUser))
  kin <- kin[userOk, , drop = FALSE]

  excluded <- rbind(excludedAge, excludedUser)
  rownames(excluded) <- NULL

  # The ancestry screen runs LAST (D5): a pair that already failed the age or
  # user screen keeps that reason and is not counted as an ancestry match, and
  # marker/genetic-value enrichment below is never computed for a blocked
  # pair. block => excluded (reason "ancestry rule"); flag, and a block rule
  # the caller overrode, stay in `pairs` and are annotated further below.
  if (!is.null(ancestry)) {
    hit <- matchAncestryPairs(kin$sireId, kin$damId, ped, ancestry$rules)
    overridden <- !is.na(hit$rule) & hit$rule %in% ancestry$overrideKeys
    blocked <- !is.na(hit$severity) & hit$severity == "block" & !overridden
    ancestryStatus <- rep(NA_character_, nrow(kin))
    ancestryStatus[!is.na(hit$rule)] <- "violation"
    ancestryStatus[overridden] <- "overridden"

    excluded$ancestryRule <- rep(NA_character_, nrow(excluded))
    excluded <- rbind(excluded, data.frame(
      sireId = kin$sireId[blocked], damId = kin$damId[blocked],
      reason = rep("ancestry rule", sum(blocked)),
      ancestryRule = hit$rule[blocked], stringsAsFactors = FALSE
    ))
    rownames(excluded) <- NULL

    ancestryRule <- hit$rule[!blocked]
    ancestrySeverity <- hit$severity[!blocked]
    ancestryStatus <- ancestryStatus[!blocked]
    kin <- kin[!blocked, , drop = FALSE]
  }

  # kin may legitimately be 0-row here (every candidate pair excluded). The
  # merges below are 0-row-safe by construction (match()/%in%/any() on empty
  # vectors resolve to correct no-ops) -- but the scalar-recycling assumption
  # for a brand-new column is NOT: `df$col <- NA_real_` errors ("replacement
  # has 1 row, data has 0") on a 0-row data.frame rather than recycling, so
  # every new column below is explicitly length-matched via rep(..., nrow()).
  kin$markerKinship <- rep(NA_real_, nrow(kin))
  if (!is.null(markerKmat)) {
    bothGenotyped <- kin$sireId %in% rownames(markerKmat) &
      kin$damId %in% rownames(markerKmat)
    if (any(bothGenotyped)) {
      kin$markerKinship[bothGenotyped] <- markerKmat[
        cbind(kin$sireId[bothGenotyped], kin$damId[bothGenotyped])
      ]
    }
  }

  kin$sireIndivMeanKin <- rep(NA_real_, nrow(kin))
  kin$sireGu <- rep(NA_real_, nrow(kin))
  kin$damIndivMeanKin <- rep(NA_real_, nrow(kin))
  kin$damGu <- rep(NA_real_, nrow(kin))
  if (!is.null(geneticValues) && !is.null(geneticValues$report)) {
    rpt <- geneticValues$report
    sireIdx <- match(kin$sireId, rpt$id)
    damIdx <- match(kin$damId, rpt$id)
    kin$sireIndivMeanKin <- rpt$indivMeanKin[sireIdx]
    kin$sireGu <- rpt$gu[sireIdx]
    kin$damIndivMeanKin <- rpt$indivMeanKin[damIdx]
    kin$damGu <- rpt$gu[damIdx]
  }

  rownames(kin) <- NULL
  if (is.null(ancestry)) {
    return(list(pairs = kin, excluded = excluded))
  }
  # Appended AFTER the existing eight columns so consumers indexing them are
  # undisturbed when rules are active (D6c).
  kin$ancestryRule <- ancestryRule
  kin$ancestrySeverity <- ancestrySeverity
  kin$ancestryStatus <- ancestryStatus
  list(
    pairs = kin, excluded = excluded,
    ancestryCoverage = mateAncestryCoverage(candidateIds, ped, ancestry$rules)
  )
}

#' @param ancestry when \code{TRUE}, include the three ancestry annotation
#' columns (issue #169): the shape depends on the argument, never the data.
#' @noRd
emptyMatePairsFrame <- function(ancestry = FALSE) {
  out <- data.frame(
    sireId = character(0L), damId = character(0L),
    kinship = numeric(0L), markerKinship = numeric(0L),
    sireIndivMeanKin = numeric(0L), sireGu = numeric(0L),
    damIndivMeanKin = numeric(0L), damGu = numeric(0L),
    stringsAsFactors = FALSE
  )
  if (ancestry) {
    out$ancestryRule <- character(0L)
    out$ancestrySeverity <- character(0L)
    out$ancestryStatus <- character(0L)
  }
  out
}

#' @param ancestry when \code{TRUE}, include the \code{ancestryRule} column.
#' @noRd
emptyMateExcludedFrame <- function(ancestry = FALSE) {
  out <- data.frame(
    sireId = character(0L), damId = character(0L),
    reason = character(0L), stringsAsFactors = FALSE
  )
  if (ancestry) {
    out$ancestryRule <- character(0L)
  }
  out
}

#' The zero-pair result of \code{reportMatePairs()}
#'
#' Shared by the two early returns. With ancestry rules active the result
#' keeps the rules-active shape (extra columns, coverage element) so the shape
#' depends on the argument, never on how many pairs there happened to be.
#'
#' @param ped the pedigree.
#' @param ancestry \code{NULL}, or the list from
#' \code{checkMatePairAncestryArgs()}.
#' @return \code{list(pairs, excluded)}, plus \code{ancestryCoverage} when
#' \code{ancestry} is not \code{NULL}.
#' @noRd
emptyMateResult <- function(ped, ancestry) {
  if (is.null(ancestry)) {
    return(list(
      pairs = emptyMatePairsFrame(), excluded = emptyMateExcludedFrame()
    ))
  }
  list(
    pairs = emptyMatePairsFrame(ancestry = TRUE),
    excluded = emptyMateExcludedFrame(ancestry = TRUE),
    ancestryCoverage = mateAncestryCoverage(character(0L), ped, ancestry$rules)
  )
}

#' Validate the ancestry arguments of \code{reportMatePairs()}
#'
#' Runs once, before any pairing. Rules are validated by
#' \code{\link{checkAncestryRules}} (so its UNKNOWN/OTHER warning fires once).
#' Each override names a \code{block} rule present in the rules
#' (unordered, case-insensitive); an override naming no real rule, a
#' \code{flag} rule (it would change nothing), or a duplicated rule is an
#' error, as is any override given without rules. An optional \code{reason}
#' column is accepted and ignored -- reasons belong to the app's confirm gate
#' and audit manifest. Zero-row \code{overriddenRules} means no overrides.
#'
#' @param ped the pedigree; must carry \code{ancestry} when rules are given.
#' @param ancestryRules \code{NULL}, or a rules table.
#' @param overriddenRules \code{NULL}, or a data frame with
#' \code{ancestry1} and \code{ancestry2} columns.
#' @return \code{NULL} when \code{ancestryRules} is \code{NULL}; otherwise
#' \code{list(rules, overrideKeys)} -- the validated rules and the overridden
#' rules' sorted \code{"LEVEL-LEVEL"} keys.
#' @noRd
checkMatePairAncestryArgs <- function(ped, ancestryRules, overriddenRules) {
  hasOverrides <- !is.null(overriddenRules) && NROW(overriddenRules) > 0L
  if (is.null(ancestryRules)) {
    if (hasOverrides) {
      stop("nprcgenekeepr: overriddenRules given without ancestryRules; ",
        "there are no rules to override.",
        call. = FALSE
      )
    }
    return(NULL)
  }
  rules <- checkAncestryRules(ancestryRules)
  if (!("ancestry" %in% names(ped))) {
    stop("nprcgenekeepr: ped has no 'ancestry' column.", call. = FALSE)
  }

  overrideKeys <- character(0L)
  if (hasOverrides) {
    if (!all(c("ancestry1", "ancestry2") %in% names(overriddenRules))) {
      stop("nprcgenekeepr: overriddenRules must have columns 'ancestry1' ",
        "and 'ancestry2'.",
        call. = FALSE
      )
    }
    overrideKeys <- .ancestryPairKey(
      toupper(trimws(as.character(overriddenRules$ancestry1))),
      toupper(trimws(as.character(overriddenRules$ancestry2)))
    )
    ruleKey <- .ancestryPairKey(rules$ancestry1, rules$ancestry2)
    missingRules <- setdiff(overrideKeys, ruleKey)
    if (length(missingRules) > 0L) {
      stop("nprcgenekeepr: overriddenRules contains rule(s) not present ",
        "in rules: ", toString(missingRules), ".",
        call. = FALSE
      )
    }
    flagRules <- overrideKeys[rules$severity[match(overrideKeys, ruleKey)] ==
      "flag"]
    if (length(flagRules) > 0L) {
      stop("nprcgenekeepr: only block rules can be overridden; flag ",
        "rule(s) never exclude a pair: ", toString(flagRules), ".",
        call. = FALSE
      )
    }
    if (anyDuplicated(overrideKeys) > 0L) {
      stop("nprcgenekeepr: overriddenRules contains duplicated ",
        "(unordered) rule(s): ",
        toString(unique(overrideKeys[duplicated(overrideKeys)])), ".",
        call. = FALSE
      )
    }
  }
  list(rules = rules, overrideKeys = overrideKeys)
}

#' Match candidate mate pairs against ancestry rules, vectorised
#'
#' One \code{match()} over all pairs -- not a loop over pairs and not
#' \code{\link{reportAncestryViolations}} over two-animal groups, which
#' measured ~0.5 ms per pair against pair tables of 10^5 to 10^6 rows (issue
#' #169 plan, D6a). Levels are normalised exactly like the group reporter
#' (\code{toupper(trimws(as.character()))}, since post-QC ancestry is a
#' factor). A pair with an \code{NA} or unrecognised level matches nothing.
#'
#' @param id1,id2 character vectors of animal ids, one pair per position.
#' @param ped data frame with \code{id} and \code{ancestry} columns.
#' @param rules validated ancestry rules table.
#' @return list with \code{rule} (sorted \code{"LEVEL-LEVEL"} key of the
#' matched rule) and \code{severity}, both \code{NA} where no rule matched.
#' @noRd
matchAncestryPairs <- function(id1, id2, ped, rules) {
  level <- function(id) {
    toupper(trimws(as.character(ped$ancestry[match(id, ped$id)])))
  }
  ruleKey <- .ancestryPairKey(rules$ancestry1, rules$ancestry2)
  hit <- match(.ancestryPairKey(level(id1), level(id2)), ruleKey)
  list(rule = ruleKey[hit], severity = rules$severity[hit])
}

#' Ancestry-rule coverage of the animals a mate-pair report considered
#'
#' Same shape and level order as the coverage element of
#' \code{\link{reportAncestryViolations}}: one row per standardized level with
#' \code{ancestry}, \code{n} (animals in \code{ids} at that level) and
#' \code{covered} (a rule names the level). An animal whose level is \code{NA}
#' or unrecognised is counted in no row.
#'
#' @param ids character vector of the distinct animals considered.
#' @param ped data frame with \code{id} and \code{ancestry} columns.
#' @param rules validated ancestry rules table.
#' @return data.frame with columns \code{ancestry}, \code{n}, \code{covered}.
#' @noRd
mateAncestryCoverage <- function(ids, ped, rules) {
  levelsAll <- c("CHINESE", "INDIAN", "HYBRID", "JAPANESE", "OTHER", "UNKNOWN")
  lev <- toupper(trimws(as.character(ped$ancestry[match(ids, ped$id)])))
  named <- unique(c(rules$ancestry1, rules$ancestry2))
  data.frame(
    ancestry = levelsAll,
    n = unname(vapply(
      levelsAll, function(l) sum(lev == l, na.rm = TRUE), integer(1L)
    )),
    covered = levelsAll %in% named,
    stringsAsFactors = FALSE
  )
}
