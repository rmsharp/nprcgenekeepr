# Write copy of dataframes to either CSV, TXT, or Excel file.

Takes a list of dataframes and creates a file based on the list name of
the dataframe and the extension for the file type.

## Usage

``` r
saveDataframesAsFiles(dfList, baseDir, fileType = "csv")
```

## Arguments

- dfList:

  list of dataframes to be stored as files. `"txt"`, `"csv"`, or
  `"xlsx"`. Default value is `"csv"`.

- baseDir:

  character vector of length on with the directory path.

- fileType:

  character vector of length one with possible values of `"txt"`,
  `"csv"`, or `"xlsx"`. Default value is `"csv"`.

## Value

Full path name of files saved.
