# Write copy of nprcgenekeepr::examplePedigree into a file

Uses `examplePedigree` data structure to create an example data file.
Files of type `"csv"` and `"txt"` are silently overwritten if they
already exist. A file of type `"excel"` is never overwritten; if the
file already exists, an error is signaled.

## Usage

``` r
makeExamplePedigreeFile(
  file = file.path(tempdir(), paste0("examplePedigree.", c(csv = "csv", txt = "txt",
    excel = "xlsx")[[fileType]])),
  fileType = "csv"
)
```

## Arguments

- file:

  character vector of length one providing the file name. The default
  file, in the session's temporary directory, is `examplePedigree.csv`,
  `examplePedigree.txt` or `examplePedigree.xlsx`, according to
  `fileType`.

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
