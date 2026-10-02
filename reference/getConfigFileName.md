# Get the configuration file name for the system

Get the configuration file name for the system

## Usage

``` r
getConfigFileName(sysInfo)
```

## Arguments

- sysInfo:

  object returned by Sys.info()

## Value

A named character vector of length two: `homeDir` is the user's home
directory and `configFile` is the expected configuration file path. Only
`sysInfo[["sysname"]]` is used, to choose the file name
(`_nprcgenekeepr_config` on Windows, otherwise `.nprcgenekeepr_config`).

## Examples

``` r
library(nprcgenekeepr)
sysInfo <- Sys.info()
config <- getConfigFileName(sysInfo)
```
