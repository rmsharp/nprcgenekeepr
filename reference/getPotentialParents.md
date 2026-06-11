# Get the lists of portential parents for all individuals born in the colony with one or two unknown parents.

**\[experimental\]**

## Usage

``` r
getPotentialParents(ped, minParentAge, maxGestationalPeriod)
```

## Arguments

- ped:

  the pedigree information in data.frame format. Pedigree (req. fields:
  id, sire, dam, gen, population). This requires complete pedigree
  information.

- minParentAge:

  numeric values to set the minimum age in years for an animal to have
  an offspring. Defaults to 2 years. The check is not performed for
  animals with missing birth dates.

- maxGestationalPeriod:

  integer value describing the days between conception and birth. This
  will be used to prevent the removal of sires who exit the colony
  between date of conception and birth. Need to decide where this will
  come from.

## Value

a list of list with each internal list being made up of an animal id
(`id`), a vector of possible sires (`sire`) and a vector of possible
dams (`dam`). The `id` must be defined while the vectors `sire` and
`dam` can be empty.
