## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Default (no-config) site parameters
#'
#' The single source of truth for the LabKey/site parameters returned by
#' \code{\link{getSiteInfo}} when no configuration file is present. These are
#' the ONPRC defaults: center "ONPRC", the PRIME UAT base URL, the \code{study}
#' schema, the \code{/ONPRC/EHR} folder, the \code{demographics} query, and the
#' ONPRC lookup-traversal pedigree columns. Centralizing them here keeps the
#' no-config branch of \code{getSiteInfo()} from drifting from this definition.
#'
#' \code{lkPedColumns} is center-specific: ONPRC uses the lookup-traversal form
#' \code{Id/parents/dam} / \code{Id/parents/sire} (curated genetic-preferred
#' parentage); SNPRC uses flat \code{dam} / \code{sire} (direct columns). See
#' \code{inst/extdata/example_nprcgenekeepr_config}. \code{mapPedColumns} is the
#' one-to-one rename of \code{lkPedColumns} to the package's internal names.
#'
#' @return A named list of seven elements: \code{center}, \code{baseUrl},
#'   \code{schemaName}, \code{folderPath}, \code{queryName},
#'   \code{lkPedColumns}, and \code{mapPedColumns}.
#' @noRd
defaultSiteParams <- function() {
  list(
    center = "ONPRC",
    baseUrl = "https://primeuat.ohsu.edu",
    schemaName = "study",
    folderPath = "/ONPRC/EHR", # nolint: nonportable_path_linter
    queryName = "demographics",
    lkPedColumns = c(
      "Id", "gender", "birth", "death", "lastDayAtCenter",
      "Id/parents/dam", "Id/parents/sire" # nolint: nonportable_path_linter
    ),
    mapPedColumns = c("id", "sex", "birth", "death", "exit", "dam", "sire")
  )
}
