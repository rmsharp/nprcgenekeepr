## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Make a CEPH-style pedigree for each id
#'
#' Part of Relations
#'
#' Creates a CEPH-style pedigree for each id, consisting of three generations:
#' the id, the parents, and the grandparents. Inserts NA for unknown pedigree
#' members.
#'
#' @param id character vector with unique identifier for an individual
#' @param sire character vector with unique identifier for an
#' individual's father (\code{NA} if unknown).
#' @param dam character vector with unique identifier for an
#' individual's mother (\code{NA} if unknown).
#' @return List of lists: fields: id, subfields: parents, pgp, mgp.
#' Pedigree information converted into a CEPH-style list. The top level
#' list elements are the IDs from id. Below each ID is a list of three
#' elements: parents (sire, dam), paternal grandparents (pgp: sire, dam),
#' and maternal grandparents (mgp: sire, dam).
#'
#' @export
#' @examples
#' library(nprcgenekeepr)
#' ped <- nprcgenekeepr::lacy1989Ped
#' pedCEPH <- makeCEPH(ped$id, ped$sire, ped$dam)
#' head(ped)
#' head(pedCEPH$F)
makeCEPH <- function(id, sire, dam) {
  ped <- data.frame(
    sire = sire, dam = dam, row.names = id,
    stringsAsFactors = FALSE
  )

  ceph <- list()
  for (i in id) {
    sire <- ped[i, "sire"]
    dam <- ped[i, "dam"]
    parents <- c(sire, dam)

    if (is.na(sire)) {
      pgp <- c(NA, NA)
    } else {
      pgp <- c(ped[sire, "sire"], ped[sire, "dam"])
    }

    if (is.na(dam)) {
      mgp <- c(NA, NA)
    } else {
      mgp <- c(ped[dam, "sire"], ped[dam, "dam"])
    }

    ceph[[i]] <- list(parents = parents, pgp = pgp, mgp = mgp)
  }

  ceph
}
