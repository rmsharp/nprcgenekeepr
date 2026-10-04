# Create example pedigree and ID-list CSV files

Creates a folder named `ExamplePedigrees` under the R session temporary
directory (as returned by
[`tempdir()`](https://rdrr.io/r/base/tempfile.html)) if it does not
already exist. It then proceeds to write each example data set into a
CSV file named based on the name of the data set. The data sets include
pedigrees and related lists, such as `focalAnimals`, `qcBreeders`,
`pedWithGenotype`, and `qcPed`.

## Usage

``` r
createExampleFiles()
```

## Value

A character vector of the full path names of the files written.

## Examples

``` r
library(nprcgenekeepr)
files <- createExampleFiles()
#> Example pedigree files examplePedigree, focalAnimals, lacy1989Ped, pedDuplicateIds, pedFemaleSireMaleDam, pedGood, pedInvalidDates, pedMissingBirth, pedOne, pedSameMaleIsSireAndDam, pedSix, pedWithGenotype, qcBreeders, qcPed, and smallPed will be created in /tmp/RtmpdOFBxf/ExamplePedigrees.
```
