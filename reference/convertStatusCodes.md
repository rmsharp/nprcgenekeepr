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
`DECEASED`, `SHIPPED`, and `UNKNOWN`.

## Examples

``` r
library(nprcgenekeepr)
original <- c(
  "A", "alive", "Alive", "1", "S", "Sale", "sold", "shipped",
  "D", "d", "dead", "died", "deceased", "2",
  "shiped", "3", "U", "4", "unknown", NA,
  "Unknown", "H", "hermaphrodite", "U", "Unknown", "4"
)
convertStatusCodes(original)
#>  [1] ALIVE    ALIVE    ALIVE    ALIVE    SHIPPED  SHIPPED  SHIPPED  SHIPPED 
#>  [9] DECEASED DECEASED DECEASED DECEASED DECEASED DECEASED SHIPPED  SHIPPED 
#> [17] UNKNOWN  UNKNOWN  UNKNOWN  UNKNOWN  UNKNOWN  <NA>     <NA>     UNKNOWN 
#> [25] UNKNOWN  UNKNOWN 
#> Levels: ALIVE DECEASED SHIPPED UNKNOWN
```
