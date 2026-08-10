# Merge two centers' pedigrees via a curator-confirmed identity link

Collapses a transferred animal's two center-specific records into ONE
node with its real parents intact, instead of leaving it as an
artificial founder at the receiving center – the failure mode issue
\#130 names directly (a transferred animal loses its recorded lineage
because the two centers use independent id namespaces). Follows the
`getPedigreeSource()` design style (D5): a deterministic,
curator-supplied cross-reference table, never coincidental same-string
ids, and fail-loud validation on any ambiguity.

## Usage

``` r
resolveCrossCenterIds(pedA, pedB, mapping)
```

## Arguments

- pedA:

  a pedigree data.frame for the first center, with (at least) columns
  `id`, `sire`, and `dam`.

- pedB:

  a pedigree data.frame for the second center, with (at least) columns
  `id`, `sire`, and `dam`.

- mapping:

  a data.frame with columns `idA` and `idB`: one row per
  curator-confirmed cross-center identity link, naming the same physical
  animal's id in `pedA` and in `pedB`. Each id may appear at most once
  in `idA` and at most once in `idB`.

## Value

A single merged pedigree data.frame over the union of `pedA`'s and
`pedB`'s columns, with one row per distinct animal (mapped pairs
collapsed to their canonical `idA` id).

## Details

For each `mapping` row, the two records collapse into one, keyed by the
`idA` value (the canonical id): every reference to the mapped `idB`
value anywhere in `pedB` – as that animal's own `id` or as a
`sire`/`dam` pointer on any other animal – is rewritten to `idA`. The
merged individual's `sire`/`dam` prefer whichever side has a non-`NA`
value (this is what fixes the artificial-founder problem: a center that
never knew the animal's real parents recorded `NA`, and the origin
center's real parents win). A mapped pair whose two sides both record a
non-`NA`, *different* `sire` or `dam` is a real data inconsistency, not
something to silently pick a side on, so it errors instead. Animals not
named in `mapping` pass through unchanged; an id string present in both
`pedA` and `pedB` that is *not* declared in `mapping` is also an error –
per D5, identity is established only by the explicit mapping table,
never assumed from a coincidentally matching id string across the two
centers' independent namespaces. As of issue \#149 Slice 1 (D10), a
merged pair's other shared columns (beyond `id`/ `sire`/`dam`) follow
the identical non-`NA`-preferred/ error-on-conflict rule – previously
they were silently dropped.

## See also

[`getFileDirectRelatives`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md),
[`checkCrossCenterMapping`](https://github.com/rmsharp/nprcgenekeepr/reference/checkCrossCenterMapping.md)

## Examples

``` r
library(nprcgenekeepr)
pedA <- data.frame(
  id = c("P1", "P2", "T1"), sire = c(NA, NA, "P1"), dam = c(NA, NA, "P2"),
  stringsAsFactors = FALSE
)
## X9 is the SAME physical animal as T1, but Center B recorded it as an
## artificial founder because it never knew the real parents.
pedB <- data.frame(
  id = c("X9", "O1"), sire = c(NA, "X9"), dam = c(NA, NA),
  stringsAsFactors = FALSE
)
mapping <- data.frame(idA = "T1", idB = "X9", stringsAsFactors = FALSE)
resolveCrossCenterIds(pedA, pedB, mapping)
#>   id sire  dam
#> 1 P1 <NA> <NA>
#> 2 P2 <NA> <NA>
#> 3 T1   P1   P2
#> 4 O1   T1 <NA>
```
