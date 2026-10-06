# Obfuscate a pedigree by aliasing IDs and shifting dates

User provides a pedigree object (`ped`), the number of characters to be
used for alias IDs (`size`), and the maximum number of days that the
birthdate can be shifted (`maxDelta`).

## Usage

``` r
obfuscatePed(
  ped,
  size = 6L,
  maxDelta = 30L,
  existingIds = character(0L),
  map = FALSE,
  linkedDateShift = TRUE
)
```

## Arguments

- ped:

  The pedigree information in data.frame format

- size:

  integer value indicating number of characters in alias IDs. IDs that
  stand for unknown parents get longer aliases when `size` is too short
  to keep them recognizable as placeholders (see
  [`obfuscateId`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md)).

- maxDelta:

  integer value indicating maximum number of days that the birthdate can
  be shifted

- existingIds:

  character vector of existing aliases to avoid duplication.

- map:

  logical if `TRUE` a list object is returned with the new pedigree and
  a named character vector with the names being the original IDs and the
  values being the new alias values. Defaults to `FALSE`.

- linkedDateShift:

  logical, defaults to `TRUE`. When `TRUE`, every Date column of one
  individual is shifted by the same, single random offset (drawn once
  per individual), so the gaps between an individual's own dates (e.g.
  `birth`, `exit`, `death`) are preserved exactly – avoiding a defect
  where independently-shifted date columns can invert an individual's
  recorded date order (e.g. an obfuscated `exit` preceding an obfuscated
  `birth`), producing a negative recomputed `age` (issue \#150 D3). When
  `FALSE`, each Date column is shifted independently via
  [`obfuscateDate`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md)
  (the original, pre-#150 behavior).

## Value

An obfuscated pedigree: IDs aliased, `name` set to `NA`, Date columns
shifted and `age` recomputed. With `map = TRUE`, a list holding that
pedigree and the alias map.

## Details

Any `name` column is overwritten with `NA`. Every Date column (e.g.
`birth`, `exit`, `death`) is shifted, not only the birthdate. When the
`age`, `birth` and `exit` columns are all present and `birth` is a Date,
`age` is recomputed from the shifted dates.

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscateGenomicROH()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenomicROH.md),
[`obfuscateGenotypeMatrix()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateGenotypeMatrix.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md),
[`obfuscateLdBlocks()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateLdBlocks.md),
[`obfuscateMhcHaplotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateMhcHaplotypes.md),
[`obfuscateTwinRelations()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateTwinRelations.md)

## Examples

``` r
library(nprcgenekeepr)
ped <- qcStudbook(nprcgenekeepr::pedGood)
obfuscatedPed <- obfuscatePed(ped)
ped
#>   id sire  dam sex gen      birth exit  age recordStatus placeholder
#> 1 d1 <NA> <NA>   F   0 2003-04-13 <NA> 23.5     original       FALSE
#> 2 d2 <NA> <NA>   F   0 2002-06-22 <NA> 24.3     original       FALSE
#> 3 s1 <NA> <NA>   M   0 2000-07-18 <NA> 26.2     original       FALSE
#> 4 s2 <NA> <NA>   M   0 2005-06-19 <NA> 21.3     original       FALSE
#> 5 o1   s1   d1   F   1 2015-02-04 <NA> 11.7     original       FALSE
#> 6 o2   s1   d2   F   1 2009-03-17 <NA> 17.6     original       FALSE
#> 7 o3   s2   d2   F   1 2012-04-11 <NA> 14.5     original       FALSE
#> 8 o4   s2   d2   M   1 2008-04-13 <NA> 18.5     original       FALSE
obfuscatedPed
#>       id   sire    dam sex gen      birth exit  age recordStatus placeholder
#> 1 GR1AT5   <NA>   <NA>   F   0 2003-05-10 <NA> 23.4     original       FALSE
#> 2 NBELFE   <NA>   <NA>   F   0 2002-07-10 <NA> 24.2     original       FALSE
#> 3 HHE9LS   <NA>   <NA>   M   0 2000-08-03 <NA> 26.2     original       FALSE
#> 4 YDEB7Y   <NA>   <NA>   M   0 2005-06-05 <NA> 21.3     original       FALSE
#> 5 DSRN9G HHE9LS GR1AT5   F   1 2015-02-19 <NA> 11.6     original       FALSE
#> 6 3CPEG4 HHE9LS NBELFE   F   1 2009-04-15 <NA> 17.5     original       FALSE
#> 7 0JSCM8 YDEB7Y NBELFE   F   1 2012-03-29 <NA> 14.5     original       FALSE
#> 8 WYKP94 YDEB7Y NBELFE   M   1 2008-04-06 <NA> 18.5     original       FALSE
```
