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

Character vector with expected configuration file

## Examples

``` r
library(nprcgenekeepr)
sysInfo <- Sys.info()
config <- getConfigFileName(sysInfo)
```
