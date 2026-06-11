# Converts the ancestry information to a standardized code

Part of Pedigree Curation

## Usage

``` r
convertAncestry(ancestry)
```

## Arguments

- ancestry:

  character vector or NA with free-form text providing information about
  the geographic population of origin.

## Value

A factor vector of standardized designators specifying if an animal is a
Chinese rhesus, Indian rhesus, Chinese-Indian hybrid rhesus, or Japanese
macaque. Levels: CHINESE, INDIAN, HYBRID, JAPANESE, OTHER, UNKNOWN.

## Examples

``` r
original <- c("china", "india", "hybridized", NA, "human", "gorilla")
convertAncestry(original)
#> [1] CHINESE INDIAN  HYBRID  UNKNOWN OTHER   OTHER  
#> Levels: CHINESE INDIAN HYBRID JAPANESE OTHER UNKNOWN
```
