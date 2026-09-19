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

  integer value indicating number of characters in alias IDs

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

An obfuscated pedigree

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
#>   id sire  dam sex gen      birth exit  age recordStatus
#> 1 d1 <NA> <NA>   F   0 2003-04-13 <NA> 23.4     original
#> 2 d2 <NA> <NA>   F   0 2002-06-22 <NA> 24.2     original
#> 3 s1 <NA> <NA>   M   0 2000-07-18 <NA> 26.2     original
#> 4 s2 <NA> <NA>   M   0 2005-06-19 <NA> 21.3     original
#> 5 o1   s1   d1   F   1 2015-02-04 <NA> 11.6     original
#> 6 o2   s1   d2   F   1 2009-03-17 <NA> 17.5     original
#> 7 o3   s2   d2   F   1 2012-04-11 <NA> 14.4     original
#> 8 o4   s2   d2   M   1 2008-04-13 <NA> 18.4     original
obfuscatedPed
#>       id   sire    dam sex gen      birth exit  age recordStatus
#> 1 T5NBEL   <NA>   <NA>   F   0 2003-04-28 <NA> 23.4     original
#> 2 FEHHE9   <NA>   <NA>   F   0 2002-07-21 <NA> 24.2     original
#> 3 LSYDEB   <NA>   <NA>   M   0 2000-07-05 <NA> 26.2     original
#> 4 7YDSRN   <NA>   <NA>   M   0 2005-06-12 <NA> 21.3     original
#> 5 9G3CPE LSYDEB T5NBEL   F   1 2015-02-22 <NA> 11.6     original
#> 6 G40JSC LSYDEB FEHHE9   F   1 2009-02-19 <NA> 17.6     original
#> 7 M8WYKP 7YDSRN FEHHE9   F   1 2012-04-02 <NA> 14.5     original
#> 8 94832J 7YDSRN FEHHE9   M   1 2008-04-09 <NA> 18.4     original
```
