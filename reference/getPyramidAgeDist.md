# Get the age distribution for the pedigree

Returns the pedigree with all animals, adding a `status` column
describing each animal as `ALIVE` or `DECEASED` and a computed `age`
column (age at exit for deceased animals). All animals are returned, not
only living ones. An animal is `DECEASED` when it has an exit date or
when its birth date is `NA`; otherwise it is `ALIVE`. When `ped` is
`NULL` (the default), the packaged `qcPed` example data are used.

## Usage

``` r
getPyramidAgeDist(ped = NULL)
```

## Arguments

- ped:

  data.frame whose first six columns are id, sire, dam, sex, birth and
  exit, in that order (see Details above). Defaults to `NULL`, which
  uses the packaged `qcPed` example data.

## Value

A pedigree with the six columns of `ped` (`id`, `sire`, `dam`, `sex`,
`birth`, `exit`) and a `status` column added, which describes the animal
as `ALIVE` or `DECEASED` and a `age` column added, which has the
animal's age in years or `NA` if it cannot be calculated. The `exit`
column values have been remapped to valid dates or `NA`.

## Details

The columns of `ped` are read by position, not by name: the first six
columns must be the id, sire, dam, sex, birth and exit values in that
order, and are renamed accordingly. Any further columns are dropped. If
birth is not in the fifth column and of class `Date`, `POSIXct` or
`character`, the error message reports that the birth column is of the
wrong class.

The lubridate package is used here because of the way the modern
Gregorian calendar is constructed, there is no straightforward
arithmetic method that produces a person’s age, stated according to
common usage — common usage meaning that a person’s age should always be
an integer that increases exactly on a birthday.

## Examples

``` r
library(nprcgenekeepr)
ped <- getPyramidAgeDist()
```
