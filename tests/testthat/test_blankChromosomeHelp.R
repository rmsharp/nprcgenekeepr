## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## RED (S979; BACKLOG.md:139, S976 audit finding 6, the owner's S976 ruling
## "treat an empty or all-space chromosome as missing"): the help of
## checkLocusMetadata() said "A value counts as present when it is not NA, so an
## empty-string chrom counts as present". That was true of the code and is now
## the behavior the owner ruled wrong: an empty or all-space chrom is missing
## and comes back as NA. The help lives in two places, the generated man page
## and the roxygen block in R/.
##
## The sentence is the owner's to approve (at the RED to GREEN gate, as at S971,
## S977 and S978), so these blocks pin what the help may no longer say and one
## short phrase per place that states the rule ("empty or all-space", the owner's
## own words); the rest of the sentence is free. Both readers need the source
## tree (man/ and R/ do not exist under an installed package) and skip without
## it.

## manText(), roxygenText() and collapseSpace() are in helper-pageText.R.

skipUnlessSourceTree <- function() {
  testthat::skip_if(
    is.na(manText("checkLocusMetadata")) ||
      is.na(roxygenText("checkLocusMetadata.R")),
    "man/*.Rd or R/*.R not available (installed package)"
  )
}

locusMetadataPlaces <- list(
  "man page" = function() manText("checkLocusMetadata"),
  "roxygen block" = function() roxygenText("checkLocusMetadata.R")
)

## Sanity check on the two readers (green at HEAD, and kept by GREEN): they find
## the page, so a reader that finds nothing cannot pass the blocks below.
test_that("the readers find checkLocusMetadata's help", {
  skipUnlessSourceTree()
  for (read in locusMetadataPlaces) {
    expect_match(read(), "three-state coverage model", fixed = TRUE)
  }
})

## The failing tests (RED at HEAD).
for (place in names(locusMetadataPlaces)) {
  test_that(paste0("checkLocusMetadata's ", place, " no longer says an empty-string chrom counts as present"), {
    skipUnlessSourceTree()
    text <- locusMetadataPlaces[[place]]()
    expect_false(grepl("empty-string.{0,12}counts as present", text),
                 info = text)
  })

  test_that(paste0("checkLocusMetadata's ", place, " says an empty or all-space chrom is missing"), {
    skipUnlessSourceTree()
    text <- locusMetadataPlaces[[place]]()
    expect_match(text, "empty or all-space", fixed = TRUE, info = text)
  })
}
