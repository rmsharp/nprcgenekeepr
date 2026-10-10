## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

# A pedigree in which GONE_X, GONE_Y, GONE_Z, GONE_P and GONE_Q are listed in
# the sire or dam column but have no row of their own, the case qcStudbook()
# repairs with addParents(). Every animal lists both parents, so the repair adds
# no unknown-parent placeholder ids and a tree built from the raw pedigree can be
# compared with one built after qcStudbook(). K is in a loop: its sire S1 and its
# dam D1 share the sire GONE_X. N descends only from absent parents.
absentParentPed <- function() {
  data.frame(
    id = c("S1", "D1", "K", "N"),
    sire = c("GONE_X", "GONE_X", "S1", "GONE_P"),
    dam = c("GONE_Y", "GONE_Z", "D1", "GONE_Q"),
    sex = c("M", "F", "M", "F"),
    birth = as.Date(c("2000-01-01", "2001-01-01", "2008-01-01", "2005-01-01")),
    stringsAsFactors = FALSE
  )
}

# The same animals as two pedigree trees: raw, from the pedigree as given (the
# absent parents are not in the tree), and qc, after qcStudbook() has added a
# row for each of them.
absentParentTrees <- function() {
  ped <- absentParentPed()
  list(
    raw = createPedTree(ped[, c("id", "sire", "dam")]),
    qc = createPedTree(qcStudbook(ped,
      minSireAge = 0, minDamAge = 0, reportErrors = FALSE
    ))
  )
}
