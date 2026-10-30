# Read a kinship overrides table from a file

Reads an outside-information kinship override table from a user-supplied
file into a data frame for
[`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md)
and
[`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md).
The expected long form is the output of
[`kinMatrix2LongForm`](https://github.com/rmsharp/nprcgenekeepr/reference/kinMatrix2LongForm.md):
columns `id1`, `id2`, and `kinship`, with a header row, so a user can
export the current matrix, edit a few rows, and feed it back. Excel
(`.xls`/`.xlsx`) and delimited text (`.csv`/`.txt`) files are both
accepted, mirroring
[`getGenotypes`](https://github.com/rmsharp/nprcgenekeepr/reference/getGenotypes.md).
Excel files are read with every column as text and then the `kinship`
column is converted to numbers, so an Excel file and a delimited text
file of the same table give the same result. If any value in that column
is not a number, the column is left as text and
[`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md)
stops, naming it.

## Usage

``` r
readKinshipOverrides(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of length one; path to the override file (typically
  the temporary `datapath` from a Shiny file upload).

- sep:

  column separator for delimited text files (default `","`). Ignored for
  Excel files.

## Value

A data frame of the rows read from `fileName` (typically with columns
`id1`, `id2`, and `kinship`). Validate it with
[`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md)
before use.

## Details

This reader does not validate structure or domain – that is
[`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md)'s
job. `kinship` is the kinship coefficient *f*, **not** the coefficient
of relatedness *r* (= 2*f* for non-inbred animals).

## Examples

``` r
csvFile <- tempfile(fileext = ".csv")
writeLines(c("id1,id2,kinship", "A1,A2,0.25", "A3,A4,0.125"), csvFile)
overrides <- readKinshipOverrides(fileName = csvFile)
overrides <- checkKinshipOverrides(overrides)
overrides
#>   id1 id2 kinship
#> 1  A1  A2   0.250
#> 2  A3  A4   0.125
unlink(csvFile)
```
