# Get site information

Get site information

## Usage

``` r
getSiteInfo(expectConfigFile = TRUE)
```

## Arguments

- expectConfigFile:

  logical parameter when set to `FALSE`, no configuration is looked for.
  Default value is `TRUE`.

## Value

A named list of 20 elements of site specific information used by the
application.

The first seven elements (`center`, `baseUrl`, `schemaName`,
`folderPath`, `queryName`, `lkPedColumns` and `mapPedColumns`) are read
from the configuration file when one exists. A configuration file that
lacks one of these keys causes an error ("Could not find ..."). When no
configuration file exists, the defaults for the ONPRC are returned
instead: center "ONPRC", baseUrl `"https://primeuat.ohsu.edu"`,
schemaName "study", folderPath "/ONPRC/EHR" and queryName
"demographics". A warning is signaled for the missing file only when
`expectConfigFile` is `TRUE`.

The returned list contains the following elements.

1.  `center` – center name, such as "ONPRC" or "SNPRC"

2.  `baseUrl` – base URL of the LabKey server

3.  `schemaName` – LabKey schema name

4.  `folderPath` – LabKey folder path

5.  `queryName` – LabKey query name, "demographics" by default

6.  `lkPedColumns` – LabKey column names for the pedigree

7.  `mapPedColumns` – the package column names that `lkPedColumns` are
    renamed to

8.  `sysname`, `release`, `version`, `nodename`, `machine`, `login`,
    `user` and `effective_user` – character strings from
    [`Sys.info()`](https://rdrr.io/r/base/Sys.info.html)

9.  `homeDir` and `configFile` – the home directory and the expected
    configuration file path, from
    [`getConfigFileName`](https://github.com/rmsharp/nprcgenekeepr/reference/getConfigFileName.md)

10. `requiredCols` – the required studbook columns, from
    [`getRequiredCols`](https://github.com/rmsharp/nprcgenekeepr/reference/getRequiredCols.md)

11. `possibleCols` – the possible studbook columns, from
    [`getPossibleCols`](https://github.com/rmsharp/nprcgenekeepr/reference/getPossibleCols.md)

12. `includeColumns` – the superset of report-inclusion columns, from
    [`getIncludeColumns`](https://github.com/rmsharp/nprcgenekeepr/reference/getIncludeColumns.md)

## Examples

``` r
library(nprcgenekeepr)
## default sends warning if configuration file is missing
suppressWarnings(getSiteInfo())
#> $center
#> [1] "ONPRC"
#> 
#> $baseUrl
#> [1] "https://primeuat.ohsu.edu"
#> 
#> $schemaName
#> [1] "study"
#> 
#> $folderPath
#> [1] "/ONPRC/EHR"
#> 
#> $queryName
#> [1] "demographics"
#> 
#> $lkPedColumns
#> [1] "Id"              "gender"          "birth"           "death"          
#> [5] "lastDayAtCenter" "Id/parents/dam"  "Id/parents/sire"
#> 
#> $mapPedColumns
#> [1] "id"    "sex"   "birth" "death" "exit"  "dam"   "sire" 
#> 
#> $sysname
#> [1] "Linux"
#> 
#> $release
#> [1] "6.17.0-1022-azure"
#> 
#> $version
#> [1] "#22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026"
#> 
#> $nodename
#> [1] "runnervmmprz5"
#> 
#> $machine
#> [1] "x86_64"
#> 
#> $login
#> [1] "unknown"
#> 
#> $user
#> [1] "runner"
#> 
#> $effective_user
#> [1] "runner"
#> 
#> $homeDir
#> [1] "/home/runner"
#> 
#> $configFile
#> [1] "/home/runner/.nprcgenekeepr_config"
#> 
#> $requiredCols
#> [1] "id"    "sire"  "dam"   "sex"   "birth"
#> 
#> $possibleCols
#>  [1] "id"           "sire"         "dam"          "sex"          "species"     
#>  [6] "gen"          "birth"        "exit"         "death"        "age"         
#> [11] "ancestry"     "population"   "origin"       "status"       "condition"   
#> [16] "departure"    "spf"          "vasxOvx"      "pedNum"       "first"       
#> [21] "second"       "first_name"   "second_name"  "recordStatus" "affected"    
#> [26] "name"        
#> 
#> $includeColumns
#>  [1] "id"          "sex"         "age"         "birth"       "exit"       
#>  [6] "population"  "condition"   "origin"      "first_name"  "second_name"
#> 
getSiteInfo(expectConfigFile = FALSE)
#> $center
#> [1] "ONPRC"
#> 
#> $baseUrl
#> [1] "https://primeuat.ohsu.edu"
#> 
#> $schemaName
#> [1] "study"
#> 
#> $folderPath
#> [1] "/ONPRC/EHR"
#> 
#> $queryName
#> [1] "demographics"
#> 
#> $lkPedColumns
#> [1] "Id"              "gender"          "birth"           "death"          
#> [5] "lastDayAtCenter" "Id/parents/dam"  "Id/parents/sire"
#> 
#> $mapPedColumns
#> [1] "id"    "sex"   "birth" "death" "exit"  "dam"   "sire" 
#> 
#> $sysname
#> [1] "Linux"
#> 
#> $release
#> [1] "6.17.0-1022-azure"
#> 
#> $version
#> [1] "#22-Ubuntu SMP Mon Jul 27 17:24:03 UTC 2026"
#> 
#> $nodename
#> [1] "runnervmmprz5"
#> 
#> $machine
#> [1] "x86_64"
#> 
#> $login
#> [1] "unknown"
#> 
#> $user
#> [1] "runner"
#> 
#> $effective_user
#> [1] "runner"
#> 
#> $homeDir
#> [1] "/home/runner"
#> 
#> $configFile
#> [1] "/home/runner/.nprcgenekeepr_config"
#> 
#> $requiredCols
#> [1] "id"    "sire"  "dam"   "sex"   "birth"
#> 
#> $possibleCols
#>  [1] "id"           "sire"         "dam"          "sex"          "species"     
#>  [6] "gen"          "birth"        "exit"         "death"        "age"         
#> [11] "ancestry"     "population"   "origin"       "status"       "condition"   
#> [16] "departure"    "spf"          "vasxOvx"      "pedNum"       "first"       
#> [21] "second"       "first_name"   "second_name"  "recordStatus" "affected"    
#> [26] "name"        
#> 
#> $includeColumns
#>  [1] "id"          "sex"         "age"         "birth"       "exit"       
#>  [6] "population"  "condition"   "origin"      "first_name"  "second_name"
#> 
```
