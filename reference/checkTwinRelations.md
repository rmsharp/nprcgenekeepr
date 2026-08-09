# Validate a twin/zygosity relations table

Checks the structure and domain of a twin/zygosity sidecar table. The
table supplies pairwise twin declarations (`id1`, `id2`, `code`) that
record which individuals in a pedigree are twins and with what twin
zygosity certainty – a fact this package's per-individual pedigree data
frame cannot represent directly (see
`docs/planning/issue137-twin-zygosity-pedigree-diagram-plan.md`). It
mirrors
[`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md):
it [`stop()`](https://rdrr.io/r/base/stop.html)s on structural or domain
errors and returns the (id-coerced) table when the input is acceptable.

## Usage

``` r
checkTwinRelations(ped, twinRelations)
```

## Arguments

- ped:

  a pedigree data.frame with (at least) `id`, `sire`, `dam`, and `sex`
  columns.

- twinRelations:

  data.frame with columns `id1`, `id2`, `code`; each row is one twin
  declaration. Any extra columns are ignored.

## Value

The validated `twinRelations` data.frame with `id1` and `id2` coerced to
character.

## Details

`code` adopts kinship2's own literal twin-code labels – `"MZ twin"`,
`"DZ twin"`, `"UZ twin"` – rather than a bare `"zygosity"` identifier,
which would collide with this package's unrelated marker-genetics
heterozygosity vocabulary (see
[`markerObservedHeterozygosity`](https://github.com/rmsharp/nprcgenekeepr/reference/markerObservedHeterozygosity.md)).
kinship2's own fourth, non-twin `"spouse"` code is out of scope here.

Validation reproduces kinship2's own `relation` acceptance rules,
confirmed empirically against the installed kinship2 namespace: both ids
must exist in `ped` and differ (all codes); an `"MZ twin"`/`"DZ twin"`
pair must already share both `sire` and `dam` in `ped`; an `"MZ twin"`
pair must additionally have matching `sex`; `"UZ twin"` has no such
precondition.

## Examples

``` r
ped <- data.frame(
  id = c("F1", "F2", "S1", "S2"),
  sire = c(NA, NA, "F1", "F1"),
  dam = c(NA, NA, "F2", "F2"),
  sex = c("M", "F", "F", "F"),
  stringsAsFactors = FALSE
)
twinRelations <- data.frame(
  id1 = "S1", id2 = "S2", code = "MZ twin", stringsAsFactors = FALSE
)
checkTwinRelations(ped, twinRelations)
#>   id1 id2    code
#> 1  S1  S2 MZ twin
```
