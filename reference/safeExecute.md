# Execute an expression with error handling

Executes an expression with comprehensive error handling. On error, logs
the error and returns a default value instead of stopping execution.
This is particularly useful in Shiny reactive contexts where errors
should be handled gracefully.

## Usage

``` r
safeExecute(
  expr,
  module = "unknown",
  default = NULL,
  silent = FALSE,
  notify = FALSE
)
```

## Arguments

- expr:

  An expression to evaluate.

- module:

  character. Name of the calling module for logging purposes.

- default:

  The value to return if an error occurs. Defaults to NULL.

- silent:

  logical. If TRUE, suppresses the error notification. Defaults to
  FALSE.

- notify:

  logical. If TRUE and in a Shiny context, shows a notification to the
  user. Defaults to FALSE.

## Value

The result of evaluating `expr`, or `default` if an error occurs.

## See also

[`logModuleEvent`](https://github.com/rmsharp/nprcgenekeepr/reference/logModuleEvent.md)
for logging

## Examples

``` r
# Returns 4
safeExecute({ 2 + 2 }, module = "test")
#> [1] 4

# Returns NULL and logs error
safeExecute({ stop("Error!") }, module = "test")
#> [2026-07-04 22:19:22] [ERROR] [test] Error: Error!
#> NULL

# Returns custom default on error
safeExecute({ stop("Error!") }, module = "test", default = data.frame())
#> [2026-07-04 22:19:22] [ERROR] [test] Error: Error!
#> data frame with 0 columns and 0 rows
```
