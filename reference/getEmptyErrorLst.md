# Creates an empty errorLst object

Creates an empty errorLst object

## Usage

``` r
getEmptyErrorLst()
```

## Value

An errorLst object with placeholders for error types found in a pedigree
file by `qcStudbook`.

## Examples

``` r
library(nprcgenekeepr)
getEmptyErrorLst()
#> $failedDatabaseConnection
#> character(0)
#> 
#> $missingColumns
#> character(0)
#> 
#> $invalidDateRows
#> character(0)
#> 
#> $suspiciousParents
#> data frame with 0 columns and 0 rows
#> 
#> $femaleSires
#> character(0)
#> 
#> $maleDams
#> character(0)
#> 
#> $sireAndDam
#> character(0)
#> 
#> $duplicateIds
#> character(0)
#> 
#> $invalidIdChars
#> character(0)
#> 
#> $changedCols
#> $changedCols$caseChange
#> character(0)
#> 
#> $changedCols$spaceRemoved
#> character(0)
#> 
#> $changedCols$periodRemoved
#> character(0)
#> 
#> $changedCols$underScoreRemoved
#> character(0)
#> 
#> $changedCols$egoToId
#> character(0)
#> 
#> $changedCols$egoidToId
#> character(0)
#> 
#> $changedCols$sireIdToSire
#> character(0)
#> 
#> $changedCols$damIdToDam
#> character(0)
#> 
#> $changedCols$birthdateToBirth
#> character(0)
#> 
#> $changedCols$deathdateToDeath
#> character(0)
#> 
#> $changedCols$recordstatusToRecordStatus
#> character(0)
#> 
#> $changedCols$fromcenterToFromCenter
#> character(0)
#> 
#> $changedCols$geographicoriginToGeographicOrigin
#> character(0)
#> 
#> 
#> attr(,"class")
#> [1] "list"             "nprcgenekeeprErr"
```
