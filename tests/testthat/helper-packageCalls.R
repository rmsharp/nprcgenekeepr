## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## One row per `pkg::name` or `pkg:::name` call in the R file `path`: its line,
## its package, and whether it is guarded. R's parser reads the file, so a
## comment or a string holding "pkg::name" is not a call. A call is guarded when
## it sits in the branch of an `if` whose condition asks
## requireNamespace("pkg") (test_packageCallsDeclared.R).
packageCallsIn <- function(path) {
  parsed <- utils::getParseData(parse(path, keep.source = TRUE))
  none <- data.frame(line = integer(), pkg = character(), guarded = logical())
  if (is.null(parsed)) {
    return(none)
  }
  operators <- parsed[parsed$token %in% c("NS_GET", "NS_GET_INT"), ]
  if (nrow(operators) == 0L) {
    return(none)
  }
  rows <- lapply(operators$id, function(operator) {
    parent <- parsed$parent[parsed$id == operator]
    nameToken <- parsed[parsed$parent == parent &
      parsed$token %in% c("SYMBOL_PACKAGE", "STR_CONST"), ]
    pkg <- gsub("[\"'`]", "", nameToken$text[1L])
    data.frame(
      line = nameToken$line1[1L], pkg = pkg,
      guarded = callIsGuarded(parsed, parent, pkg)
    )
  })
  do.call(rbind, rows)
}

## TRUE when the walk from node `id` to the top passes through the taken branch
## of `if (requireNamespace("pkg", ...))`. A negated condition or the `else`
## branch does not count: there the package is the one known to be missing.
callIsGuarded <- function(parsed, id, pkg) {
  asksForPkg <- paste0("^requireNamespace\\(\\s*[\"']", pkg, "[\"']")
  node <- id
  parent <- parsed$parent[parsed$id == node]
  while (parent != 0L) {
    kids <- parsed[parsed$parent == parent, ]
    if (any(kids$token == "IF")) {
      ## An `if` holds its condition, then the branch taken, then any `else`.
      branches <- kids$id[kids$token == "expr"]
      if (branches[2L] == node &&
        grepl(asksForPkg, utils::getParseText(parsed, branches[1L]))) {
        return(TRUE)
      }
    }
    node <- parent
    parent <- parsed$parent[parsed$id == node]
  }
  FALSE
}

## Reads a comma-separated DESCRIPTION dependency field (Imports/Suggests/
## Depends/...) and returns the bare package names, with any parenthetical
## version constraint (e.g. "Rlabkey (>= 3.2.0)") stripped off.
readDescriptionField <- function(field) {
  path <- testthat::test_path("..", "..", "DESCRIPTION")
  raw <- read.dcf(path, fields = field)[1L, field]
  if (is.na(raw)) {
    return(character(0L))
  }
  pkgs <- strsplit(raw, ",")[[1L]]
  pkgs <- trimws(gsub("\\s*\\([^)]*\\)\\s*$", "", trimws(pkgs)))
  pkgs[nzchar(pkgs)]
}

## The rows of packageCallsIn() that a check would object to: not guarded, not a
## package listed in `declared`, not a base package, and not this package.
undeclaredPackageCalls <- function(calls, declared, self = "nprcgenekeepr") {
  base <- rownames(utils::installed.packages(priority = "base"))
  calls[!calls$guarded & !(calls$pkg %in% c(declared, base, self)), ]
}
