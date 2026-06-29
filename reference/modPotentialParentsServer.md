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
  minParentAge = 2,
  gestationTable = NULL,
  gestationDefault = NULL
)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning the current pedigree data.frame.

- minParentAge:

  numeric minimum age in years for an animal to be a parent. Defaults to
  2 (the QC default).

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
