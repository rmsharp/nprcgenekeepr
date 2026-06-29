# Copyright(c) 2017-2026 R. Mark Sharp This file is part of nprcgenekeepr Look up the maximum gestation period (days) for one or more species

Maps each supplied species name to a conservative upper bound on the
number of days from conception to birth, using the
[`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
lookup table (or a supplied `gestationTable`). Matching is case- and
whitespace-insensitive. Any species that is missing, `NA`, an empty
string, or not present in the table falls back to `default` (210 days,
the conservative rhesus bound). Used by
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
to key its gestation window on the first-class `species` pedigree
column.

## Usage

``` r
getSpeciesGestation(species, gestationTable = NULL, default = 210L)
```

## Arguments

- species:

  character vector of species names (may contain `NA`).

- gestationTable:

  optional data.frame with a character column `species` and an integer
  column `gestation` to use instead of the bundled
  [`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
  table. Defaults to `NULL`, which uses the bundled table.

- default:

  integer fallback returned for species that are missing, `NA`, empty,
  or not found in the table. Defaults to `210L`.

## Value

an integer vector of gestation-period day bounds, the same length and
order as `species`.

## Examples

``` r
getSpeciesGestation("RHESUS")
#> [1] 210
getSpeciesGestation(c("RHESUS", "UNICORN", NA))
#> [1] 210 210 210
```
