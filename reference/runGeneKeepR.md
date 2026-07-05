# Run the GeneKeepR Shiny Application

Launches the GeneKeepR Shiny application. It uses a module-based
architecture with a Home tab and improved UI components.

## Usage

``` r
runGeneKeepR(port = 6013L, launch.browser = TRUE)
```

## Arguments

- port:

  Integer port number for the Shiny server (default 6013)

- launch.browser:

  Logical; whether to launch browser (default TRUE)

## Value

Returns the error condition of the Shiny application when it terminates.

## Details

The application includes:

- Home tab with navigation buttons

- Input tab with enhanced QC display

- Dynamic error and changed columns tabs

- Enhanced Pedigree Browser with focal animal support

- Genetic Value Analysis with visualizations

- Summary Statistics with popovers

- Breeding Groups with group panels

- Age-Sex Pyramid with enhanced controls

[`runModularApp`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
is a soft-deprecated alias for this function.

## See also

[`runModularApp`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md),
a soft-deprecated alias for this function.

## Examples

``` r
if (FALSE) { # \dontrun{
library(nprcgenekeepr)
runGeneKeepR()
} # }
```
