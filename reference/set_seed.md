# Work around for unit tests using sample() among various versions of R

The change in how `set.seed` works in R 3.6 prompted the creation of
this R version agnostic replacement to get unit test code to work on
multiple versions of R in a CICD test build.

## Usage

``` r
set_seed(seed = 1L)
```

## Arguments

- seed:

  argument to `set.seed`

## Value

NULL, invisibly.

## Details

It seems `RNGkind(sample.kind="Rounding")` does not work prior to
version 3.6 so I resorted to using version dependent construction of the
argument list to set.seed() in do.call().#'

## Examples

``` r
set_seed(1)
rnorm(5)
#> [1] -0.6264538  0.1836433 -0.8356286  1.5952808  0.3295078
```
