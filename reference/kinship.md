# Generate a kinship matrix

The function previously had an internal call to the kindepth function in
order to provide the parameter pdepth (the generation number). This
version requires the generation number to be calculated elsewhere and
passed into the function.

## Usage

``` r
kinship(
  id,
  father.id,
  mother.id,
  pdepth,
  sparse = FALSE,
  twinRelations = NULL,
  chrtype = "autosome",
  sex = NULL
)
```

## Arguments

- id:

  character vector of IDs for a set of animals.

- father.id:

  character vector or NA for the IDs of the sires for the set of
  animals.

- mother.id:

  character vector or NA for the IDs of the dams for the set of animals.

- pdepth:

  integer vector indicating the generation number for each animal.

- sparse:

  logical flag. If `TRUE`, `Matrix::Diagnol()` is used to make a unit
  diagonal matrix. If `FALSE`,
  [`base::diag()`](https://rdrr.io/r/base/diag.html) is used to make a
  unit square matrix.

- twinRelations:

  `NULL` (default, no-op) or a data.frame with columns `id1`, `id2`,
  `code` declaring twin pairs (see
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)).
  Only `code == "MZ twin"` rows affect the computed matrix –
  `"DZ twin"`/`"UZ twin"` rows are accepted but get zero special
  treatment, matching kinship2's own `relation` mechanism. A declared
  MZ-twin pair's coefficient is corrected to equal their shared
  self-kinship (genetic identity), and the correction is propagated
  transitively (chained MZ declarations, e.g. A-B and B-C, also correct
  the undeclared A-C pair) and to every relative computed at a later
  pedigree depth through either twin – not just the declared pair's own
  cell. `twinRelations` is trusted as already validated by
  [`checkTwinRelations`](https://github.com/rmsharp/nprcgenekeepr/reference/checkTwinRelations.md)
  (this function has no `sex` parameter of its own and so cannot re-run
  that validator's full rule set itself); only a cheap self-contained
  check (both ids present in `id`) is performed here. See
  `docs/planning/twin-relations-kinship-computation-plan.md` for the
  full design rationale.

- chrtype:

  `"autosome"` (default) or `"x"`. When `"autosome"`, behavior is
  unchanged from every prior version of this function – `sex` is not
  required and is ignored if supplied. When `"x"`, computes X-chromosome
  kinship instead: a male's X comes from his mother only (self-kinship
  1, since he carries a single copy); a female's X-linked kinship
  follows the same average-of-parents formula as the autosomal case
  (self-kinship 0.5, as usual). An individual with unrecognized `sex`
  gets `NA` kinship with everyone, including their own self-kinship
  value. The MZ-twin correction (`twinRelations`) applies inside this
  branch identically to the autosomal branch. Ported from kinship2's own
  `kinship.default()` X-linked branch; see
  `docs/planning/kinship2-supplement-full-reproduction-plan.md` §3 for
  the full design rationale.

- sex:

  `NULL` (default) or a character vector, the same length as `id`, using
  this package's own internal sex codes (`sexCodes`): `"M"`/`"F"`; any
  other value, including `NA`, is treated as unknown). Required when
  `chrtype = "x"`; ignored (may be omitted) when `chrtype = "autosome"`.

## Value

A kinship square matrix

## Details

The rows (cols) of founders are just 0.5 \* identity matrix, no further
processing is needed for them. Parents must be processed before their
children, and then a child's kinship is just a sum of the kinship's for
his or her parents.

The code for the kinship function was written by Terry Therneau at the
Mayo clinic and taken from his website. This function is part of a
package written in S (and later ported to R) for calculating kinship and
other statistics.

## References

<https://cran.r-project.org/package=kinship2>

The `chrtype = "x"` branch is ported from kinship2's own X-chromosome
kinship algorithm, described and worked (Table S2) in its supplementary
material:

Sinnwell JP, Therneau TM, Schaid DJ (2014). "The kinship2 R Package for
Pedigree Data." *Human Heredity*, 78(2), 91-93.

\$Id: kinship.s,v 1.5 2003/01/04 19:07:53 therneau Exp \$

Create the kinship matrix, using the algorithm of K Lange, Mathematical
and Statistical Methods for Genetic Analysis, Springer, 1997, p 71-72.

## Author

Terry M. Therneau, Mayo Clinic (mayo.edu), original version

All of the code on the original S-Plus kinship function (originally
hosted on Terry Therneau's Mayo Clinic software page, offline since at
least 2019) was stated to be released under the GNU General Public
License (version 2 or later).

The R version became the kinship2 package available on CRAN:

as modified by M Raboin, 2014-09-08 14:44:26

## Examples

``` r
library(nprcgenekeepr)
ped <- nprcgenekeepr::lacy1989Ped
ped$gen <- findGeneration(ped$id, ped$sire, ped$dam)
kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen)
ped
#>   id sire  dam gen population
#> 1  A <NA> <NA>   0       TRUE
#> 2  B <NA> <NA>   0       TRUE
#> 3  C    A    B   1       TRUE
#> 4  D    A    B   1       TRUE
#> 5  E <NA> <NA>   0       TRUE
#> 6  F    D    E   2       TRUE
#> 7  G    D    E   2       TRUE
kmat
#>       A     B     C    D    E     F     G
#> A 0.500 0.000 0.250 0.25 0.00 0.125 0.125
#> B 0.000 0.500 0.250 0.25 0.00 0.125 0.125
#> C 0.250 0.250 0.500 0.25 0.00 0.125 0.125
#> D 0.250 0.250 0.250 0.50 0.00 0.250 0.250
#> E 0.000 0.000 0.000 0.00 0.50 0.250 0.250
#> F 0.125 0.125 0.125 0.25 0.25 0.500 0.250
#> G 0.125 0.125 0.125 0.25 0.25 0.250 0.500
```
