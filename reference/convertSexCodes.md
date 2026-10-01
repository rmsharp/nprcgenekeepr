# Convert a sex indicator to a standardized code

Part of Pedigree Curation

## Usage

``` r
convertSexCodes(sex, ignoreHerm = TRUE)
```

## Arguments

- sex:

  character vector or factor of sex codes (see above) for individuals;
  any other value is treated as unknown.

- ignoreHerm:

  logical flag indicating if hermaphrodites should be treated as unknown
  sex ("U"), default is `TRUE`.

## Value

A single factor with levels `F`, `M`, `H` and `U` holding the
standardized sex codes after transformation from non-standard codes.
Level `H` is used only when `ignoreHerm = FALSE`.

## Details

Standard sex codes are

- `F` – replacing "FEMALE" or "2"

- `M` – replacing "MALE" or "1"

- `H` – replacing "HERMAPHRODITE" or "4", if `ignoreHerm` == FALSE

- `U` – replacing "HERMAPHRODITE" or "4", if `ignoreHerm` == TRUE

- `U` – replacing "UNKNOWN" or "3"

- `U` – replacing a missing, blank or unrecognized value

Case and any spaces around a code are ignored, so `" male "` and `"M "`
both become `M`.

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
