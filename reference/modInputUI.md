# Data Input and Quality Control Module - UI Function

Copyright(c) 2017-2025 R. Mark Sharp This file is part of nprcgenekeepr

## Usage

``` r
modInputUI(id)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

## Value

A `div` object containing the data input UI.

## Details

Creates user interface for data input including file uploads for
pedigree and genotype data with various format options, followed by
quality control validation.

## See also

[`modInputServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md)
for server logic.

[`modPedigreeUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md)
for pedigree browsing after QC.
