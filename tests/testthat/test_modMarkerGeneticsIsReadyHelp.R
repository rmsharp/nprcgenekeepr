## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S999, CB5 of docs/audits/DOCS_AUDIT_PART2_SLICE_6D_RECHECK_2026-10-14.md):
## the help of modMarkerGeneticsServer() said only that its returned `isReady`
## is "TRUE once comparisonTable has a value". The answer used to stop with an
## error for a genotype file the module cannot use; it now says FALSE, and the
## owner approved the clause that says so (S999): "isReady, TRUE once
## comparisonTable has a value, and FALSE (never an error) when it has none,
## including when the uploaded genotype file cannot be used;". The help is read
## in the two places it lives: the generated man page and the roxygen block in
## R/. Both readers need the source tree (man/ and R/ do not exist under an
## installed package) and skip without it.

## helpPlaces() and skipUnlessHelpInSourceTree() are in helper-pageText.R.

isReadyPlaces <- helpPlaces("modMarkerGeneticsServer", "modMarkerGenetics.R")

## Sanity check on the two readers (green at HEAD): they find the sentence the
## RED tests below are about, so a reader that finds nothing cannot pass.
test_that("the readers find the isReady sentence of the Marker Genetics module's help", {
  skipUnlessHelpInSourceTree(isReadyPlaces)
  for (read in isReadyPlaces) {
    expect_match(read(), "isReady, TRUE once comparisonTable has a value",
                 fixed = TRUE)
  }
})

## The failing tests (RED at HEAD).
for (place in names(isReadyPlaces)) {
  test_that(paste0("the Marker Genetics module's ", place, " says isReady is FALSE, never an error, when the genotype file cannot be used"), {
    skipUnlessHelpInSourceTree(isReadyPlaces)
    text <- isReadyPlaces[[place]]()
    expect_match(text,
                 paste("isReady, TRUE once comparisonTable has a value, and",
                       "FALSE (never an error) when it has none, including",
                       "when the uploaded genotype file cannot be used;"),
                 fixed = TRUE, info = text)
  })
}
