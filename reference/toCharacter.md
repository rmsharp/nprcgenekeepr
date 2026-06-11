# Force dataframe columns to character

Converts designated columns of a dataframe to character. Defaults to
converting columns `id`, `sire`, and `dam`.

## Usage

``` r
toCharacter(df, headers = c("id", "sire", "dam"))
```

## Arguments

- df:

  a dataframe where the first three columns can be coerced to character.

- headers:

  character vector with the columns to be converted to character class.
  Defaults to `c("id", "sire", "dam")`/

## Value

A dataframe with the specified columns converted to class "character"
for display with xtables (in shiny)

## Examples

``` r
library(nprcgenekeepr)
pedGood <- nprcgenekeepr::pedGood
names(pedGood) <- c("id", "sire", "dam", "sex", "birth")
class(pedGood[["id"]])
#> [1] "factor"
pedGood <- toCharacter(pedGood)
class(pedGood[["id"]])
#> [1] "character"
```
