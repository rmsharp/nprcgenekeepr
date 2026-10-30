## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
#'
#' A documented @examples block should demonstrate the function it documents.
#' These tests read the generated man/*.Rd via tools::Rd2ex (source/dev
#' context); under an installed package (no man/ directory) they skip
#' (exampleLines(), helper-pageText.R).

exampleCode <- function(fn) paste(exampleLines(fn), collapse = "\n")

for (fn in c(
  "getPedDirectRelatives", "cumulateSimKinships", "getIdsWithOneParent"
)) {
  test_that(paste0("@examples for ", fn, " invokes ", fn), {
    code <- exampleCode(fn)
    expect_true(
      grepl(paste0(fn, "("), code, fixed = TRUE),
      info = paste0("documented example for ", fn, " must call ", fn, "()")
    )
  })
}

test_that(paste0(
  "@examples for getPedDirectRelatives does not demonstrate ",
  "getLkDirectRelatives"
), {
  code <- exampleCode("getPedDirectRelatives")
  expect_false(
    grepl("getLkDirectRelatives(", code, fixed = TRUE),
    info = "getPedDirectRelatives example must not call getLkDirectRelatives()"
  )
})
