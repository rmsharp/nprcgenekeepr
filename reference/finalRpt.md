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

## Details

It is a list of three data frames: `highGu`, `lowMk` and `lowVal`. Each
has the 13 columns `id`, `sex`, `age`, `birth`, `exit`, `population`,
`first_name`, `second_name`, `indivMeanKin`, `zScores`, `gu`,
`totalOffspring` and `livingOffspring`.

## Examples

``` r
library(nprcgenekeepr)
data("finalRpt")
finalRpt <- rankSubjects(finalRpt)
```
