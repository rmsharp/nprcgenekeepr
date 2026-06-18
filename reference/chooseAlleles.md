# Combines two vectors of alleles by randomly selecting one allele or the other at each position

Combines two vectors of alleles by randomly selecting one allele or the
other at each position

## Usage

``` r
chooseAlleles(a1, a2)
```

## Arguments

- a1:

  integer vector with first allele for each individual

- a2:

  integer vector with second allele for each individual `a1` and `a2`
  are equal length vectors of alleles for one individual

## Value

An integer vector with the result of sampling from `a1` and `a2`
according to Mendelian inheritance.

## Examples

``` r
chooseAlleles(0L:4L, 5L:9L)
#> [1] 5 1 7 3 4
```
