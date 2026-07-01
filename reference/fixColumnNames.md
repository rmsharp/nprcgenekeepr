# Standardize pedigree column names

Standardize pedigree column names

## Usage

``` r
fixColumnNames(orgCols, errorLst)
```

## Arguments

- orgCols:

  character vector with ordered list of column names found in a pedigree
  file.

- errorLst:

  list object with places to store the various column name changes.

## Value

A list object with `newColNames` and `errorLst` with a record of all
changes made.

## Examples

``` r
library(nprcgenekeepr)
fixColumnNames(c("Sire_ID", "EGO", "DAM", "Id", "birth_date"),
  errorLst = getEmptyErrorLst()
)
#> $newColNames
#> [1] "sire"  "id"    "dam"   "id"    "birth"
#> 
#> $errorLst
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
#> [1] "Sire_ID, EGO, DAM, and Id to sire_id, ego, dam, and id"
#> 
#> $changedCols$spaceRemoved
#> character(0)
#> 
#> $changedCols$periodRemoved
#> character(0)
#> 
#> $changedCols$underScoreRemoved
#> [1] "sire_id and birth_date to sireid and birthdate"
#> 
#> $changedCols$egoToId
#> [1] "ego to id"
#> 
#> $changedCols$egoidToId
#> character(0)
#> 
#> $changedCols$sireIdToSire
#> [1] "sireid to sire"
#> 
#> $changedCols$damIdToDam
#> character(0)
#> 
#> $changedCols$birthdateToBirth
#> [1] "birthdate to birth"
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
#> 
```
