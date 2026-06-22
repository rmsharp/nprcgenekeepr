# Per-species maximum gestation period (days)

A lookup table mapping a species name to a conservative upper bound on
the number of days from conception to birth. It keys the gestation
window in
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
through
[`getSpeciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md)
(issue \#46 item 2). Species names are matched case- and whitespace-
insensitively; any species not present falls back to 210 days. Seeded
with rhesus = 210 (the conservative bound used historically; typical
rhesus gestation is about 165 days, per Vinson & Raboin 2015). Extend it
by adding rows in `data-raw/speciesGestation.R` and re-running that
script.

- species:

  – character species name (e.g. "RHESUS").

- gestation:

  – integer maximum gestation period in days (a conservative upper
  bound).

## Usage

``` r
data(speciesGestation)
```

## Format

An object of class `data.frame` with 1 rows and 2 columns.

## Examples

``` r
library(nprcgenekeepr)
data("speciesGestation")
speciesGestation
#>   species gestation
#> 1  RHESUS       210
```
