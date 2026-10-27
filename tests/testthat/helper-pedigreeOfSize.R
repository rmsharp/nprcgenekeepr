# `n` animals: one trio (A0001 and A0002 the parents of A0003) and founders
# with no recorded relatives. For tests of the Diagram tab's animal-count
# limits: the trio keeps the diagram from being empty when it is drawn (a
# pedigree of only isolated animals shows its own empty-state message), so the
# count is what such a test exercises.
pedigreeOfSize <- function(n) {
  ids <- sprintf("A%04d", seq_len(n))
  sire <- rep(NA_character_, n)
  dam <- rep(NA_character_, n)
  sire[3L] <- ids[1L]
  dam[3L] <- ids[2L]
  data.frame(
    id = ids, sire = sire, dam = dam,
    sex = rep(c("M", "F"), length.out = n), stringsAsFactors = FALSE
  )
}
