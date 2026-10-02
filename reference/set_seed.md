# Set a reproducible RNG seed across R versions

R 3.6 changed how `set.seed` and `sample` work. For R 3.6 and later this
function calls `set.seed(seed, sample.kind = "Rounding")`, which
restores the earlier [`sample()`](https://rdrr.io/r/base/sample.html)
behavior, so results of [`sample()`](https://rdrr.io/r/base/sample.html)
differ from those after a plain `set.seed(seed)`. For earlier versions
of R it calls `set.seed(seed)`. This lets unit tests give the same
results on multiple versions of R in a CICD test build. Messages and
warnings from `set.seed` are suppressed.

## Usage

``` r
set_seed(seed = 1L)
```

## Arguments

- seed:

  argument to `set.seed`

## Value

NULL, invisibly.

## Examples

``` r
set_seed(1)
rnorm(5)
#> [1] -0.6264538  0.1836433 -0.8356286  1.5952808  0.3295078
```
