# Create Founder Statistics HTML Table

Copyright(c) 2017-2025 R. Mark Sharp This file is part of nprcgenekeepr

## Usage

``` r
makeFounderStatsTable(founderStats)
```

## Arguments

- founderStats:

  list containing founder statistics with elements:

  - `total` - Total number of known founders

  - `nMaleFounders` - Number of male founders

  - `nFemaleFounders` - Number of female founders

  - `fe` - Founder equivalents

  - `fg` - Founder genome equivalents

  - `fgSE` - (optional) sampling standard error of `fg`; when finite it
    is shown inline as `FG +/- SE`

## Value

Character string containing HTML table markup.

## Details

Generates an HTML table displaying founder statistics including counts
of known founders, male founders, female founders, founder equivalents
(FE), and founder genome equivalents (FG).

## See also

[`makeGeneticSummaryTable`](https://github.com/rmsharp/nprcgenekeepr/reference/makeGeneticSummaryTable.md)
for genetic value summary

[`calcFE`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md)
for founder equivalents calculation

[`calcFG`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md)
for founder genome equivalents

## Examples

``` r
if (FALSE) { # \dontrun{
stats <- list(
  total = 50,
  nMaleFounders = 20,
  nFemaleFounders = 30,
  fe = 25.5,
  fg = 22.3
)
html <- makeFounderStatsTable(stats)
} # }
```
