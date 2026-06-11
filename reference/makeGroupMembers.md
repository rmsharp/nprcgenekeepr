# Convenience function to make the initial groupMembers animal list

Convenience function to make the initial groupMembers animal list

## Usage

``` r
makeGroupMembers(numGp, currentGroups, candidates, ped, harem, minAge)
```

## Arguments

- numGp:

  integer value indicating the number of groups that should be formed
  from the list of IDs. Default is 1.

- currentGroups:

  list of character vectors of IDs of animals currently assigned to the
  group. Defaults to character(0) assuming no groups are existent.

- candidates:

  character vector of IDs of the animals available for use in the group.

- ped:

  dataframe that is the `Pedigree`. It contains pedigree information
  including the IDs listed in `candidates`.

- harem:

  logical variable when set to `TRUE`, the formed groups have a single
  male at least `minAge` old.

- minAge:

  integer value indicating the minimum age to consider in group
  formation. Pairwise kinships involving an animal of this age or
  younger will be ignored. Default is 1 year.

## Value

Initial groupMembers list
