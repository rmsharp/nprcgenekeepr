# Potential Parents Module - Server Function

Server logic for the Potential Parents module. On button press, it calls
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
against the current pedigree, flattens the result into a sortable table,
and exposes it for CSV download. The surface degrades gracefully when no
pedigree is loaded, when the pedigree lacks the `fromCenter`
colony-origin field, or when no in-colony animal has an unknown parent.

## Usage

``` r
modPotentialParentsServer(
  id,
  pedigree = NULL,
  minSireAge = NULL,
  minDamAge = NULL,
  gestationTable = NULL,
  gestationDefault = NULL
)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning the current pedigree data.frame.

- minSireAge:

  minimum age in years for a male to be proposed as a sire. May be a
  plain numeric, `NULL`, or a reactive returning either. `NULL` (the
  default) uses the species- and sex-specific breeding-age table default
  via
  [`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md).

- minDamAge:

  minimum age in years for a female to be proposed as a dam. Same forms
  and default as `minSireAge`, applied to females.

- gestationTable:

  optional species-to-gestation lookup passed to
  [`getSpeciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md)
  when defaulting the gestation window; `NULL` (the default) uses the
  bundled
  [`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
  table. Supplied at boot from the user-configurable species overrides,
  so a colony's CSV values drive the prefill default.

- gestationDefault:

  optional integer fallback (days) for a pedigree whose species is
  absent from `gestationTable`, passed through to the gestation prefill;
  `NULL` (the default) keeps the built-in 210. Supplied at boot from the
  user-configurable species overrides.

## Value

A list of reactive expressions:

- `potentialParents` - the raw `getPotentialParents` result (or `NULL`).

- `tableData` - the flattened results data.frame.

- `gestationDefault` - the species-keyed default gestation window (days)
  used to prefill the maximum-gestational-period input.

## See also

[`modPotentialParentsUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md)
for the user interface.

[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
for the underlying computation.

Other Shiny modules:
[`modBreedingGroupsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md),
[`modBreedingGroupsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsUI.md),
[`modGeneticDiversityServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityServer.md),
[`modGeneticDiversityUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticDiversityUI.md),
[`modGeneticValueServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md),
[`modGeneticValueUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md),
[`modGvAndBgDescServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescServer.md),
[`modGvAndBgDescUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modGvAndBgDescUI.md),
[`modInputServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md),
[`modInputUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md),
[`modORIPReportingServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingServer.md),
[`modORIPReportingUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modORIPReportingUI.md),
[`modPedigreeServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md),
[`modPedigreeUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md),
[`modPotentialParentsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md),
[`modPyramidServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidServer.md),
[`modPyramidUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modPyramidUI.md),
[`modSummaryStatsServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsServer.md),
[`modSummaryStatsUI()`](https://github.com/rmsharp/nprcgenekeepr/reference/modSummaryStatsUI.md)
