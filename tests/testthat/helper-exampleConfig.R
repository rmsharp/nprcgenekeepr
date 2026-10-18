## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# Path of the example configuration file the package ships
# (inst/extdata/examples/example_nprcgenekeepr_config). It documents the
# optional keys as commented lines, so tests that read the configuration use it
# as the file a site copies unedited.
exampleConfigPath <- function() {
  system.file("extdata", "examples", "example_nprcgenekeepr_config",
              package = "nprcgenekeepr")
}
