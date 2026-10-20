# Example nprcgenekeepr configuration file (loadable)

A loadable version of the example configuration file
`example_nprcgenekeepr_config`. It contains a working version of a
**nprcgenekeepr** configuration file created at the SNPRC. Users of
LabKey's EHR can adapt it to their systems and put it in their home
directory. Instructions are embedded as comments within the file.

## Usage

``` r
data(exampleNprcgenekeeprConfig)
```

## Format

An object of class `character` of length 89.

## Examples

``` r
library(nprcgenekeepr)
data("exampleNprcgenekeeprConfig")
head(exampleNprcgenekeeprConfig)
#> [1] "# The formatting in this example file is intentionally sloppy to illustrate"   
#> [2] "# the essential features and to point out what has no effect."                 
#> [3] "# A # that begins a word starts a comment that runs to the end of the line, on"
#> [4] "# a line of its own or after a setting."                                       
#> [5] "# Empty lines are ignored"                                                     
#> [6] "#"                                                                             
```
