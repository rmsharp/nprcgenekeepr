# Write copy of nprcgenekeepr::examplePedigree into a file

Uses `examplePedigree` data structure to create an example data file

## Usage

``` r
makeExamplePedigreeFile(
  file = file.path(tempdir(), "examplePedigree.csv"),
  fileType = "csv"
)
```

## Arguments

- file:

  character vector of length one providing the file name

- fileType:

  character vector of length one with possible values of `"txt"`,
  `"csv"`, or `"excel"`. Default value is `"csv"`.

## Value

Full path name of file saved.

## Examples

``` r
library(nprcgenekeepr)
pedigreeFile <- makeExamplePedigreeFile()
```
