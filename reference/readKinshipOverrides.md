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

## Usage

``` r
readKinshipOverrides(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of length one; path to the override file (typically
  the temporary `datapath` from a Shiny file upload).

- sep:

  column separator for delimited text files (default `","`).

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
if (FALSE) { # \dontrun{
overrides <- readKinshipOverrides(fileName = "kinship_overrides.csv")
overrides <- checkKinshipOverrides(overrides)
} # }
```
