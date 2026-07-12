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

A list of site specific information used by the application.

Currently this returns the following character strings in a named list.

1.  `center` – One of "SNPRC" or "ONPRC"

2.  `baseUrl` – If `center` is "SNPRC", baseUrl is one of
    "https://boomer.txbiomed.local:8080/labkey" or
    "https://vger.txbiomed.local:8080/labkey". To allow testing, if
    `center` is "ONPRC" baseUrl is
    "https://boomer.txbiomed.local:8080/labkey".

3.  `schemaName` – If `center` is "SNPRC", schemaName is "study". If
    `center` is "ONPRC", schemaName is "study"

4.  `folderPath` – If `center` is "SNPRC", folderPath is "/SNPRC". If
    `center` is "ONPRC", folderPath is "/ONPRC"

5.  `queryName` – is "demographics"

6.  `requiredCols` – the required studbook columns, from
    [`getRequiredCols`](https://github.com/rmsharp/nprcgenekeepr/reference/getRequiredCols.md)

7.  `possibleCols` – the possible studbook columns, from
    [`getPossibleCols`](https://github.com/rmsharp/nprcgenekeepr/reference/getPossibleCols.md)

8.  `includeColumns` – the superset of report-inclusion columns, from
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
#> [1] "6.17.0-1018-azure"
#> 
#> $version
#> [1] "#18~24.04.1-Ubuntu SMP Thu May 28 16:39:11 UTC 2026"
#> 
#> $nodename
#> [1] "runnervm5mmn9"
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
#> [21] "second"       "first_name"   "second_name"  "recordStatus"
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
#> [1] "6.17.0-1018-azure"
#> 
#> $version
#> [1] "#18~24.04.1-Ubuntu SMP Thu May 28 16:39:11 UTC 2026"
#> 
#> $nodename
#> [1] "runnervm5mmn9"
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
#> [21] "second"       "first_name"   "second_name"  "recordStatus"
#> 
#> $includeColumns
#>  [1] "id"          "sex"         "age"         "birth"       "exit"       
#>  [6] "population"  "condition"   "origin"      "first_name"  "second_name"
#> 
```
