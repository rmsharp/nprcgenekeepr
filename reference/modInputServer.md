# Data Input and Quality Control Module - Server Function

Server logic for data input module handling file uploads, parsing of
pedigree and genotype data files, and quality control validation.

## Usage

``` r
modInputServer(id, config = NULL)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- config:

  optional reactive expression returning configuration data.

## Value

A list with reactive components:

- `cleanedStudbook` - The QC-cleaned studbook data

- `genotypeData` - Genotype data if provided

- `qcSummary` - Summary of QC results (error/warning counts)

- `minParentAge` - The minimum parent age value

- `isReady` - Logical indicating if data is ready for next step

## See also

[`modInputUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputUI.md)
for the user interface.

[`modPedigreeServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md)
for using the cleaned data.
