# Combine two allele vectors by Mendelian sampling

Combine two allele vectors by Mendelian sampling

## Usage

``` r
chooseAlleles(a1, a2)
```

## Arguments

- a1:

  integer vector with the alleles of one parent, one per simulated
  iteration

- a2:

  integer vector with the other alleles of the same parent, one per
  simulated iteration. `a1` and `a2` are expected to be equal length
  vectors; if they are not, the shorter is recycled silently.

## Value

An integer vector with the result of sampling from `a1` and `a2`
according to Mendelian inheritance.

## Examples

``` r
chooseAlleles(0L:4L, 5L:9L)
#> [1] 5 1 2 8 4
```
