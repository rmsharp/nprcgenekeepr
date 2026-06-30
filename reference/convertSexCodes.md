# Converts a sex indicator for an individual to a standardized code

Part of Pedigree Curation

## Usage

``` r
convertSexCodes(sex, ignoreHerm = TRUE)
```

## Arguments

- sex:

  factor with levels: "M", "F", "U". Sex specifier for an individual.

- ignoreHerm:

  logical flag indicating if hermaphrodites should be treated as unknown
  sex ("U"), default is `TRUE`.

## Value

A vector of factors representing standardized sex codes after
transformation from non-standard codes.

## Details

Standard sex codes are

- `F` – replacing "FEMALE" or "2"

- `M` – replacing "MALE" or "1"

- `H` – replacing "HERMAPHRODITE" or "4", if ignore.herm == FALSE

- `U` – replacing "HERMAPHRODITE" or "4", if ignore.herm == TRUE

- `U` – replacing "UNKNOWN" or "3"

## Examples

``` r
library(nprcgenekeepr)
original <- c(
  "m", "male", "1", "MALE", "M", "F", "f", "female",
  "FemAle", "U", "Unknown", "H", "hermaphrodite",
  "U", "Unknown", "3", "4"
)
sexCodes <- convertSexCodes(original)
sexCodes
#>  [1] M M M M M F F F F U U U U U U U U
#> Levels: F M H U
```
