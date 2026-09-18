# Parse per-animal MHC haplotype designations into a long call table

Internal parse rule for MHC haplotype reporting (issue \#148 design plan
D3, ratified S704): `NA` or an empty string is a MISSING call; a
designation matching `^(.+)\?$` is an UNCERTAIN (provisional) call of
the haplotype with the trailing `?` stripped; anything else is a certain
call. Labels are otherwise opaque (design plan D9): a bare `"?"` has no
label part to strip, so it is treated as a certain call of the literal
label `"?"`, not judged. Total function over
[`checkMhcHaplotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md)-validated
input – no error paths.

## Usage

``` r
.parseMhcHaplotypeCalls(genotype)
```

## Arguments

- genotype:

  dataframe as returned by
  [`checkMhcHaplotypeFile`](https://github.com/rmsharp/nprcgenekeepr/reference/checkMhcHaplotypeFile.md):
  columns `id`, `haplotype1`, `haplotype2`, one row per animal.

## Value

A data.frame with one row per (animal x designation column), i.e. 2 rows
per animal: `id` (character), `haplotype` (character; the designation
with any trailing `?` stripped, or `NA` when missing), `uncertain`
(logical), `missing` (logical).
