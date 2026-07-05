# Check an error list for non-empty fields

Check an error list for non-empty fields

## Usage

``` r
checkErrorLst(errorLst)
```

## Arguments

- errorLst:

  list with fields for each type of error detectable by `qcStudbook`.

## Value

Returns FALSE if all fields are empty or the list is NULL otherwise
TRUE.

## Examples

``` r
errorLst <- qcStudbook(nprcgenekeepr::pedFemaleSireMaleDam,
  reportErrors = TRUE
)
checkErrorLst(errorLst)
#> [1] TRUE
```
