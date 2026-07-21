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
  map = FALSE
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

## Value

An obfuscated pedigree

## See also

Other obfuscation:
[`mapIdsToObfuscated()`](https://github.com/rmsharp/nprcgenekeepr/reference/mapIdsToObfuscated.md),
[`obfuscateDate()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateDate.md),
[`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md)

## Examples

``` r
library(nprcgenekeepr)
ped <- qcStudbook(nprcgenekeepr::pedGood)
obfuscatedPed <- obfuscatePed(ped)
ped
#>   id sire  dam sex gen      birth exit  age recordStatus
#> 1 d1 <NA> <NA>   F   0 2003-04-13 <NA> 23.3     original
#> 2 d2 <NA> <NA>   F   0 2002-06-22 <NA> 24.1     original
#> 3 s1 <NA> <NA>   M   0 2000-07-18 <NA> 26.0     original
#> 4 s2 <NA> <NA>   M   0 2005-06-19 <NA> 21.1     original
#> 5 o1   s1   d1   F   1 2015-02-04 <NA> 11.5     original
#> 6 o2   s1   d2   F   1 2009-03-17 <NA> 17.3     original
#> 7 o3   s2   d2   F   1 2012-04-11 <NA> 14.3     original
#> 8 o4   s2   d2   M   1 2008-04-13 <NA> 18.3     original
obfuscatedPed
#>       id   sire    dam sex gen      birth exit  age recordStatus
#> 1 LS7SJB   <NA>   <NA>   F   0 2003-03-17 <NA> 23.3     original
#> 2 P4MENX   <NA>   <NA>   F   0 2002-05-29 <NA> 24.1     original
#> 3 NZZUQQ   <NA>   <NA>   M   0 2000-07-10 <NA> 26.0     original
#> 4 KV6EPH   <NA>   <NA>   M   0 2005-05-30 <NA> 21.1     original
#> 5 QER817 NZZUQQ LS7SJB   F   1 2015-01-22 <NA> 11.5     original
#> 6 RWRDIS NZZUQQ P4MENX   F   1 2009-02-26 <NA> 17.4     original
#> 7 N7TLJ2 KV6EPH P4MENX   F   1 2012-03-27 <NA> 14.3     original
#> 8 ZFC1WF KV6EPH P4MENX   M   1 2008-03-24 <NA> 18.3     original
```
