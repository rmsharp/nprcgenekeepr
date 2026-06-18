# Convert internal column names to display or header names

Converts the column names of a Pedigree or Genetic value Report to
something more descriptive.

## Usage

``` r
headerDisplayNames(headers)
```

## Arguments

- headers:

  a character vector of column (header) names

## Value

Updated list of column names

## Examples

``` r
library(nprcgenekeepr)
headerDisplayNames(headers = c("id", "sire", "dam", "sex", "birth", "age"))
#> [1] "Ego ID"         "Sire ID"        "Dam ID"         "Sex"           
#> [5] "Birth Date"     "Age (in years)"
```
