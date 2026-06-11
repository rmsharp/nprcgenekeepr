# Creates a pyramid plot of the pedigree provided.

The pedigree provided must have the following columns: `sex` and `age`.
This needs to be augmented to allow pedigrees structures that are
provided by the nprcgenekeepr package.

## Usage

``` r
getPyramidPlot(
  ped = NULL,
  binWidth = 2L,
  ageUnit = "years",
  colorScheme = "default",
  showCounts = TRUE,
  ageLabelCex = 1
)
```

## Arguments

- ped:

  dataframe with pedigree data.

- binWidth:

  numeric bin width for age groups (default 2).

- ageUnit:

  character either "years" (default) or "months".

- colorScheme:

  character color scheme: "default" (blue/pink) or "viridis"
  (colorblind-friendly).

- showCounts:

  logical whether to show count values on bars (default TRUE).

- ageLabelCex:

  numeric expansion factor for age labels (default 1.0).

## Value

The return value of par("mar") when the function was called.

## Examples

``` r
library(nprcgenekeepr)
data(qcPed)
getPyramidPlot(qcPed)

#> 15 15 
#> [1] 5.1 4.1 4.1 2.1
getPyramidPlot(qcPed, binWidth = 5, colorScheme = "viridis")

#> 15 15 
#> [1] 5.1 4.1 4.1 2.1
```
