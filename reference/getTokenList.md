# Get tokens from a character vector of lines

Get tokens from a character vector of lines

## Usage

``` r
getTokenList(lines)
```

## Arguments

- lines:

  character vector with text from configuration file

## Value

First right and left space trimmed token from first character vector
element.

## Examples

``` r
lines <- c(
  "center = \"SNPRC\"",
  " baseUrl = \"https://boomer.txbiomed.local:8080/labkey\"",
  " schemaName = \"study\"", " folderPath = \"/SNPRC\"",
  " queryName = \"demographics\"",
  "lkPedColumns = (\"Id\", \"gender\", \"birth\", \"death\",",
  "              \"lastDayAtCenter\", \"dam\", \"sire\")",
  "mapPedColumns = (\"id\", \"sex\", \"birth\", \"death\", ",
  "  \"exit\", \"dam\", \"sire\")"
)
lkVec <- c(
  "Id", "gender", "birth", "death",
  "lastDayAtCenter", "dam", "sire"
)
mapVec <- c("id", "sex", "birth", "death", "exit", "dam", "sire")
tokenList <- getTokenList(lines)
params <- tokenList$param
tokenVectors <- tokenList$tokenVec
```
