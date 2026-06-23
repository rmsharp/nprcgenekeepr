# Per-species reproductive parameters

A lookup table mapping a species name to reproductive parameters used
across the package. It keys the gestation window in
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
through
[`getSpeciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md)
(issue \#46 item 2) and the minimum breeding ages in the Genetic Value
Analysis unknown-parent mean-kinship correction through
[`getSpeciesMinBreedingAge`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md)
(issue \#9 Slice 2). Species names are matched case- and
whitespace-insensitively; any species not present falls back to 210 days
for gestation and 2 years for the breeding ages. Seeded with rhesus =
210-day gestation (the conservative bound used historically; typical
rhesus gestation is about 165 days, per Vinson & Raboin 2015) and rhesus
minimum breeding ages male = 4, female = 3. Generalizing this table to
all common colony NHP species and making the values user-configurable is
tracked as issue \#73. Extend it by adding rows in
`data-raw/speciesGestation.R` and re-running that script.

- species:

  – character species name (e.g. "RHESUS").

- gestation:

  – integer maximum gestation period in days (a conservative upper
  bound).

- minMaleBreedingAge:

  – integer minimum age in years at which a male of the species can sire
  offspring.

- minFemaleBreedingAge:

  – integer minimum age in years at which a female of the species can
  bear offspring.

## Usage

``` r
data(speciesGestation)
```

## Format

An object of class `data.frame` with 1 rows and 4 columns.

## Examples

``` r
library(nprcgenekeepr)
data("speciesGestation")
speciesGestation
#>   species gestation minMaleBreedingAge minFemaleBreedingAge
#> 1  RHESUS       210                  4                    3
```
