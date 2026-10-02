## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

## Male-left placement must survive the min-separation sweep (S857; found
## S789, cause traced S856). makePedigreeMatingLayout() documents that a
## simple two-parent mating (each parent with exactly one mate, neither a
## duplicate node) renders the male on the left (issue #145). On the bundled
## rhesusPedigree two such units rendered the male on the RIGHT: the S666
## correction pass chose the right side, then sweepMinSepBackstop() pushed
## the anchor past its children in a crowded row, and the Decision-1 seeding
## read the side from the children's mean. These tests pin the documented
## rule on the real fixture; they do not pin any x value.

## One row per mixed-sex mating unit: the male's and the female's node x,
## whether either is a duplicate node, and each real parent's unit count.
## A union node's parents are reached through any __jog_ connector nodes.
.maleFemaleUnitX <- function(ped, edgeStyle) {
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
  out$maleUnits <- as.integer(units[out$maleReal])
  out$femaleUnits <- as.integer(units[out$femaleReal])
  out$simple <- !out$duplicated & out$maleUnits == 1L & out$femaleUnits == 1L
  out
}

.exceptionPairs <- data.frame(
  male = c("QL6GH4", "BM40IX"), female = c("3PD3U5", "MTSHHY"),
  stringsAsFactors = FALSE)

for (style in c("rectilinear", "direct")) {
  local({
    edgeStyle <- style
    skip_if_not_installed("quadprog")
    units <- .maleFemaleUnitX(nprcgenekeepr::rhesusPedigree, edgeStyle)

    test_that(paste0("the two squeezed rhesusPedigree pairs render male-left (",
                     edgeStyle, ")"), {
      for (i in seq_len(nrow(.exceptionPairs))) {
        row <- units[units$maleReal == .exceptionPairs$male[i] &
                       units$femaleReal == .exceptionPairs$female[i], ]
        expect_equal(nrow(row), 1L)
        expect_lt(row$maleX, row$femaleX)
      }
    })

    test_that(paste0("every simple rhesusPedigree mating renders male-left (",
                     edgeStyle, ")"), {
      simple <- units[units$simple, ]
      expect_gt(nrow(simple), 30L)
      expect_true(all(simple$maleX < simple$femaleX),
                  info = paste("male-right:", toString(
                    paste(simple$maleReal, simple$femaleReal)[
                      simple$maleX >= simple$femaleX])))
    })

    test_that(paste0("simple pairs other than the two stay male-left (",
                     edgeStyle, ")"), {
      key <- paste(units$maleReal, units$femaleReal)
      excluded <- paste(.exceptionPairs$male, .exceptionPairs$female)
      others <- units[units$simple & !key %in% excluded, ]
      expect_gt(nrow(others), 25L)
      expect_true(all(others$maleX < others$femaleX))
    })
  })
}
