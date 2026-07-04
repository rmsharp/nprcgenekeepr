# Get the direct ancestors of selected animals

Gets direct ancestors from labkey `study` schema and `demographics`
table.

## Usage

``` r
getLkDirectAncestors(ids)
```

## Arguments

- ids:

  character vector of animal IDs

## Value

data.frame with pedigree structure having all of the direct ancestors
for the Ids provided.

## See also

Other direct relatives:
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md),
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md),
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires LabKey connection
library(nprcgenekeepr)
## Have to a vector of focal animals
focalAnimals <- c("1X2701", "1X0101")
suppressWarnings(getLkDirectAncestors(ids = focalAnimals))
} # }
```
