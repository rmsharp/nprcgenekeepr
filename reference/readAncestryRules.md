# Read an ancestry compatibility rules table from a file

Reads a center-configurable ancestry compatibility rules table from a
user-supplied file into a data frame for
[`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md)
(issue \#168). Each row is one unordered pair of standardized ancestry
levels plus the rule's severity: columns `ancestry1`, `ancestry2`, and
`severity` (`"block"` or `"flag"`), with a header row. Excel
(`.xls`/`.xlsx`) and delimited text (`.csv`/`.txt`) files are both
accepted, mirroring
[`readKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/readKinshipOverrides.md).

## Usage

``` r
readAncestryRules(fileName, sep = ",")
```

## Arguments

- fileName:

  character vector of length one; path to the rules file (typically the
  temporary `datapath` from a Shiny file upload).

- sep:

  column separator for delimited text files (default `","`).

## Value

A data frame of the rows read from `fileName` (typically with columns
`ancestry1`, `ancestry2`, and `severity`). Validate it with
[`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md)
before use.

## Details

This reader does not validate structure or domain – that is
[`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md)'s
job. An example rules file expressing the rhesus Indian-origin purity
case ships as `example_ancestry_rules.csv` in the package's
`extdata/examples` directory.

## Examples

``` r
rulesFile <- system.file("extdata", "examples",
  "example_ancestry_rules.csv",
  package = "nprcgenekeepr"
)
rules <- checkAncestryRules(readAncestryRules(rulesFile))
rules
#>   ancestry1 ancestry2 severity
#> 1    INDIAN   CHINESE    block
#> 2    INDIAN    HYBRID    block
#> 3    INDIAN   UNKNOWN     flag
#> 4    INDIAN     OTHER     flag
```
