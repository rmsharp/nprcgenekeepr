# Find date errors and convert dates in a pedigree

Finds date errors in columns defined in `convertDate` as dates and
converts date strings to `Date` objects.

## Usage

``` r
getDateErrorsAndConvertDatesInPed(sb, errorLst)
```

## Arguments

- sb:

  A dataframe containing a table of pedigree and demographic
  information.

- errorLst:

  object with placeholders for error types found in a pedigree file by
  `qcStudbook` through the functions it calls.

## Value

A list with the pedigree, `sb`, and the `errorLst` with invalid date
rows (`errorLst$invalidDateRows`)

## Details

If there are no errors that prevent the calculation of exit dates, they
are calculated and added to the pedigree otherwise the pedigree is not
updated.

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::pedInvalidDates
ped
#>   id sire  dam sex      birth
#> 1 s1 <NA> <NA>   M 2000-07-18
#> 2 d1 <NA> <NA>   F 2003-04-13
#> 3 s2 <NA> <NA>   M  205-06-19
#> 4 d2 <NA> <NA>   F 2002-16-22
#> 5 o1   s1   d1   F 2015-02-04
#> 6 o2   s1   d2   F 2009-03-17
#> 7 o3   s2   d2   F 2012-04-11
#> 8 o4   s2   d2   M 2008-04-13
errorLst <- getEmptyErrorLst()
colNamesAndErrors <- fixColumnNames(names(ped), errorLst)
names(ped) <- colNamesAndErrors$newColNames
pedAndErrors <- getDateErrorsAndConvertDatesInPed(ped, errorLst)
pedAndErrors$sb
#>   id sire  dam sex      birth exit
#> 1 s1 <NA> <NA>   M 2000-07-18 <NA>
#> 2 d1 <NA> <NA>   F 2003-04-13 <NA>
#> 3 s2 <NA> <NA>   M       <NA> <NA>
#> 4 d2 <NA> <NA>   F       <NA> <NA>
#> 5 o1   s1   d1   F 2015-02-04 <NA>
#> 6 o2   s1   d2   F 2009-03-17 <NA>
#> 7 o3   s2   d2   F 2012-04-11 <NA>
#> 8 o4   s2   d2   M 2008-04-13 <NA>
pedAndErrors$errorLst
#> $failedDatabaseConnection
#> character(0)
#> 
#> $missingColumns
#> character(0)
#> 
#> $invalidDateRows
#> [1] "3" "4"
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
