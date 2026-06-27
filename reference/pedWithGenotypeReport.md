# Genetic-value report for pedWithGenotype

A list containing the output of `reportGV`.

## Usage

``` r
data(pedWithGenotypeReport)
```

## Format

An object of class `list` (inherits from `nprcgenekeeprGV`) of length
11.

## Source

pedWithGenotypeReport was made with pedWithGenotype as input into
reportGV with 10,000 iterations.

pedWithGenotypeReport is a simple example report for use in examples and
unit tests. It was created using the following commands.

- set_seed(10)

- pedWithGenotypeReport \<- reportGV(nprcgenekeepr::pedWithGenotype,
  guIter = 10000)

- save(pedWithGenotypeReport, file = "data/pedWithGenotypeReport.RData")

## Examples

``` r
pedWithGenotypeReport <- nprcgenekeepr::pedWithGenotypeReport
```
