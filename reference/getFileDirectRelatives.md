# Get the direct relatives of selected animals from a pedigree file

File-sourced sibling of
[`getLkDirectRelatives`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md):
reads a pedigree file through the internal `getPedigreeSource()`
`"file"` provider (via
[`getPedigree`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md)),
then delegates the pedigree walk to the source-agnostic
[`getPedDirectRelatives`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md).
The result is the full connected pedigree component (ancestors,
descendants, and collaterals such as siblings and mates) reachable from
the focal animals. It is fully offline and deterministic.

## Usage

``` r
getFileDirectRelatives(
  ids,
  fileName = NULL,
  sep = ",",
  unrelatedParents = FALSE
)
```

## Arguments

- ids:

  character vector of animal IDs

- fileName:

  path to a pedigree file (CSV or Excel) read via
  [`getPedigree`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md);
  the file must provide at least `id`, `sire`, and `dam` columns.

- sep:

  column separator passed to the file reader for delimited text files
  (default `","`); ignored for Excel files.

- unrelatedParents:

  logical vector when `FALSE` the unrelated parents of offspring do not
  get a record as an ego; when `TRUE` a place holder record where parent
  (`sire`, `dam`) IDs are set to `NA`.

## Value

A data.frame with pedigree structure containing all direct relatives –
the full connected pedigree component (ancestors, descendants, and
collaterals) – for the Ids provided.

## Details

Unlike the LabKey source, which fails soft (returns `NULL`) when its
fetch fails, the file source errors loudly: a `NULL` or missing
`fileName`, a file that does not exist, or a file lacking the `id`,
`sire`, and `dam` columns each raises an error.

## See also

Other direct relatives:
[`getLkDirectAncestors()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectAncestors.md),
[`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md),
[`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)

## Examples

``` r
library(nprcgenekeepr)
## Build a tiny pedigree file, then pull the relatives of a focal animal.
ped <- data.frame(
  id = c("A", "B", "C"), sire = c(NA, NA, "A"), dam = c(NA, NA, "B"),
  stringsAsFactors = FALSE
)
pedFile <- tempfile(fileext = ".csv")
write.csv(ped, pedFile, row.names = FALSE)
getFileDirectRelatives(ids = "C", fileName = pedFile)
#>   id sire  dam
#> 1  A <NA> <NA>
#> 2  B <NA> <NA>
#> 3  C    A    B
unlink(pedFile)
```
