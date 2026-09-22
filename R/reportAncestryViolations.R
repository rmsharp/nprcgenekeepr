## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Report ancestry-rule violations within formed groups
#'
#' Issue #168 Slice 2: the script-callable flag/inspection half of the
#' ancestry guardrails. Given any list of formed groups (for example the
#' \code{group} element returned by \code{\link{groupAddAssign}}, excluding
#' its final unused-animals element), a pedigree carrying an \code{ancestry}
#' column, and a rules table in \code{\link{checkAncestryRules}}'s shape,
#' it reports every within-group pair matching a rule -- \code{block} and
#' \code{flag} severities alike -- plus a rule-coverage summary so
#' permissive silence is visible (a level no rule names participates in no
#' conflict; the summary says how many animals sit at each level and
#' whether any rule covers it).
#'
#' A rule listed in \code{overriddenRules} still reports its violating
#' pairs -- with \code{status} \code{"overridden"} rather than
#' \code{"violation"}, never silently absent. An \code{overriddenRules} row
#' that matches no rule in \code{rules} is an error, so a typo cannot
#' silently disable nothing.
#'
#' @param groups list of character vectors of animal IDs, one vector per
#' formed group. \code{NA} entries (the empty unused-animals marker
#' \code{\link{groupAddAssign}} can produce) are ignored.
#' @param ped data frame with at least \code{id} and \code{ancestry}
#' columns. Ancestry values are coerced with \code{toupper(trimws())}, so a
#' post-\code{\link{qcStudbook}} pedigree and a hand-built frame both work.
#' @param rules data frame of ancestry compatibility rules; validated here
#' via \code{\link{checkAncestryRules}}.
#' @param overriddenRules optional data frame with \code{ancestry1} and
#' \code{ancestry2} columns naming the rules overridden for this run
#' (unordered match, case-insensitive). Default \code{NULL}: no overrides.
#' @return A list with two data.frames:
#' \item{violations}{One row per violating within-group pair:
#' \code{group} (integer index into \code{groups}), \code{id1}, \code{id2},
#' \code{ancestry1}, \code{ancestry2} (the two animals' own levels),
#' \code{rule} (the matched rule's unordered pair as a sorted
#' \code{"LEVEL-LEVEL"} string), \code{severity} (\code{"block"} or
#' \code{"flag"}), and \code{status} (\code{"violation"} or
#' \code{"overridden"}). Zero rows, same columns, when nothing violates.}
#' \item{coverage}{One row per standardized ancestry level (CHINESE,
#' INDIAN, HYBRID, JAPANESE, OTHER, UNKNOWN): \code{ancestry}, \code{n}
#' (animals in \code{groups} at that level), and \code{covered}
#' (\code{TRUE} when at least one rule names the level).}
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- qcStudbook(
#'   read.csv(
#'     system.file("extdata", "examples", "example_ancestry_pedigree.csv",
#'       package = "nprcgenekeepr"
#'     ),
#'     stringsAsFactors = FALSE, na.strings = c("", "NA")
#'   ),
#'   minParentAge = 2, reportChanges = FALSE, reportErrors = FALSE
#' )
#' rules <- checkAncestryRules(readAncestryRules(
#'   system.file("extdata", "examples", "example_ancestry_rules.csv",
#'     package = "nprcgenekeepr"
#'   )
#' ))
#' reportAncestryViolations(list(c("I1", "C1"), c("I2", "U1")), ped, rules)
reportAncestryViolations <- function(groups, ped, rules,
                                     overriddenRules = NULL) {
  rules <- checkAncestryRules(rules)
  if (!("ancestry" %in% names(ped))) {
    stop("nprcgenekeepr: ped has no 'ancestry' column.", call. = FALSE)
  }
  allIds <- unique(unlist(groups, use.names = FALSE))
  allIds <- allIds[!is.na(allIds)]
  unknown <- setdiff(allIds, ped$id)
  if (length(unknown) > 0L) {
    stop("nprcgenekeepr: group ids not present in ped: ",
      toString(unknown), ".",
      call. = FALSE
    )
  }

  overriddenKeys <- character(0L)
  if (!is.null(overriddenRules) && nrow(overriddenRules) > 0L) {
    ## D4: an override that names nothing real must fail loudly, never
    ## silently disable nothing
    if (!all(c("ancestry1", "ancestry2") %in% names(overriddenRules))) {
      stop("nprcgenekeepr: overriddenRules must have columns 'ancestry1' ",
        "and 'ancestry2'.",
        call. = FALSE
      )
    }
    o1 <- toupper(trimws(as.character(overriddenRules$ancestry1)))
    o2 <- toupper(trimws(as.character(overriddenRules$ancestry2)))
    overriddenKeys <- paste(pmin(o1, o2), pmax(o1, o2), sep = "-")
    ruleKeys <- paste(pmin(rules$ancestry1, rules$ancestry2),
      pmax(rules$ancestry1, rules$ancestry2),
      sep = "-"
    )
    missingRules <- setdiff(overriddenKeys, ruleKeys)
    if (length(missingRules) > 0L) {
      stop("nprcgenekeepr: overriddenRules contains rule(s) not present ",
        "in rules: ", toString(missingRules), ".",
        call. = FALSE
      )
    }
  }

  violations <- list()
  for (g in seq_along(groups)) {
    ids <- groups[[g]]
    ids <- unique(ids[!is.na(ids)])
    if (length(ids) < 2L) {
      next
    }
    pairsG <- rbind(
      .ancestryConflictPairs(ids, ped, rules, severity = "block"),
      .ancestryConflictPairs(ids, ped, rules, severity = "flag")
    )
    if (nrow(pairsG) == 0L) {
      next
    }
    pairsG$group <- rep(g, nrow(pairsG))
    violations[[length(violations) + 1L]] <- pairsG
  }

  if (length(violations) > 0L) {
    v <- do.call(rbind, violations)
    v$status <- ifelse(v$rule %in% overriddenKeys, "overridden", "violation")
    v <- v[, c(
      "group", "id1", "id2", "ancestry1", "ancestry2", "rule",
      "severity", "status"
    )]
    rownames(v) <- NULL
  } else {
    v <- data.frame(
      group = integer(0L), id1 = character(0L), id2 = character(0L),
      ancestry1 = character(0L), ancestry2 = character(0L),
      rule = character(0L), severity = character(0L),
      status = character(0L), stringsAsFactors = FALSE
    )
  }

  ## D6 coverage: the vocabulary is checkAncestryRules()'s six levels
  levelsAll <- c(
    "CHINESE", "INDIAN", "HYBRID", "JAPANESE", "OTHER", "UNKNOWN"
  )
  lev <- toupper(trimws(as.character(ped$ancestry[match(allIds, ped$id)])))
  named <- unique(c(rules$ancestry1, rules$ancestry2))
  coverage <- data.frame(
    ancestry = levelsAll,
    n = unname(vapply(
      levelsAll, function(l) sum(lev == l, na.rm = TRUE), integer(1L)
    )),
    covered = levelsAll %in% named,
    stringsAsFactors = FALSE
  )

  list(violations = v, coverage = coverage)
}

#' Find the id pairs matching ancestry rules of one severity
#'
#' Shared by \code{\link{groupAddAssign}} (block-pair merge) and
#' \code{\link{reportAncestryViolations}} (both severities). Animals whose
#' ancestry level no rule names -- or whose level is \code{NA} -- participate
#' in no conflict (permissive by construction, D6). Each unordered pair
#' appears exactly once: \code{\link{checkAncestryRules}} guarantees no
#' duplicated unordered rule pair, so no animal pair can match twice.
#'
#' @param ids character vector of animal IDs to examine.
#' @param ped data frame with \code{id} and \code{ancestry} columns.
#' @param rules validated ancestry rules table.
#' @param severity which severity class to extract (\code{"block"} or
#' \code{"flag"}).
#' @return data.frame with columns \code{id1}, \code{id2}, \code{ancestry1},
#' \code{ancestry2}, \code{rule} (sorted \code{"LEVEL-LEVEL"} string), and
#' \code{severity}; zero rows when nothing matches.
#' @noRd
.ancestryConflictPairs <- function(ids, ped, rules, severity) {
  rules <- rules[rules$severity == severity, , drop = FALSE]
  lev <- toupper(trimws(as.character(ped$ancestry[match(ids, ped$id)])))
  byLevel <- split(ids, lev)
  out <- list()
  for (r in seq_len(nrow(rules))) {
    a <- rules$ancestry1[r]
    b <- rules$ancestry2[r]
    if (a == b) {
      idsA <- byLevel[[a]]
      if (length(idsA) < 2L) {
        next
      }
      cmb <- utils::combn(idsA, 2L)
      pairsR <- data.frame(
        id1 = cmb[1L, ], id2 = cmb[2L, ], stringsAsFactors = FALSE
      )
    } else {
      idsA <- byLevel[[a]]
      idsB <- byLevel[[b]]
      if (length(idsA) == 0L || length(idsB) == 0L) {
        next
      }
      pairsR <- data.frame(
        id1 = rep(idsA, times = length(idsB)),
        id2 = rep(idsB, each = length(idsA)),
        stringsAsFactors = FALSE
      )
    }
    pairsR$ancestry1 <- rep(a, nrow(pairsR))
    pairsR$ancestry2 <- rep(b, nrow(pairsR))
    pairsR$rule <- rep(paste(sort(c(a, b)), collapse = "-"), nrow(pairsR))
    pairsR$severity <- rep(severity, nrow(pairsR))
    out[[length(out) + 1L]] <- pairsR
  }
  if (length(out) == 0L) {
    return(data.frame(
      id1 = character(0L), id2 = character(0L),
      ancestry1 = character(0L), ancestry2 = character(0L),
      rule = character(0L), severity = character(0L),
      stringsAsFactors = FALSE
    ))
  }
  do.call(rbind, out)
}

#' Merge ancestry-blocked pairs into the kin conflict list
#'
#' Adds each blocked pair to \code{kin} in BOTH directions (the list is
#' consumed one-directionally at the \code{fillGroupMembers} seam, so
#' symmetry is the caller's guarantee -- issue #168 plan, Dragon 2).
#' Entries are created when absent; an existing \code{NA} placeholder
#' entry gains the id alongside the \code{NA}, which the seam's
#' \code{setdiff} tolerates.
#'
#' @param kin named list of conflict partners, as built by
#' \code{\link{getAnimalsWithHighKinship}}.
#' @param pairs data.frame with \code{id1} and \code{id2} columns, one
#' blocked pair per row.
#' @return The \code{kin} list with every pair present in both directions.
#' @noRd
.mergeAncestryBlockPairs <- function(kin, pairs) {
  # getAnimalsWithHighKinship() builds `kin` with tapply(), a 1-d list-mode
  # ARRAY: reading an absent name with [[ errors there ("subscript out of
  # bounds") where a plain list returns NULL -- and it is empty (no names at
  # all) whenever every kinship pair was filtered out. Normalize first;
  # every downstream consumer indexes by name identically on a plain list.
  kin <- as.list(kin)
  for (i in seq_len(nrow(pairs))) {
    id1 <- pairs$id1[i]
    id2 <- pairs$id2[i]
    kin[[id1]] <- c(kin[[id1]], id2)
    kin[[id2]] <- c(kin[[id2]], id1)
  }
  kin
}
