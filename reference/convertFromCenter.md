# Convert from-center information to a logical value

Part of Pedigree Curation

## Usage

``` r
convertFromCenter(fromCenter)
```

## Arguments

- fromCenter:

  character or logical vector or NA indicating whether or not the animal
  is from the center.

## Value

A logical vector specifying TRUE if an animal is from the center
otherwise FALSE.

## Examples

``` r
original <- c(
  "y", "yes", "Y", "Yes", "YES", "n", "N", "No", "NO", "no",
  "t", "T", "True", "true", "TRUE", "f", "F", "false", "False",
  "FALSE"
)
convertFromCenter(original)
#>  [1]  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE  TRUE  TRUE
#> [13]  TRUE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE
```
