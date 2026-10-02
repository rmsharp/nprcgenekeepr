## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Male-left placement for a mating whose mate is drawn as a duplicate node
## (S858; found S857). makePedigreeMatingLayout() documents that a mating
## where each parent has exactly one mate renders the male on the left
## (issue #145). On the bundled rhesusPedigree two such matings rendered the
## male on the RIGHT: both parents have parents of their own, so the mate is
## drawn as a duplicate node, the S666 correction pass skips the unit, and
## the seeding took the side of the children's mean. These tests pin the
## documented rule on the real fixture; they do not pin any x value.

## Same measuring approach as test_maleLeftSweepSurvival.R, repeated here so
## each file runs on its own.
.maleFemaleX <- function(ped, edgeStyle) {
  lay <- suppressWarnings(
    makePedigreeMatingLayout(ped, edgeStyle = edgeStyle))
  nd <- lay$nodes
  e <- lay$edges
  d2r <- lay$duplicateToReal
  realOf <- function(i) ifelse(i %in% names(d2r), d2r[i], i)
  sexOf <- stats::setNames(as.character(ped$sex), as.character(ped$id))
  walkBack <- function(n) {
    repeat {
      if (!grepl("^__", n) || n %in% names(d2r)) return(n)
      incoming <- e$from[e$to == n]
      if (length(incoming) != 1L) return(NA_character_)
      n <- incoming
    }
  }
  unions <- unique(e$to[grepl("^__union_", e$to)])
  rows <- lapply(unions, function(u) {
    parents <- vapply(e$from[e$to == u], walkBack, "")
    if (length(parents) != 2L || anyNA(parents)) return(NULL)
    s <- sexOf[realOf(parents)]
    if (!setequal(s, c("M", "F"))) return(NULL)
    m <- parents[s == "M"]
    f <- parents[s == "F"]
    data.frame(maleReal = realOf(m), femaleReal = realOf(f),
               maleX = nd$x[match(m, nd$id)], femaleX = nd$x[match(f, nd$id)],
               duplicated = m %in% names(d2r) || f %in% names(d2r),
               stringsAsFactors = FALSE)
  })
  out <- do.call(rbind, rows)
  units <- table(c(out$maleReal, out$femaleReal))
  out$oneMateEach <- as.integer(units[out$maleReal]) == 1L &
    as.integer(units[out$femaleReal]) == 1L
  out
}

.duplicateMatePairs <- data.frame(
  male = c("D0Z114", "V1X2X3"), female = c("4CHDK1", "SH0L6S"),
  stringsAsFactors = FALSE)

for (style in c("rectilinear", "direct")) {
  local({
    edgeStyle <- style
    skip_if_not_installed("quadprog")
    units <- .maleFemaleX(nprcgenekeepr::rhesusPedigree, edgeStyle)

    test_that(paste0("the two duplicate-mate rhesusPedigree pairs render ",
                     "male-left (", edgeStyle, ")"), {
      for (i in seq_len(nrow(.duplicateMatePairs))) {
        row <- units[units$maleReal == .duplicateMatePairs$male[i] &
                       units$femaleReal == .duplicateMatePairs$female[i], ]
        expect_equal(nrow(row), 1L)
        expect_true(row$duplicated)
        expect_lt(row$maleX, row$femaleX)
      }
    })

    test_that(paste0("every one-mate-each rhesusPedigree mating renders ",
                     "male-left, duplicate mate or not (", edgeStyle, ")"), {
      one <- units[units$oneMateEach, ]
      expect_gt(nrow(one), 55L)
      expect_true(all(one$maleX < one$femaleX),
                  info = paste("male-right:", toString(
                    paste(one$maleReal, one$femaleReal)[
                      one$maleX >= one$femaleX])))
    })

    test_that(paste0("duplicate-mate matings already male-left stay so (",
                     edgeStyle, ")"), {
      key <- paste(units$maleReal, units$femaleReal)
      excluded <- paste(.duplicateMatePairs$male, .duplicateMatePairs$female)
      others <- units[units$oneMateEach & units$duplicated &
                        !key %in% excluded, ]
      expect_gt(nrow(others), 15L)
      expect_true(all(others$maleX < others$femaleX))
    })
  })
}
