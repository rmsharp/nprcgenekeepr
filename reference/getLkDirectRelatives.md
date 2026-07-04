# Get the direct relatives of selected animals from the LabKey EHR

Builds the pedigree of relatives for the provided focal animals from the
LabKey `study` schema `demographics` table, obtained through the
internal `getPedigreeSource()` adapter. The pedigree walk is delegated
to
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md),
so the result is the full connected pedigree component (ancestors,
descendants, and collaterals such as siblings and mates) reachable from
the focal animals.

## Usage

``` r
getLkDirectRelatives(ids, unrelatedParents = FALSE)
```

## Arguments

- ids:

  character vector of animal IDs

- unrelatedParents:

  logical vector when `FALSE` the unrelated parents of offspring do not
  get a record as an ego; when `TRUE` a place holder record where parent
  (`sire`, `dam`) IDs are set to `NA`.

## Value

A data.frame with pedigree structure containing all direct relatives –
the full connected pedigree component (ancestors, descendants, and
collaterals) – for the Ids provided.

## See also

Other direct relatives:
[`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md),
[`getLkDirectAncestors()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectAncestors.md),
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires LabKey connection
library(nprcgenekeepr)
## Have to a vector of focal animals
focalAnimals <- c("1X2701", "1X0101")
suppressWarnings(getLkDirectRelatives(ids = focalAnimals))
} # }
```
