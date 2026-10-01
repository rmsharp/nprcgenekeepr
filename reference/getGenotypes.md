# Get genotypes from file

Get genotypes from file

## Usage

``` r
getGenotypes(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of length one: the path of a delimited text file or
  an Excel (`xls`/`xlsx`) file.

- sep:

  column separator in a delimited text file; ignored for an Excel file.

## Value

The file's contents as an unchecked dataframe (column names are not
changed). In a delimited text file an empty string and `"NA"` are read
as `NA`. Pass the result to
[`checkGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkGenotypeFile.md)
to make it compatible with the other functions in this package.

## Examples

``` r
library(nprcgenekeepr)
pedCsv <- getGenotypes(fileName = system.file("testdata", "qcPed.csv",
  package = "nprcgenekeepr"
))
```
