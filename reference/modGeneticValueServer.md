# Genetic Value Analysis Module - Server Function

Genetic Value Analysis Module - Server Function

## Usage

``` r
modGeneticValueServer(id, pedigree)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning pedigree data frame.

## Value

List with `geneticValues`, `topAnimals`, `nAnalyzed`, `kinshipMatrix`,
`founderStats`, `maleFounders`, and `femaleFounders`.

## References

Lacy, R.C. (1989) *Zoo Biology*, **8**, 111-123.

## See also

[`modGeneticValueUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueUI.md)

[`modBreedingGroupsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modBreedingGroupsServer.md)
for using results.
