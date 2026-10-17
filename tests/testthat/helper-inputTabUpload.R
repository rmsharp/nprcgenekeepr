## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Uploads the file at `path` through the real Input module (read, then
## runQcStudbook()) and returns the module's qcResults(), which holds the
## cleaned studbook (`cleaned`), the `errors` and the `warnings` tables.
## A blank minimum age takes the species-and-sex default.
uploadPedigreeFile <- function(path, fileType = "fileTypeExcel",
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
    got$res <- qcResults()
  })
  got$res
}
