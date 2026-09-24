# Mate Pair Analysis Module - Server Function

Reports eligible individual mate-pair candidates via
[`reportMatePairs`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md)
(issue \#151 Slice 1), wrapped in a curator-facing configuration panel
for the D4-ratified population scope (`populationSource`: `"allAlive"` –
ids with no recorded `ped$exit` date; `"topRanked"` – the top
`nTopAnimals` ids in `geneticValues`' own report order, mirroring
[`modBreedingGroupsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md)'s
own `topRanked` reading; `"custom"` – a pasted, delimiter-separated id
list), the D2 minimum- age floor, and the D5-ratified exclude-list
textarea. Kept structurally and file-wise separate from
[`modBreedingGroupsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md)
(D1) – this module shares no code with it.

## Usage

``` r
modMatePairServer(
  id,
  pedigree,
  kinshipMatrix,
  markerKinshipMatrix,
  geneticValues,
  ancestryRules = NULL
)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning the current pedigree data frame (columns `id`,
  `sire`, `dam`, `sex`, `age`, optionally `exit`).

- kinshipMatrix:

  reactive returning the full pedigree-based kinship matrix (row/column
  names are animal IDs), typically the same shared reactive passed to
  `modBreedingGroupsServer`/ `modMarkerGeneticsServer`.

- markerKinshipMatrix:

  reactive returning the genotype-only KING- robust kinship matrix from
  [`modMarkerGeneticsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsServer.md)'s
  own `markerKinshipMatrix` return element, or `NULL` before a genotype
  file has been uploaded.

- geneticValues:

  reactive returning the current genetic-value report data.frame
  (`shared$geneticValues`, with `id`, `indivMeanKin`, `gu` columns), or
  `NULL` before the Genetic Value Analysis tab has been run.

- ancestryRules:

  optional reactive returning the validated ancestry rules table (see
  [`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md))
  from
  [`modBreedingGroupsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md)'s
  `ancestryRules` return element, or `NULL` when no rules are loaded.
  `NULL` (the default, or a reactive that returns `NULL`) applies no
  rules, and the results are identical to a run before this argument
  existed.

## Value

A list with three reactive elements: `pairs`, the eligible- pairs
data.frame from the most recent
[`reportMatePairs()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md)
run (see that function's own return documentation for columns);
`excluded`, the corresponding excluded-pairs data.frame; and `isReady`,
`TRUE` once a run has completed.

## Details

**The `geneticValues` wiring detail.** `shared$geneticValues` (as
threaded from `appServer.R`, matching every other module's own
convention) is the flat `reportGV()$report` data.frame, not the
`list(report = ...)` shape
[`reportMatePairs`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md)
itself expects. This server wraps it (`list(report = geneticValues())`)
immediately before calling
[`reportMatePairs()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md)
– omitting the wrap would not error (a data.frame's `$report` accessor
returns `NULL`, not a condition), it would silently leave every genetic-
value column `NA`.

**Population scoping is a hard dependency, not a fallback-recompute.**
Unlike `modBreedingGroupsServer`'s optional `kinshipMatrix` (which
recomputes from `pedigree` when absent), this module always receives the
already-computed shared kinship reactive from `appServer.R` and simply
depends on it (module-contract rule 5: upstream absence is `req()`),
matching
[`modMarkerGeneticsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsServer.md)'s
own simpler precedent – there is no standalone use case for this module
that would need an independent recompute path.

**Ancestry guardrails (issue \#169).** `ancestryRules` carries the rules
loaded on the Breeding Groups tab. When rules are loaded and the
pedigree has an `ancestry` column, each run hands them to
[`reportMatePairs`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md):
a pair matching a `block` rule moves to the Excluded tab (reason
`"ancestry rule"`) and a pair matching a `flag` rule stays in Eligible
Pairs, annotated. The rules are read once, at the "Find Eligible Pairs"
click, so loading or clearing rules afterwards never rewrites a finished
run's tables. The module checks for the `ancestry` column before passing
rules (the report function stops without it); a rules-loaded run on a
pedigree with no such column runs exactly as it does with no rules, and
the status line says the guardrails are inactive. An always-visible
status line reports the loaded state.

**Overriding a block rule.** With active rules, the "Ancestry
Guardrails" section lists the block rules not yet overridden. "Override
rule..." opens a confirmation step that shows the warning text verbatim
and requires a written reason (a blank reason is refused); confirming
relaxes that one rule for this tab's runs, for the session, until the
overrides are cleared or the rules change. An overridden rule's pairs
stay in Eligible Pairs marked `"overridden"` (severity still `"block"`);
they are never silently dropped. Each override is recorded per tab –
Breeding Groups keeps its own – and the next run applies it; a finished
run is never rewritten.

**The Ancestry tab.** Shows the displayed run's coverage summary (how
many candidate animals carry each ancestry classification and which
classifications no rule reaches) and a "Download Audit Manifest" button.
The manifest is one row per rule: the rule as written, whether it was
overridden and why, how many otherwise-eligible pairs it matched, the
animal census by classification, and the confirmation warning verbatim.
It describes the displayed run's own rules and overrides, and is
unavailable for a run that had no rules in effect.

## See also

[`modMatePairUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairUI.md)

[`reportMatePairs`](https://github.com/rmsharp/nprcgenekeepr/reference/reportMatePairs.md)

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modCrossCenterIdentityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityServer.md),
[`modCrossCenterIdentityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modCrossCenterIdentityUI.md),
[`modDeidentifiedExportServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportServer.md),
[`modDeidentifiedExportUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modDeidentifiedExportUI.md),
[`modGeneticDiversityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityServer.md),
[`modGeneticDiversityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modMarkerGeneticsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsServer.md),
[`modMarkerGeneticsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMarkerGeneticsUI.md),
[`modMatePairUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairUI.md),
[`modORIPReportingServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingServer.md),
[`modORIPReportingUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md),
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md),
[`modPedigreeUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md),
[`modPotentialParentsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md),
[`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md),
[`modPyramidServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidServer.md),
[`modPyramidUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidUI.md),
[`modSnapshotTrendsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSnapshotTrendsServer.md),
[`modSnapshotTrendsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSnapshotTrendsUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)
