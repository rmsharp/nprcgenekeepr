## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
library(testthat)
library(nprcgenekeepr)
## A CRAN check leaves out the slow files named in testthat/slowTestFiles.txt
## (CRAN's 10-minute check limit); with NOT_CRAN "true", as on CI and in local
## runs, every file runs (testthat/helper-slowTestFiles.R).
source(file.path("testthat", "helper-slowTestFiles.R"))
test_check("nprcgenekeepr", filter = cranTestFilter("testthat"), invert = TRUE)
Sys.setenv(R_TESTS = "")
