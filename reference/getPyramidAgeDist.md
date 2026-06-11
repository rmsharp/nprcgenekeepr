# Get the age distribution for the pedigree

Forms a dataframe with columns `id`, `birth`, `sex`, and `age` for those
animals with a status of `Alive` in the pedigree.

## Usage

``` r
getPyramidAgeDist(ped = NULL)
```

## Arguments

- ped:

  dataframe with pedigree

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
