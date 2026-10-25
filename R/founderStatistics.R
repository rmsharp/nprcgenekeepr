## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

#' Founder equivalents, founder genome equivalents and FG's standard error
#'
#' What \code{reportGV()} reports from \code{calcFEFG()} and \code{calcFGSE()},
#' with the founder contributions and the retention scan each built once for
#' both (performance plan Phase 5, H8): the same numbers, warnings and errors,
#' in the same order, as the two calls.
#'
#' @param ped the pedigree, as \code{calcFEFG()} takes it.
#' @param alleles the gene-drop table, as \code{calcFEFG()} takes it.
#' @return A list: \code{feFg}, \code{calcFEFG()}'s list, and \code{fgSE},
#' \code{calcFGSE()}'s number.
#' @noRd
founderStatistics <- function(ped, alleles) {
  fc <- calcFounderContributions(ped, "calcFEFG")
  pedc <- fc$ped
  founders <- getFounders(pedc)
  descendants <- pedc$id[pedc$population & !(pedc$id %in% founders)]
  founderAlleles <- alleles[alleles$id %in% founders, c("id", "V1")]
  colnames(founderAlleles) <- c("id", "allele")
  retained <- retainedFounderAlleles(founderAlleles$allele, alleles,
                                     descendants)

  ## calcFEFG(): calcRetention()'s mean retention per founder.
  perCopy <- rowSums(retained, na.rm = TRUE) / ncol(retained)
  copies <- cbind(founderAlleles, retained = perCopy)
  r <- tapply(copies$retained, copies$id, mean)
  r <- r[names(fc$p)]
  fe <- 1L / sum(fc$p^2L)
  feFg <- if (checkFgDegeneracy(fc$p, r)) {
    list(FE = fe, FG = NA_real_)
  } else {
    list(FE = fe, FG = 1L / sum((fc$p^2L) / r, na.rm = TRUE))
  }

  ## The standard error of FG, as calcFGSE() computes it.
  storage.mode(retained) <- "numeric"
  retentionMatrix <- rowsum(retained, founderAlleles$id) / 2L
  rhat <- rowMeans(retentionMatrix)
  p <- fc$p[names(rhat)]
  k <- ncol(retentionMatrix)
  fgSE <- if (checkFgDegeneracy(p, rhat)) {
    NA_real_
  } else {
    keep <- !is.na(rhat) & rhat > 0L & !is.na(p)
    fg <- 1L / sum((p[keep]^2L) / rhat[keep])
    gradient <- numeric(length(rhat))
    gradient[keep] <- fg^2L * (p[keep]^2L) / (rhat[keep]^2L)
    influence <- as.numeric(crossprod(gradient, retentionMatrix))
    stats::sd(influence) / sqrt(k)
  }
  list(feFg = feFg, fgSE = fgSE)
}
