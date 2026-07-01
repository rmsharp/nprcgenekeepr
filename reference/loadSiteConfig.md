# Load the site configuration for the modular Shiny application

Reads the user's site-configuration file (`~/.nprcgenekeepr_config`, or
`~/_nprcgenekeepr_config` on Windows) using the tolerant
[`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
parser, which handles the documented configuration format (comment
lines, blank lines, and multi-line / quoted / comma-separated values;
see `inst/extdata/example_nprcgenekeepr_config`). The call is wrapped in
`tryCatch` so that a missing or malformed configuration file can never
crash the application on boot: in that case a warning is logged and
`NULL` is returned.

## Usage

``` r
loadSiteConfig()
```

## Value

A named list of site information (as returned by
[`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md))
when a configuration file is present and parseable; otherwise `NULL`.

## Details

This replaces a former `read.table(sep = "=")` call in the application
server that assumed a strict two-column table, could not parse the
documented format, and crashed
[`runModularApp`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
at startup.

## See also

[`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md),
[`getConfigFileName`](https://github.com/rmsharp/nprcgenekeepr/reference/getConfigFileName.md),
[`appServer`](https://github.com/rmsharp/nprcgenekeepr/reference/appServer.md)

## Examples

``` r
library(nprcgenekeepr)
## Reads ~/.nprcgenekeepr_config (or ~/_nprcgenekeepr_config on
## Windows) if it exists; returns NULL when no config file is
## present, so this is safe to run on any machine.
config <- loadSiteConfig()
config
#> NULL
```
