# Run the Modular Version of GeneKeepR

Launches the modularized Shiny application for testing purposes. This
version uses the new module-based architecture with a Home tab and
improved UI components.

## Usage

``` r
runModularApp(port = 6013L, launch.browser = TRUE)
```

## Arguments

- port:

  Integer port number for the Shiny server (default 6013)

- launch.browser:

  Logical; whether to launch browser (default TRUE)

## Value

Returns the error condition of the Shiny application when it terminates.

## Details

This function runs the modular version of the application which
includes:

- Home tab with navigation buttons

- Modular Input tab with enhanced QC display

- Dynamic error and changed columns tabs

- Enhanced Pedigree Browser with focal animal support

- Genetic Value Analysis with visualizations

- Summary Statistics with popovers

- Breeding Groups with group panels

- Age-Sex Pyramid with enhanced controls

Use
[`runGeneKeepR`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
to run the original monolithic version.

## Examples

``` r
if (interactive()) {
  library(nprcgenekeepr)
  runModularApp()
}
```
