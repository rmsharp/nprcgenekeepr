# Validate a kinship overrides table

Checks the structure and domain of an outside-information kinship
override table (issue \#13). The table supplies pairwise kinship
coefficients (`id1`, `id2`, `kinship`) that
[`applyKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/applyKinshipOverrides.md)
writes into a computed kinship matrix, replacing the pedigree-derived
value for those pairs. It mirrors
[`checkGenotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkGenotypeFile.md):
it [`stop()`](https://rdrr.io/r/base/stop.html)s on structural or domain
errors and returns the (id-coerced) table when the input is acceptable.

## Usage

``` r
checkKinshipOverrides(overrides)
```

## Arguments

- overrides:

  data.frame with id columns `id1` and `id2` and a numeric `kinship`
  column; each row is one off-diagonal pair. An optional
  `missingSideFor` column (issue \#95 option C) may name, per row, which
  of `id1` / `id2` is the one-unknown focal whose MISSING-side
  relatedness the override stands in for (blank / NA = known-side); each
  non-blank value must equal that row's `id1` or `id2`.

## Value

The validated `overrides` data.frame with `id1` and `id2` coerced to
character, and an optional `missingSideFor` column normalized (NA -\>
"") when present.

## Details

`kinship` is the kinship coefficient *f* (the probability that an allele
drawn at random from each of the two animals is identical by descent),
**not** the coefficient of relatedness *r* (= 2*f* for non-inbred
animals). Supplying *r* – e.g. 0.5 for half-sibs whose true *f* is 0.125
– silently corrupts the matrix, so an off-diagonal value above 0.5 (the
maximum for a non-inbred pair) draws a warning here. The exact
positive-semi-definiteness bound is enforced by
[`applyKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/applyKinshipOverrides.md)
once the matrix diagonal is known.

## Examples

``` r
overrides <- data.frame(
  id1 = c("A1", "A3"), id2 = c("A2", "A4"),
  kinship = c(0.25, 0.125), stringsAsFactors = FALSE
)
checkKinshipOverrides(overrides)
#>   id1 id2 kinship
#> 1  A1  A2   0.250
#> 2  A3  A4   0.125
```
