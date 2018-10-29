#' createPedSix makes the pedSix data object
#'
#' @importFrom lubridate mdy
#' @export
createPedSix <- function() {
  set.seed(123)
  pedFive <- data.frame(id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
                        sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
                        dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
                        sex = c("F", "F", "M", "F", "F", "F", "F", "M"),
                        birth = mdy(
                          paste0(sample(1:12, 8, replace = TRUE), "-",
                                 sample(1:28, 8, replace = TRUE), "-",
                                 sample(seq(0, 15, by = 3), 8, replace = TRUE) +
                                   2000)),
                        stringsAsFactors = FALSE)
  pedSix <- data.frame(pedFive[ , names(pedFive) != "birth"], ped1)
  pedSix$birth[pedSix$id %in% c("s1", "s2", "d1", "d2")] - dyears(20)
  names(pedSix) <- c("Ego Id", "Sire Id", "Dam", "Sex", "Birth Date")
  save(pedSix, file = "data/pedSix.RData")
  pedSix
}
