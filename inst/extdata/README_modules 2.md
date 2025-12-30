
## Installation

1. Copy `mod_pyramid.R` and `utils_pyramid.R` to your `R/` directory
2. Make sure you have required packages: `shiny`, `ggplot2`, `dplyr`

## Usage

```r
# In your UI
mod_pyramid_ui("pyramid1")

# In your server
pyramidResults <- mod_pyramid_server("pyramid1", your_pedigree_data)
```

## Requirements

- R >= 4.0.0
- shiny
- ggplot2
- dplyr

See `example_usage.R` for complete examples.
