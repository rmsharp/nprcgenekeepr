# Write copy of dataframes to either CSV, TXT, or Excel file

Takes a list of dataframes and creates a file based on the list name of
the dataframe and the extension for the file type. The extension is the
value of `fileType` itself, so Excel files get the extension `.excel`,
not `.xlsx`. The list must be named; an unnamed list gives files without
a base name.

## Usage

``` r
saveDataframesAsFiles(dfList, baseDir, fileType = "csv")
```

## Arguments

- dfList:

  named list of dataframes to be stored as files. The names of the list
  supply the file names.

- baseDir:

  character vector of length one with the directory path. The directory
  must already exist.

- fileType:

  character vector of length one with possible values of `"txt"`,
  `"csv"`, or `"excel"`. Default value is `"csv"`.

## Value

A character vector of the path names of the files saved, built as
`baseDir`, a slash, the list name, a period and `fileType`. `baseDir` is
used exactly as supplied, so a relative path stays relative.

## Examples

``` r
library(nprcgenekeepr)
dfList <- list(
  lacy1989Ped = nprcgenekeepr::lacy1989Ped,
  pedGood = nprcgenekeepr::pedGood
)
## Write each data frame to a CSV file under a temporary directory.
files <- saveDataframesAsFiles(dfList,
  baseDir = tempdir(), fileType = "csv"
)
basename(files)
#> [1] "lacy1989Ped.csv" "pedGood.csv"    
```
