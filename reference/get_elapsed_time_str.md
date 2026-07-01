# Format the elapsed time since a start time

Taken from github.com/rmsharp/rmsutilityr

## Usage

``` r
get_elapsed_time_str(start_time)
```

## Arguments

- start_time:

  a POSIXct time object

## Value

A character vector describing the passage of time in hours, minutes, and
seconds.

## Examples

``` r
start_time <- proc.time()
## do something
elapsed_time <- get_elapsed_time_str(start_time)
```
