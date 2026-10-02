# Get pedigree from file

Get pedigree from file

## Usage

``` r
getPedigree(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of temporary file path.

- sep:

  column separator in CSV file. It is ignored for Excel (xls and xlsx)
  files.

## Value

A data.frame of the pedigree as read from the file, with no quality
control applied (see
[`qcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)).
Every column read from an Excel file is returned as character.

## Examples

``` r
library(nprcgenekeepr)
ped <- getPedigree(fileName = system.file("testdata", "qcPed.csv",
  package = "nprcgenekeepr"
))
```
