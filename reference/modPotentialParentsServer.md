# Potential Parents Module - Server Function

Server logic for the Potential Parents module. On button press, it calls
[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
against the current pedigree, flattens the result into a sortable table,
and exposes it for CSV download. The surface degrades gracefully when no
pedigree is loaded, when the pedigree lacks the `fromCenter`
colony-origin field, or when no in-colony animal has an unknown parent.

## Usage

``` r
modPotentialParentsServer(id, pedigree = NULL, minParentAge = 2)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- pedigree:

  reactive returning the current pedigree data.frame.

- minParentAge:

  numeric minimum age in years for an animal to be a parent. Defaults to
  2 (the QC default).

## Value

A list of reactive expressions:

- `potentialParents` - the raw `getPotentialParents` result (or `NULL`).

- `tableData` - the flattened results data.frame.

## See also

[`modPotentialParentsUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modPotentialParentsUI.md)
for the user interface.

[`getPotentialParents`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
for the underlying computation.
