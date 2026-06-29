# Potential Parents Module - UI Function

Creates the user interface for identifying potential parents of
in-colony animals that have at least one unknown parent. The user sets a
maximum gestational period, presses a button to compute candidate sires
and dams on the current pedigree, views a sortable results table, and
downloads the results as CSV.

## Usage

``` r
modPotentialParentsUI(id)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

## Value

A `div` object containing the Potential Parents UI.

## See also

[`modPotentialParentsServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsServer.md)
for server logic.

[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
for the underlying computation.
