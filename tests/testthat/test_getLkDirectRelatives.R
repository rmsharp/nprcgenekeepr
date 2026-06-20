#' Copyright(c) 2017-2024 R. Mark Sharp
#' This file is part of nprcgenekeepr

test_that(
  "getLkDirectRelatives throws an error with no LabKey session connection",
  {
    expect_warning(getLkDirectRelatives(), "The file should be named:")
  }
)

test_that(
  paste0(
    "getLkDirectRelatives obtains its pedigree via getPedigreeSource ",
    "and walks the strict ancestor/descendant lineage"
  ),
  {
    skip_if_not_installed("mockery")
    # Founders S1, D1, X1; O1 & O2 are full sibs of S1 x D1;
    # GC1 is the offspring of O1 x X1. Focal = O1.
    # The strict up/down walk reaches O1's parents (S1, D1), O1's descendant
    # (GC1), and GC1's unrelated parent placeholder (X1) -- but NOT the
    # collateral sibling O2. (getPedDirectRelatives' full-component walk WOULD
    # include O2; this test is the guard against silently swapping the walk.)
    fixture <- data.frame(
      id    = c("S1", "D1", "X1", "O1", "O2", "GC1"),
      sex   = c("M", "F", "M", "F", "M", "M"),
      birth = c("2000-01-01", "2000-01-01", "2000-01-01",
                "2010-01-01", "2010-01-01", "2018-01-01"),
      death = c(NA, NA, NA, NA, NA, NA),
      exit  = c(NA, NA, NA, NA, NA, NA),
      dam   = c(NA, NA, NA, "D1", "D1", "O1"),
      sire  = c(NA, NA, NA, "S1", "S1", "X1"),
      stringsAsFactors = FALSE
    )
    srcMock <- mockery::mock(fixture)
    mockery::stub(getLkDirectRelatives, "getPedigreeSource", srcMock)
    # Keep the pre-refactor code path offline + deterministic as well, so this
    # test fails RED on the expect_called assertion rather than on a network
    # call: stub the legacy fetch/site lookups to the same fixture.
    mockery::stub(getLkDirectRelatives, "getSiteInfo",
                  list(lkPedColumns = names(fixture),
                       mapPedColumns = names(fixture)))
    mockery::stub(getLkDirectRelatives, "getDemographics",
                  function(...) fixture)

    result <- getLkDirectRelatives(ids = "O1")

    mockery::expect_called(srcMock, 1)
    expect_setequal(result$id, c("O1", "S1", "D1", "GC1", "X1"))
    expect_false("O2" %in% result$id)
  }
)
