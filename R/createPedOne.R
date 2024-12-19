#' createPedOne makes the pedOne data object
#'
## Copyright(c) 2017-2024 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' @param savePed logical value if TRUE the pedigree is saved into the
#' packages \code{data} directory
#' @importFrom lubridate mdy
#' @importFrom stringi stri_c
createPedOne <- function(savePed = TRUE) {
  set_seed(10)
  pedOne <- data.frame(
    ego_id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
    `si re` = c(NA, NA, NA, NA, "s1", "s1", "s2", "s2"),
    dam_id = c(NA, NA, NA, NA, "d1", "d2", "d2", "d2"),
    sex = c("F", "M", "M", "F", "F", "F", "F", "M"),
    birth_date = mdy(paste0(
      sample(1:12, 8, replace = TRUE),
      "-",
      sample(1:28, 8, replace = TRUE),
      "-",
      sample(seq(0, 15, by = 3), 8, replace = TRUE) +
        2000
    )),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
  if (savePed) {
    pedigree_dir <- tempdir()
    suppressWarnings(dir.create(pedigree_dir))
    pedigree_dir <- paste0(pedigree_dir, "/data")
    suppressWarnings(dir.create(pedigree_dir))
    save(pedOne, file = stri_c(pedigree_dir, "/pedOne.RData"))
  }
  pedOne
}
