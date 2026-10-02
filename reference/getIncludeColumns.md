# Get the superset of report-inclusion columns

Part of Genetic Value Functions

## Usage

``` r
getIncludeColumns()
```

## Value

A character vector of the ten columns kept in genetic-value reports
(`id`, `sex`, `age`, `birth`, `exit`, `population`, `condition`,
`origin`, `first_name` and `second_name`). It is not the set of columns
a pedigree file may contain; that is returned by
[`getPossibleCols`](https://github.com/rmsharp/nprcgenekeepr/reference/getPossibleCols.md).

## Details

Replaces INCLUDE.COLUMNS data statement.

## Examples

``` r
getIncludeColumns()
#>  [1] "id"          "sex"         "age"         "birth"       "exit"       
#>  [6] "population"  "condition"   "origin"      "first_name"  "second_name"
```
