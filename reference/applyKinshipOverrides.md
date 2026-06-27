# Apply outside-information kinship overrides to a kinship matrix

Writes pairwise kinship coefficients from outside information (issue
\#13) into a computed kinship matrix, replacing the pedigree-derived
value for the named pairs. Each `(id1, id2, kinship)` row sets both
`kmat[id1, id2]` and its symmetric twin `kmat[id2, id1]`; all other
cells are unchanged. This is a direct cell replacement – it does not
propagate to descendant rows.

## Usage

``` r
applyKinshipOverrides(kmat, overrides)
```

## Arguments

- kmat:

  a dense, symmetric, id-named numeric kinship matrix.

- overrides:

  data.frame of overrides (`id1`, `id2`, `kinship`); `NULL` or a
  zero-row frame is a no-op returning `kmat` unchanged. Validated with
  [`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md).

## Value

`kmat` with the override cells replaced (symmetric).

## Details

`kmat` must be a dense, symmetric, id-named base R matrix (the object
[`kinship`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
returns); a sparse `Matrix` object is out of contract. The function is
strict: it [`stop()`](https://rdrr.io/r/base/stop.html)s on an id absent
from the matrix and on a value above the exact
positive-semi-definiteness bound
`sqrt(kmat[id1, id1] * kmat[id2, id2])`. Soft, run-preserving handling
of ids outside the analysis set is the caller's responsibility –
[`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
warn-drops non-member ids before calling this.
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
itself is never modified (it has several callers, including two
simulations that must not take current-kinship overrides).

## Examples

``` r
ped <- nprcgenekeepr::qcPed
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
overrides <- data.frame(
  id1 = ped$id[1], id2 = ped$id[2], kinship = 0.25,
  stringsAsFactors = FALSE
)
kmat <- applyKinshipOverrides(kmat, overrides)
#> 1 kinship override(s) applied.
```
