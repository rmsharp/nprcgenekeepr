# Create Genetic Summary Statistics HTML Table

Generates an HTML table displaying summary statistics (Min, Q1, Mean,
Median, Q3, Max) for mean kinship and genome uniqueness values.

## Usage

``` r
makeGeneticSummaryTable(geneticValues)
```

## Arguments

- geneticValues:

  data.frame containing genetic value columns:

  - `meanKinship` - Mean kinship coefficients

  - `genomeUniqueness` - Genome uniqueness values

## Value

Character string containing HTML table markup.

## See also

[`makeFounderStatsTable`](https://github.com/rmsharp/nprcgenekeepr/reference/makeFounderStatsTable.md)
for founder statistics

## Examples

``` r
if (FALSE) { # \dontrun{
gv <- data.frame(
  meanKinship = c(0.1, 0.2, 0.3, 0.4, 0.5),
  genomeUniqueness = c(0.9, 0.8, 0.7, 0.6, 0.5)
)
html <- makeGeneticSummaryTable(gv)
} # }
```
