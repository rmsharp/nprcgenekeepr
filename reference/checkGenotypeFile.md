# Check genotype file

Checks to ensure the content and structure are appropriate for a
genotype file. These checks are simply based on expected columns and
legal domains. The function stops (an error, not a warning) when the
dataframe has fewer than three columns, when the first column name does
not contain `"id"` (any case), when any column is named `first` or
`second` (any case), or when an allele in columns 2 or 3 that reads as
an integer is above 10000 (it would collide with the integer codes
[`addGenotype`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)
assigns).

## Usage

``` r
checkGenotypeFile(genotype)
```

## Arguments

- genotype:

  dataframe with genotype data

## Value

The genotype dataframe, checked for the column count, the first column's
name and the allele range described above; no column types are checked.
The returned genotype file has the first column name forced to "id".

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::qcPed
ped <- ped[order(ped$id), ]
genotype <- data.frame(
  id = ped$id[50 + 1:20],
  first_name = paste0("first_name", 1:20),
  second_name = paste0("second_name", 1:20),
  stringsAsFactors = FALSE
)

## checkGenotypeFile disallows dataframe with < 3 columns
tryCatch(
  {
    checkGenotypeFile(genotype[, c("id", "first_name")])
  },
  warning = function(w) {
    cat("Warning produced")
  },
  error = function(e) {
    cat("Error produced")
  }
)
#> Error produced
```
