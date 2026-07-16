# Log module events

Centralized logging function for Shiny module events. Provides
consistent logging format across all modules with configurable log
levels.

## Usage

``` r
logModuleEvent(module, message, level = "INFO", ...)
```

## Arguments

- module:

  character. Name of the module generating the log message.

- message:

  character. The log message to record.

- level:

  character. Log level: "DEBUG", "INFO", "WARN", or "ERROR". Defaults to
  "INFO".

- ...:

  Additional arguments passed to the log message (for sprintf-style
  formatting).

## Value

Invisible NULL. Called for side effect of logging.

## See also

[`safeExecute`](https://github.com/rmsharp/nprcgenekeepr/reference/safeExecute.md)
for error-safe execution with logging

## Examples

``` r
logModuleEvent("modInput", "File uploaded successfully")
logModuleEvent("modPedigree", "Processing %d animals", level = "DEBUG", 100)
logModuleEvent("modGeneticValue", "Calculation failed", level = "ERROR")
#> [2026-07-16 05:38:50] [ERROR] [modGeneticValue] Calculation failed
```
