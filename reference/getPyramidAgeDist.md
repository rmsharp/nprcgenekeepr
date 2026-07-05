# Get the age distribution for the pedigree

Returns the pedigree with all animals, adding a `status` column
describing each animal as `ALIVE` or `DECEASED` and a computed `age`
column (age at exit for deceased animals). All animals are returned, not
only living ones.

## Usage

``` r
getPyramidAgeDist(ped = NULL)
```

## Arguments

- ped:

  The pedigree information in data.frame format

## Value

A pedigree with `status` column added, which describes the animal as
`ALIVE` or `DECEASED` and a `age` column added, which has the animal's
age in years or `NA` if it cannot be calculated. The `exit` column
values have been remapped to valid dates or `NA`.

## Details

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
