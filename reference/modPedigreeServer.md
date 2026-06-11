# Pedigree Browser Module - Server Function

Server logic for pedigree browser module handling focal animal
selection, pedigree processing, filtering, and data export.

## Usage

``` r
modPedigreeServer(id, studbook, config = NULL)
```

## Arguments

- id:

  character vector of length 1. Module namespace identifier.

- studbook:

  reactive returning the cleaned studbook data from modInput.

- config:

  optional reactive returning configuration.

## Value

A list of reactive values:

- `pedigree` - Filtered pedigree for display (respects trim/unknown
  settings)

- `processedPedigree` - Full pedigree with population, pedNum, gen
  columns

- `focalAnimals` - Character vector of focal animal IDs

- `nAnimals` - Count of animals in filtered pedigree

- `populationCount` - Count of animals marked as population

- `isReady` - Logical indicating if pedigree data is ready

## Details

This module processes the studbook by:

- Adding a `population` column via
  [`setPopulation()`](https://github.com/rmsharp/nprcgenekeepr/reference/setPopulation.md)

- Adding a `pedNum` column via
  [`findPedigreeNumber()`](https://github.com/rmsharp/nprcgenekeepr/reference/findPedigreeNumber.md)

- Ensuring a `gen` column exists via
  [`findGeneration()`](https://github.com/rmsharp/nprcgenekeepr/reference/findGeneration.md)

- Optionally trimming to ancestors of focal animals via
  [`trimPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/trimPedigree.md)

## See also

[`modPedigreeUI`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeUI.md)
for the UI component

[`setPopulation`](https://github.com/rmsharp/nprcgenekeepr/reference/setPopulation.md)
for population marking

[`trimPedigree`](https://github.com/rmsharp/nprcgenekeepr/reference/trimPedigree.md)
for pedigree trimming

[`findPedigreeNumber`](https://github.com/rmsharp/nprcgenekeepr/reference/findPedigreeNumber.md)
for pedigree numbering

[`findGeneration`](https://github.com/rmsharp/nprcgenekeepr/reference/findGeneration.md)
for generation calculation
