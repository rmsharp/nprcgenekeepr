# finalRpt is a list object created from the list object *rpt* prepared by `reportGV`. It is created inside `orderReport`. This version is at the state just prior to calling `rankSubjects` inside `orderReport`.

finalRpt is a list object created from the list object *rpt* prepared by
`reportGV`. It is created inside `orderReport`. This version is at the
state just prior to calling `rankSubjects` inside `orderReport`.

## Usage

``` r
finalRpt
```

## Format

An object of class `list` of length 3.

## Examples

``` r
library(nprcgenekeepr)
data("finalRpt")
finalRpt <- rankSubjects(finalRpt)
```
