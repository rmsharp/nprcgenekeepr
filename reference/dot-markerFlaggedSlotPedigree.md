# Build a local pedigree copy with each flagged (id, role) slot blanked

Internal helper for
[`markerParentageLikelihood`](https://github.com/rmsharp/nprcgenekeepr/reference/markerParentageLikelihood.md)
(issue \#155,
`docs/planning/issue155-parentage-likelihood-candidate-lookup-plan.md`
D1).
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
only ever builds a candidate list for an animal with at least one
missing (`NA`) parent slot; a flagged animal whose recorded parent is
present but Mendelian-inconsistent has both slots non-`NA` by
definition, so it never appears in
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)'s
own candidate search. This helper returns a local, unmutated-in-place
copy of `pedigree` with exactly the named (id, role) slot(s) set to
`NA`, so `pedigree` merely *looks like* a genuinely-missing-parent case
to
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
– which is called completely unmodified against it, reusing its full
demographic-eligibility engine (breeding-age floor, gestation window,
proven-breeder preference) at 100\\ never changed – the copy is scoped
only to the caller's own
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
call argument.

## Usage

``` r
.markerFlaggedSlotPedigree(pedigree, ids, roles)
```

## Arguments

- pedigree:

  a data frame with (at least) columns `id`, `sire`, and `dam`.

- ids:

  character vector of flagged ids, one entry per (id, role) pair.

- roles:

  character vector of flagged roles (`"sire"`/`"dam"`), the same length
  as `ids`, paired positionally.

## Value

A copy of `pedigree`, un-mutated except for the named slot(s). A
duplicated `pedigree$id` is left un-blanked – which row is "the" flagged
animal is undefined for an ambiguous id, so this falls through to the
same fail-soft, zero-candidates posture as an id genuinely absent from
`pedigree`, rather than silently blanking every matching row (mirrors
`scoreOnePair()`'s own defensive `nrow(pedRow) == 1L` pattern a few
lines above in this file).
