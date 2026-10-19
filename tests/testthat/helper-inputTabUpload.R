## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Uploads the file at `path` through the real Input module (read, then
## runQcStudbook()) and returns the module's qcResults(), which holds the
## cleaned studbook (`cleaned`), the `errors` and the `warnings` tables.
## A blank minimum age takes the species-and-sex default.
uploadPedigreeFile <- function(path, fileType = "fileTypeExcel",
                               separator = ",", minDamAge = "",
                               minSireAge = "") {
  uploadPedigreeFileQc(path, fileType = fileType, separator = separator,
                       minDamAge = minDamAge, minSireAge = minSireAge)$results
}

## The one upload block: uploads the file at `path` through the real Input
## module and returns what the module holds afterwards: `results`, its
## qcResults(); `summary`, its qcSummary() (the counts `errors`, `warnings`
## and `records`); and `ready`, its isReady(). uploadPedigreeFile() returns
## only `results`.
uploadPedigreeFileQc <- function(path, fileType = "fileTypeExcel",
                                 separator = ",", minDamAge = "",
                                 minSireAge = "") {
  got <- new.env()
  shiny::testServer(modInputServer, {
    session$setInputs(fileContent = "pedFile", fileType = fileType,
                      separator = separator, minSireAge = minSireAge,
                      minDamAge = minDamAge)
    session$setInputs(pedigreeFileOne = list(name = basename(path),
                                             datapath = path))
    session$setInputs(getData = 1L)
    got$summary <- session$getReturned()$qcSummary()
    got$results <- qcResults()
    got$ready <- session$getReturned()$isReady()
  })
  list(summary = got$summary, results = got$results, ready = got$ready)
}
