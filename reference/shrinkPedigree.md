# Shrink a pedigree to fit within a bit-size budget

Trims a pedigree down to the individuals needed to keep it genetically
informative within a genotyping-cost budget (`maxBits`), given which
individuals are genotyped (`genotyped`) and, optionally, which are
affected by a trait of interest (`affected`). It is equivalent to
[`kinship2::pedigree.shrink()`](https://rdrr.io/pkg/kinship2/man/pedigree.shrink.html),
working on this package's `id`/`sire`/`dam` data-frame pedigree. Three
tiers are applied in order:

1.  **Unavailable trim.** Iteratively removes terminal (leaf)
    individuals who are not genotyped, then removes any founder couple
    with exactly one child together and no other mate, when both parents
    are themselves founders and neither is genotyped (the couple's
    shared child is promoted to founder status rather than removed),
    then removes any remaining childless founder ("stray marry-in")
    *regardless of genotyped status*.

2.  **Non-informative trim.** Removes a genotyped, non-parent individual
    whose own `sire` and `dam` are both known and both genotyped, when
    the individual is not `affected` (an `NA` `affected` status counts
    as unaffected here) – they add no genotype information beyond what
    their parents already supply. An individual with only one known
    parent (one of `sire`/`dam` known, the other `NA`) is never trimmed
    by this tier. Such partial parentage is ordinary data in this
    package (see
    [`getIdsWithOneParent`](https://github.com/rmsharp/nprcgenekeepr/reference/getIdsWithOneParent.md)),
    whereas kinship2 does not allow it.

3.  **Affected-priority trim.** While the pedigree's bit size
    (`2 * nNonFounder - nFounder`) still exceeds `maxBits`, removes one
    genotyped, non-parent individual at a time – trying `NA`-affected
    candidates first, then unaffected, then affected – choosing
    whichever single candidate's removal (including any cascade through
    tiers 1-2 above) minimizes the resulting bit size. Ties are broken
    deterministically by lowest `id`, compared as a string, so the same
    input always gives the same answer (kinship2 breaks ties at random).
    `idTrimmed` and `idList$affected` record every id actually removed
    each round, including those removed by a cascade, so
    `pedSizeOriginal - pedSizeFinal` always equals `length(idTrimmed)`.

## Usage

``` r
shrinkPedigree(ped, genotyped, affected = NULL, maxBits = 16L)
```

## Arguments

- ped:

  a pedigree `data.frame`. The fields `id`, `sire` and `dam` are
  required; an optional `affected` logical column is used as the default
  source for `affected` (see below). `sire`/`dam` are `NA` for a
  founder, and may be `NA` for only one of the two (partial parentage) –
  see the non-informative-trim tier above for how that case is handled.

- genotyped:

  a logical vector, the same length as `nrow(ped)` and in the same row
  order, `TRUE` where a genotype (or other available biological sample)
  exists for that individual. `NA` is not allowed, matching kinship2's
  own `avail` validation.

- affected:

  `NULL` (default) or a logical vector the same length as `nrow(ped)`.
  When `NULL`, defaults to `ped$affected` if that column exists, or to
  all-`FALSE` (unaffected) if it does not – ensuring the
  affected-priority trim can always make progress even with no recorded
  affected status.

- maxBits:

  numeric, default `16L`. The bit-size budget the affected-priority trim
  reduces toward.

## Value

A list:

- ped:

  The shrunk pedigree `data.frame`, with all of `ped`'s original
  columns; a promoted founder's `sire`/ `dam` are set to `NA`.

- idTrimmed:

  Character vector, every `id` removed, in removal order.

- idList:

  A list with elements `unavail`, `noninform` and `affected` – character
  vectors (`character(0)` when empty) grouping `idTrimmed` by which tier
  removed each id.

- bitSize:

  Numeric vector: the pedigree's bit size before any trimming, after
  tiers 1-2, then one further value per affected- priority round.

- genotyped:

  The final `genotyped` vector, aligned to `ped$id`.

- pedSizeOriginal, pedSizeIntermed, pedSizeFinal:

  Integer row counts: original, after tiers 1-2, and final.

## Details

A fully genotyped pedigree can shrink to zero rows (see the example).

## References

Sinnwell JP, Therneau TM, Schaid DJ (2014). "The kinship2 R Package for
Pedigree Data." *Human Heredity*, 78(2), 91-93.

<https://cran.r-project.org/package=kinship2>

## See also

[`isFounder`](https://github.com/rmsharp/nprcgenekeepr/reference/isFounder.md),
[`getIdsWithOneParent`](https://github.com/rmsharp/nprcgenekeepr/reference/getIdsWithOneParent.md)

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::examplePedigree[, c("id", "sire", "dam")]
genotyped <- rep(TRUE, nrow(ped))
result <- shrinkPedigree(ped, genotyped, maxBits = 16L)
nrow(ped)
#> [1] 3694
## With every individual genotyped, the whole pedigree can be trimmed away.
nrow(result$ped)
#> [1] 0
```
