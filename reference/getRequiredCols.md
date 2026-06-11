# Get required column names for a studbook.

Pedigree curation function

## Usage

``` r
getRequiredCols()
```

## Value

A character vector of the required columns that can be in a studbook.
The required columns are as follows:

- {id} {– character vector with unique identifier for an individual}

- {sire} {– character vector with unique identifier for an individual's
  father (`NA` if unknown).}

- {dam} {– character vector with unique identifier for an individual's
  mother (`NA` if unknown).}

- {sex} {– factor {levels: "M", "F", "U"} Sex specifier for an
  individual}

- {birth} {– Date or `NA` (optional) with the individual's birth date}

## Examples

``` r
library(nprcgenekeepr)
getRequiredCols()
#> [1] "id"    "sire"  "dam"   "sex"   "birth"
```
