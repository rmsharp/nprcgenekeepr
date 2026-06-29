## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#
# Test fixtures and an INDEPENDENT reference recompute for the founder-genome-
# equivalent sampling SE (issue #82, Slice 1). These live only in the test
# harness; the shipped estimator is R/calcFGSE.R.
#
# fgSEReference() forms the EXPLICIT delta-method sandwich
#   sqrt( grad' (Sigma_hat / K) grad ),  grad_f = FG^2 * p_f^2 / r_f^2,
# with Sigma_hat = cov(t(R)) the F x F within-iteration founder covariance.
# calcFGSE() instead uses the algebraically identical O(K*F) influence form
# sd(crossprod(g, R)) / sqrt(K); the two agreeing is a genuine cross-check
# (the calcGUSE independent-recompute test pattern), not a tautology.

# Per-founder retention matrix R (F x K, rows id-sorted, entries in {0,0.5,1}).
# rowMeans(R) equals calcRetention() to machine precision.
fgRetentionMatrix <- function(ped, alleles) {
  fc <- calcFounderContributions(ped, "calcFG")
  pedc <- fc$ped
  f0 <- getFounders(pedc)
  desc <- pedc$id[pedc$population & !(pedc$id %in% f0)]
  fdf <- alleles[alleles$id %in% f0, c("id", "V1")]
  colnames(fdf) <- c("id", "allele")
  alD <- alleles[
    alleles$id %in% desc,
    !(colnames(alleles) %in% c("id", "parent"))
  ]
  retmat <- apply(alD, 2L, function(a) fdf$allele %in% a)
  storage.mode(retmat) <- "numeric"
  rowsum(retmat, fdf$id) / 2
}

# Independent sandwich-form reference SE of FG. Name-aligned throughout;
# returns NA on the hard-fail case (a contributing founder with zero retention).
fgSEReference <- function(ped, alleles) {
  fc <- calcFounderContributions(ped, "calcFG")
  rmat <- fgRetentionMatrix(ped, alleles)
  rhat <- rowMeans(rmat)
  p <- fc$p[names(rhat)] # align p to rhat by NAME (Dragon D-3)
  k <- ncol(rmat)
  if (any(!is.na(p) & p > 0 & !is.na(rhat) & rhat == 0)) {
    return(NA_real_)
  }
  keep <- !is.na(rhat) & rhat > 0 & !is.na(p)
  fg <- 1 / sum((p[keep]^2) / rhat[keep])
  g <- numeric(length(rhat))
  g[keep] <- fg^2 * (p[keep]^2) / (rhat[keep]^2)
  sqrt(as.numeric(crossprod(g, stats::cov(t(rmat)) %*% g)) / k)
}

# Small fixture pedigree. The first founder is isolated (no descendants), so its
# contribution p == 0 and its allele is never retained -- the clean p==0,r==0
# drop. When `unsorted = TRUE` the founder ids are in a pedigree-row order that
# differs from sorted order, exercising founder-order alignment (Dragon D-3).
makeFgPed <- function(unsorted = FALSE, asFactor = FALSE) {
  fIds <- if (unsorted) {
    c("Z3", "Z1", "Z0", "Z2") # row order != sorted order
  } else {
    c("P0", "P1", "P2", "P3")
  }
  iso <- fIds[1L]
  a <- fIds[2L]
  b <- fIds[3L]
  cc <- fIds[4L]
  ped <- data.frame(
    id = c(fIds, "D1", "D2", "D3", "D4"),
    sire = c(NA, NA, NA, NA, a, a, cc, cc),
    dam = c(NA, NA, NA, NA, b, b, b, a),
    stringsAsFactors = FALSE
  )
  ped["gen"] <- findGeneration(ped$id, ped$sire, ped$dam)
  ped$population <- getGVPopulation(ped, NULL)
  if (asFactor) {
    ped$id <- as.factor(ped$id)
    ped$sire <- as.factor(ped$sire)
    ped$dam <- as.factor(ped$dam)
  }
  ped
}

# Controlled gene-drop allele table for makeFgPed(). Each founder gets two fixed
# integer allele labels; descendant cells in column k hold exactly the alleles
# of the founders flagged "present" that column (deterministic in k, mid-range
# retention with column-to-column variation). The isolated founder is never
# present. When `hardFail = TRUE` the third contributor (p > 0) is present in
# ZERO columns, forcing r == 0 -> the hard-fail degeneracy.
makeFgAlleles <- function(ped, k = 600L, hardFail = FALSE) {
  f0 <- as.character(getFounders(ped)) # pedigree-row order
  desc <- as.character(ped$id[ped$population & !(ped$id %in% f0)])
  labs <- lapply(seq_along(f0), function(i) c(10L * i + 1L, 10L * i + 2L))
  names(labs) <- f0
  iso <- f0[1L]
  con <- f0[-1L]
  presentInCol <- function(fid, col) {
    if (fid == iso) {
      return(FALSE)
    }
    j <- match(fid, con)
    if (j == 3L) {
      return(!hardFail && (col %% 3L) == 0L) # ~0.333, or never (hard fail)
    }
    if (j == 1L) {
      return((col %% 4L) != 0L) # ~0.75
    }
    (col %% 2L) == 0L # j == 2L: 0.50  (covers every gap of contributor 1)
  }
  nFRows <- 2L * length(f0)
  nDRows <- 2L * length(desc)
  fLabs <- unlist(labs, use.names = FALSE) # length 2F, fixed every column
  vmat <- matrix(NA_real_, nrow = nFRows + nDRows, ncol = k)
  for (col in seq_len(k)) {
    vmat[seq_len(nFRows), col] <- fLabs
    present <- f0[vapply(f0, presentInCol, logical(1L), col = col)]
    pl <- unlist(labs[present], use.names = FALSE)
    dcol <- rep(pl[1L], nDRows) # filler is a present label (introduces no founder)
    dcol[seq_along(pl)] <- pl
    vmat[(nFRows + 1L):(nFRows + nDRows), col] <- dcol
  }
  ids <- c(rep(f0, each = 2L), rep(desc, each = 2L))
  parent <- rep(c("sire", "dam"), times = length(ids) / 2L)
  al <- data.frame(id = ids, parent = parent, vmat, stringsAsFactors = FALSE)
  colnames(al) <- c("id", "parent", paste0("V", seq_len(k)))
  al
}
