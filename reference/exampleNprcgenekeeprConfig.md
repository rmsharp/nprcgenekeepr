# exampleNprcgenekeeprConfig is a loadable version of the example configuration file `example_nprcgenekeepr_config`

It contains a working version of a **nprcgenekeepr** configuration file
created the SNPRC. Users of LabKey's EHR can adapt it to their systems
and put it in their home directory. Instructions are embedded as
comments within the file.

## Usage

``` r
exampleNprcgenekeeprConfig
```

## Format

An object of class `character` of length 34.

## Examples

``` r
library(nprcgenekeepr)
data("exampleNprcgenekeeprConfig")
head(exampleNprcgenekeeprConfig)
#> [1] "# The formatting in this example file is intentionally sloppy to illustrate" 
#> [2] "# the esssential features and to point out what has no effect."              
#> [3] "# Lines beginning with \"#\" are ignored."                                   
#> [4] "# Empty lines are ignored"                                                   
#> [5] "#"                                                                           
#> [6] "# It is critical to have the term being defined immediately before an equals"
```
