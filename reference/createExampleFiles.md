# Creates a folder with CSV files containing example pedigrees and ID lists used to demonstrate the package

Creates a folder named `~/tmp/ExamplePedigrees` if it does not already
exist. It then proceeds to write each example pedigree into a CSV file
named based on the name of the example pedigree.

## Usage

``` r
createExampleFiles()
```

## Value

A vector of the names of the files written.

## Examples

``` r
library(nprcgenekeepr)
files <- createExampleFiles()
#> Example pedigree files examplePedigree, focalAnimals, lacy1989Ped, pedDuplicateIds, pedFemaleSireMaleDam, pedGood, pedInvalidDates, pedMissingBirth, pedOne, pedSameMaleIsSireAndDam, pedSix, pedWithGenotype, qcBreeders, qcPed, and smallPed will be created in /tmp/Rtmp6sSQI7/ExamplePedigrees.
```
