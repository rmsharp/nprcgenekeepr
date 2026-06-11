# Main Application Server for nprcgenekeepr

Server function for the main GeneKeepR Shiny application. Initializes
all modules and manages shared reactive state between them.

## Usage

``` r
appServer(input, output, session)
```

## Arguments

- input:

  Shiny input object

- output:

  Shiny output object

- session:

  Shiny session object

## Details

The server handles:

- Configuration loading from site-specific config files

- Navigation button handlers for the home page

- Dynamic tab management for QC errors and changed columns

- Module initialization and data flow between modules

## See also

[`appUI`](https://github.com/rmsharp/nprcgenekeepr/reference/appUI.md)
for the corresponding UI function

[`modInputServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modInputServer.md)
for data input module

[`modPedigreeServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modPedigreeServer.md)
for pedigree browser module

[`modGeneticValueServer`](https://github.com/rmsharp/nprcgenekeepr/reference/modGeneticValueServer.md)
for genetic value analysis

[`shouldShowChangedColsTab`](https://github.com/rmsharp/nprcgenekeepr/reference/shouldShowChangedColsTab.md)
for changed columns tab logic
