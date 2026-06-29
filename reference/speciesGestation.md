# Per-species reproductive parameters

A lookup table mapping a species name to reproductive parameters used
across the package. It keys the gestation window in
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
through
[`getSpeciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md)
and the minimum breeding ages in the Genetic Value Analysis
unknown-parent mean-kinship correction through
[`getSpeciesMinBreedingAge`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md).
Species names are matched case- and whitespace-insensitively; any
species not present falls back to 210 days for gestation and 2 years for
the breeding ages. Rhesus gestation is 210 days (the historical
conservative bound; typical rhesus gestation is about 165 days, per
Vinson & Raboin 2015), and rhesus minimum breeding ages are male = 4,
female = 2.5. The table is populated for the common colony NHP species,
with gestation values as conservative upper bounds; making the values
user-configurable is a separate planned enhancement. Extend or adjust it
by editing `data-raw/speciesGestation.R` and re-running that script.

- species:

  – character species name (e.g. "RHESUS").

- gestation:

  – integer maximum gestation period in days (a conservative upper
  bound).

- minMaleBreedingAge:

  – numeric minimum age in years at which a male of the species can sire
  offspring.

- minFemaleBreedingAge:

  – numeric minimum age in years at which a female of the species can
  bear offspring.

## Usage

``` r
data(speciesGestation)
```

## Format

An object of class `data.frame` with 14 rows and 4 columns.

## Examples

``` r
library(nprcgenekeepr)
data("speciesGestation")
speciesGestation
#>                 species gestation minMaleBreedingAge minFemaleBreedingAge
#> 1                RHESUS       210                4.0                  2.5
#> 2            CYNOMOLGUS       170                4.0                  2.5
#> 3      JAPANESE MACAQUE       180                5.0                  4.0
#> 4    PIG-TAILED MACAQUE       175                4.0                  3.0
#> 5                BABOON       187                6.0                  4.0
#> 6                VERVET       170                4.0                  3.0
#> 7  AFRICAN GREEN MONKEY       170                4.0                  3.0
#> 8       SQUIRREL MONKEY       170                3.5                  2.5
#> 9       COMMON MARMOSET       145                1.0                  1.0
#> 10   COTTON-TOP TAMARIN       185                1.5                  1.5
#> 11           OWL MONKEY       140                2.0                  2.0
#> 12             CAPUCHIN       160                6.0                  4.0
#> 13           CHIMPANZEE       240               12.0                  8.0
#> 14               BONOBO       240               12.0                  8.0
```
