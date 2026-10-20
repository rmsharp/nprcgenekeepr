# Get tokens from a character vector of lines

Reads the lines of an nprcgenekeepr configuration file. The term before
each equals sign names a setting and the terms after it, up to the next
name, are its value; terms are separated by blanks, commas or line
breaks, a term in double quotes is kept whole (a quote not closed on its
line ends at the end of that line), and a `#` that begins a word starts
a comment that runs to the end of the line. Round brackets outside
quotes are ignored. A setting with nothing after its equals sign has an
empty value.

## Usage

``` r
getTokenList(lines)
```

## Arguments

- lines:

  character vector with text from configuration file

## Value

A list with two elements: `param`, a character vector of parameter
names, and `tokenVec`, a list of the token vectors parsed for each
parameter (an empty character vector for a setting with no value).

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
