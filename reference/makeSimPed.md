# Makes a simulated pedigree using representative sires and dams

For each `id` in `allSimParents` with one or more unknown parents each
unknown parent is replaced with a random sire or dam as needed from the
corresponding parent vector (`sires` or `dams`).

## Usage

``` r
makeSimPed(ped, allSimParents, verbose = FALSE)
```

## Arguments

- ped:

  pedigree information in data.frame format

- allSimParents:

  list made up of lists where the internal list has the offspring ID
  `id`, a vector of representative sires (`sires`), and a vector of
  representative dams (`dams`).

- verbose:

  logical vector of length one that indicates whether or not to print
  out when an animal is missing a sire or a dam.

## Value

simulated pedigree in data.frame format with the id, sire, and dam.

## Details

The algorithm assigns parents randomly from the lists of possible sires
and dams and does not prevent a dam from being selected more than once
within the same breeding period. While this is probably not introducing
a large error, it is not ideal.
