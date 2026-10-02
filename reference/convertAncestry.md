# Convert ancestry information to a standard code

Part of Pedigree Curation

## Usage

``` r
convertAncestry(ancestry)
```

## Arguments

- ancestry:

  character vector or NA with free-form text providing information about
  the geographic population of origin. Matching ignores case and looks
  for text inside each value: a value containing "chin" but not "ind" is
  CHINESE, one containing "ind" but not "chin" is INDIAN, one containing
  both, or "hyb", is HYBRID, and one containing "jap" is JAPANESE. `NA`
  is UNKNOWN and anything else is OTHER. For example, "Indonesian" is
  INDIAN.

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
