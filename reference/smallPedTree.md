# Pedigree tree built from smallPed

A pedigree tree made from `smallPed`. It is a named list with one
element per animal (17 elements, named by animal ID). Each element is a
list with the components `sire` and `dam`, which hold the IDs of the
animal's parents (`NA` when a parent is unknown).

## Usage

``` r
data(smallPedTree)
```

## Format

An object of class `list` of length 17.

## Details

Access it using the following commands.

## Examples

``` r
library(nprcgenekeepr)
data("smallPedTree")
```
