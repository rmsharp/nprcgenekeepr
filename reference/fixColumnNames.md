# Standardize pedigree column names

Standardizing converts the names to lower case, removes spaces, periods
and underscores, and then renames by substring: `egoid` and `ego` become
`id`, `sireid` becomes `sire`, `damid` becomes `dam`, `birthdate`
becomes `birth` and `deathdate` becomes `death`. `recordstatus`,
`fromcenter` and `geographicorigin` are restored to their camel case
forms. The headers `first_name` and `second_name` keep their underscore.
The matching is unanchored, so any name that contains one of these
strings is changed (for example, `category` becomes `catidry`).

## Usage

``` r
fixColumnNames(orgCols, errorLst)
```

## Arguments

- orgCols:

  character vector with ordered list of column names found in a pedigree
  file.

- errorLst:

  list object with places to store the various column name changes, as
  returned by
  [`getEmptyErrorLst`](https://github.com/rmsharp/nprcgenekeepr/reference/getEmptyErrorLst.md).

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
#> $invalidPlaceholderRows
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
