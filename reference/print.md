# print.summary.nprcgenekeepr print.summary.nprcgenekeeprGV

print.summary.nprcgenekeepr print.summary.nprcgenekeeprGV

## Usage

``` r
# S3 method for class 'summary.nprcgenekeeprErr'
print(x, ...)

# S3 method for class 'summary.nprcgenekeeprGV'
print(x, ...)
```

## Arguments

- x:

  object of class summary.nprcgenekeeprErr and class list

- ...:

  additional arguments for the `summary.default` statement

## Value

An object to send to the generic print function

object to send to generic print function

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
#> Founder Genome Equivalents: 2.68 +/- 0.14 
#> Live Offspring: 8 
#> High Value Individuals: 1 
#> Low Value Individuals: 3 
```
