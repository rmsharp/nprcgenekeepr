# Look up the minimum breeding age (years) for one or more species and sexes

Maps each supplied (species, sex) pair to the minimum age in years at
which an animal of that species and sex can produce offspring, using the
[`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
lookup table (or a supplied `breedingTable`). Matching is case- and
whitespace-insensitive on both species and sex. Any species that is
missing, `NA`, an empty string, or not present in the table – and any
sex that is not `"M"` or `"F"` – falls back to `default` (2 years, the
legacy package-wide minimum parent age). Used by the Genetic Value
Analysis unknown-parent mean-kinship correction to form a focal animal's
contemporaneous breeding-age peer cohort. The bundled table is populated
for the common colony NHP species; the user-configurable override path
is a separate feature.

## Usage

``` r
getSpeciesMinBreedingAge(species, sex, breedingTable = NULL, default = 2)
```

## Arguments

- species:

  character vector of species names (may contain `NA`).

- sex:

  character vector of sexes (`"M"` or `"F"`); recycled to the length of
  `species` (or vice versa).

- breedingTable:

  optional data.frame with a character column `species` and numeric
  columns `minMaleBreedingAge` and `minFemaleBreedingAge` to use instead
  of the bundled
  [`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
  table. Defaults to `NULL`, which uses the bundled table.

- default:

  numeric fallback returned for species that are missing, `NA`, empty,
  or not found, and for a sex that is not `"M"`/`"F"`. Defaults to `2`.

## Value

a numeric vector of minimum breeding ages in years, the same length as
the longer of `species` and `sex`.

## Examples

``` r
getSpeciesMinBreedingAge("RHESUS", "M")
#> [1] 4
getSpeciesMinBreedingAge("RHESUS", "F")
#> [1] 2.5
getSpeciesMinBreedingAge(c("RHESUS", "UNICORN"), c("M", "F"))
#> [1] 4 2
```
