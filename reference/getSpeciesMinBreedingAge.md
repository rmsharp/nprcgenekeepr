# Copyright(c) 2017-2026 R. Mark Sharp This file is part of nprcgenekeepr Look up the minimum breeding age (years) for one or more species and sexes

Maps each supplied (species, sex) pair to the minimum age in years at
which an animal of that species and sex can produce offspring, using the
[`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
lookup table (or a supplied `breedingTable`). Matching is case- and
whitespace-insensitive on both species and sex. Any species that is
missing, `NA`, an empty string, or not present in the table – and any
sex that is not `"M"` or `"F"` – falls back to `default` (2 years, the
legacy package-wide minimum parent age). Used by the Genetic Value
Analysis unknown-parent mean-kinship correction to form a focal animal's
contemporaneous breeding-age peer cohort (issue \#9 Slice 2).
Generalizing the seeded values to all common colony NHP species and
making them user-configurable is tracked as issue \#73.

## Usage

``` r
getSpeciesMinBreedingAge(species, sex, breedingTable = NULL, default = 2L)
```

## Arguments

- species:

  character vector of species names (may contain `NA`).

- sex:

  character vector of sexes (`"M"` or `"F"`); recycled to the length of
  `species` (or vice versa).

- breedingTable:

  optional data.frame with a character column `species` and integer
  columns `minMaleBreedingAge` and `minFemaleBreedingAge` to use instead
  of the bundled
  [`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
  table. Defaults to `NULL`, which uses the bundled table.

- default:

  integer fallback returned for species that are missing, `NA`, empty,
  or not found, and for a sex that is not `"M"`/`"F"`. Defaults to `2L`.

## Value

an integer vector of minimum breeding ages in years, the same length as
the longer of `species` and `sex`.

## Examples

``` r
getSpeciesMinBreedingAge("RHESUS", "M")
#> [1] 4
getSpeciesMinBreedingAge("RHESUS", "F")
#> [1] 3
getSpeciesMinBreedingAge(c("RHESUS", "UNICORN"), c("M", "F"))
#> [1] 4 2
```
