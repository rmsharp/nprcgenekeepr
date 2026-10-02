# Force dataframe columns to character

Converts designated columns of a dataframe to character. Defaults to
converting columns `id`, `sire`, and `dam`.

## Usage

``` r
toCharacter(df, headers = c("id", "sire", "dam"))
```

## Arguments

- df:

  a dataframe. Columns named in `headers` are converted to character.

- headers:

  character vector with the names of the columns to be converted to
  character class. Names that are not columns of `df` are skipped
  silently. Defaults to `c("id", "sire", "dam")`.

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
