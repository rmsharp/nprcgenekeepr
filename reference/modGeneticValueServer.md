# Genetic Value Analysis Module - Server Function

Genetic Value Analysis Module - Server Function

## Usage

``` r
modGeneticValueServer(id, pedigree, speciesOverrides = reactive(NULL))
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning pedigree data frame.

- speciesOverrides:

  reactive returning the user-configurable species overrides loaded at
  boot by
  [`loadSpeciesOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSpeciesOverrides.md)
  (a list with `breedingTable`, `gestationTable`, `breedingAgeDefault`,
  `gestationDefault`), or `NULL`. Threaded into
  [`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).
  Defaults to `reactive(NULL)` so no config file means bundled behavior.

## Value

List with `geneticValues`, `topAnimals`, `nAnalyzed`, `kinshipMatrix`,
`founderStats`, `maleFounders`, and `femaleFounders`.

## References

Lacy, R.C. (1989) *Zoo Biology*, **8**, 111-123.

## See also

[`modGeneticValueUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md)

[`modBreedingGroupsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md)
for using results.
