# Convert status indicators to a standardized code

Part of Pedigree Curation

## Usage

``` r
convertStatusCodes(status)
```

## Arguments

- status:

  character vector or NA. Flag indicating an individual's status as
  alive, dead, sold, etc.

## Value

A factor vector of the standardized status codes with levels: `ALIVE`,
`DECEASED`, `SHIPPED`, and `UNKNOWN`. A value that is not recognized
becomes `NA`, not `UNKNOWN`.

## Details

Case is ignored, but spaces are not trimmed. The recognized codes are
`ALIVE`, `A`, `1` for alive; `DECEASED`, `DEAD`, `DIED`, `D`, `2` for
deceased; `SHIPPED`, `SHIPED`, `SOLD`, `SALE`, `S`, `3` for shipped; and
`UNKNOWN`, `U`, `4` or `NA` for unknown.

## Examples

``` r
library(nprcgenekeepr)
original <- c(
  "A", "alive", "Alive", "1", "S", "Sale", "sold", "shipped",
  "D", "d", "dead", "died", "deceased", "2",
  "shiped", "3", "U", "4", "unknown", NA,
  "Unknown", "U", "Unknown", "4"
)
## A value that is not recognized becomes NA
convertStatusCodes("hermaphrodite")
#> [1] <NA>
#> Levels: ALIVE DECEASED SHIPPED UNKNOWN
convertStatusCodes(original)
#>  [1] ALIVE    ALIVE    ALIVE    ALIVE    SHIPPED  SHIPPED  SHIPPED  SHIPPED 
#>  [9] DECEASED DECEASED DECEASED DECEASED DECEASED DECEASED SHIPPED  SHIPPED 
#> [17] UNKNOWN  UNKNOWN  UNKNOWN  UNKNOWN  UNKNOWN  UNKNOWN  UNKNOWN  UNKNOWN 
#> Levels: ALIVE DECEASED SHIPPED UNKNOWN
```
