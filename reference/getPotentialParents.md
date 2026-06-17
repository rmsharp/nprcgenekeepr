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

  integer value describing the maximum number of days between conception
  and birth for the species being analyzed (a conservative upper bound,
  e.g. 210 for rhesus whose typical gestation is about 165 days). It is
  used two ways: (1) a sire who exited the colony between conception
  (birth - maxGestationalPeriod) and birth is still retained as a
  candidate; and (2) a female who delivered another offspring within
  maxGestationalPeriod days of the focal birth is excluded as a
  candidate dam, because a female bears one offspring at a time. The
  sire check uses presence at conception while the dam check uses
  presence at birth; this asymmetry is intentional – a sire need only be
  present to conceive, whereas a dam must be present through the
  pregnancy to give birth.

## Value

a list of list with each internal list being made up of an animal id
(`id`), a vector of possible sires (`sire`) and a vector of possible
dams (`dam`). The `id` must be defined while the vectors `sire` and
`dam` can be empty.
