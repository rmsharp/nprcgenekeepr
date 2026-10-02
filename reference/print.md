# Print an nprcgenekeepr summary object

Print an nprcgenekeepr summary object

## Usage

``` r
# S3 method for class 'summary.nprcgenekeeprErr'
print(x, ...)

# S3 method for class 'summary.nprcgenekeeprGV'
print(x, ...)
```

## Arguments

- x:

  object of class summary.nprcgenekeeprErr (from
  [`summary()`](https://rdrr.io/r/base/summary.html) of a studbook error
  list) or summary.nprcgenekeeprGV (from
  [`summary()`](https://rdrr.io/r/base/summary.html) of a genetic value
  report)

- ...:

  further arguments passed to the
  [`print()`](https://rdrr.io/r/base/print.html) call for the
  suspicious-parents table (and ignored by the GV method)

## Value

The summary object, returned invisibly after it is printed.

The summary object, returned invisibly after it is printed.

## Examples

``` r
library(nprcgenekeepr)
errorLst <- qcStudbook(nprcgenekeepr::pedInvalidDates,
  reportChanges = TRUE, reportErrors = TRUE
)
summary(errorLst)
#> Error: There are 2 rows having an invalid date. The rows having an invalid date are: 3 and 4.
#> 
#> Please check and correct the pedigree file.
#>  
library(nprcgenekeepr)
ped <- nprcgenekeepr::pedGood
ped <- suppressWarnings(qcStudbook(ped, reportErrors = FALSE))
summary(reportGV(ped, guIter = 10))
#> The genetic value report 
#> Individuals in Pedigree: 8 
#> Male Founders: 2
#> Female Founders: 2
#> Total Founders: 4 
#> Founder Equivalents: 3.56 
#> Founder Genome Equivalents: 2.82 +/- 0.15 
#> Live Offspring: 8 
#> High Value Individuals: 1 
#> Low Value Individuals: 3 
```
