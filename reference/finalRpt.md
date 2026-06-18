# Genetic-value report list prior to ranking

A list object created from the list object *rpt* prepared by `reportGV`.
It is created inside `orderReport`. This version is at the state just
prior to calling `rankSubjects` inside `orderReport`.

## Usage

``` r
data(finalRpt)
```

## Format

An object of class `list` of length 3.

## Examples

``` r
library(nprcgenekeepr)
data("finalRpt")
finalRpt <- rankSubjects(finalRpt)
```
