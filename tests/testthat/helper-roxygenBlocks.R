## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Read the roxygen blocks of an R file as roxygen2 8.0.0 groups them into help
## pages, without roxygen2 (a dev-only package, not installed where CI runs the
## tests): a tag's values, the argument names a block's @param lines name, and
## each page's @inheritParams, @param names and function arguments
## (inheritParamsPages(), emptyInheritParams(); test_roxygenInheritParams.R).

## The values of one roxygen tag in a block (lines without the #' prefix).
roxygenTagValues <- function(block, tag) {
  pattern <- paste0("^\\s*@", tag, "(\\s|$)")
  trimws(sub(pattern, "", grep(pattern, block, value = TRUE)))
}

## The argument names a block's own @param lines name: "@param a,b" names both,
## and \dots is `...`.
roxygenParamNames <- function(block) {
  names <- unlist(strsplit(sub("\\s.*$", "", roxygenTagValues(block, "param")),
                           ",", fixed = TRUE))
  names[names == "\\dots"] <- "..."
  names
}

## TRUE when a top-level expression assigns a function (`f <- function(...)`
## or `f = function(...)`, on one line or two).
isFunctionAssignment <- function(expr) {
  is.call(expr) &&
    (identical(expr[[1L]], as.name("<-")) ||
       identical(expr[[1L]], as.name("="))) &&
    is.call(expr[[3L]]) && identical(expr[[3L]][[1L]], as.name("function"))
}

## The help pages of one R file (its lines), each as whether it has
## @inheritParams, its own @param names and its functions' arguments. A block
## is the #' lines between the previous top-level expression and a function;
## blocks join one page by @rdname, else each function is its own page; an
## @noRd block makes no page. Only blocks above a function are read: every
## @inheritParams in R/ sits above one (64 of 64 blocks, S1068).
inheritParamsPages <- function(lines) {
  exprs <- parse(text = lines, keep.source = TRUE)
  refs <- attr(exprs, "srcref")
  pages <- list()
  previousEnd <- 0L
  for (i in seq_along(exprs)) {
    first <- refs[[i]][[1L]]
    above <- lines[seq_len(first - 1L)]
    above <- above[seq_along(above) > previousEnd]
    previousEnd <- refs[[i]][[3L]]
    block <- sub("^#' ?", "", above[startsWith(above, "#'")])
    expr <- exprs[[i]]
    if (length(block) == 0L || length(roxygenTagValues(block, "noRd")) > 0L ||
          !isFunctionAssignment(expr)) {
      next
    }
    page <- c(sub("\\s.*$", "", roxygenTagValues(block, "rdname")),
              as.character(expr[[2L]]))[[1L]]
    old <- pages[[page]]
    pages[[page]] <- list(
      inherits = isTRUE(old$inherits) ||
        length(roxygenTagValues(block, "inheritParams")) > 0L,
      params = c(old$params, roxygenParamNames(block)),
      arguments = c(old$arguments, names(expr[[3L]][[2L]]))
    )
  }
  pages
}

## The pages of one R file (its lines) whose @inheritParams has nothing to
## inherit: their own @param lines name every argument of their functions.
emptyInheritParams <- function(lines) {
  pages <- Filter(function(page) page$inherits, inheritParamsPages(lines))
  empty <- Filter(function(page) {
    length(setdiff(page$arguments, page$params)) == 0L
  }, pages)
  as.character(names(empty))
}
