## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr

test_that(
  "getLkDirectRelatives throws an error with no LabKey session connection",
  {
    expect_warning(getLkDirectRelatives(), "The file should be named:")
  }
)

test_that(
  paste0(
    "getLkDirectRelatives obtains its pedigree via getPedigreeSource ",
    "and walks the full connected component (matching getPedDirectRelatives)"
  ),
  {
    skip_if_not_installed("mockery")
    # Founders S1, D1, X1; O1 & O2 are full sibs of S1 x D1;
    # GC1 is the offspring of O1 x X1. Focal = O1.
    # The full connected-component walk reaches O1's parents (S1, D1), O1's
    # descendant (GC1), GC1's other parent (X1), AND the collateral sibling O2
    # (the other child of S1 x D1) -- i.e. the entire family graph, identical
    # to what getPedDirectRelatives() returns. This test guards that
    # getLkDirectRelatives delegates the walk to getPedDirectRelatives
    # (collaterals included), NOT the old strict ancestor/descendant lineage
    # that excluded O2.
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

    result <- getLkDirectRelatives(ids = "O1")

    mockery::expect_called(srcMock, 1)
    # Full connected component for O1 = the entire fixture, including sib O2.
    expect_setequal(result$id, c("S1", "D1", "X1", "O1", "O2", "GC1"))
    expect_true("O2" %in% result$id)
    # Equivalence: the LabKey walk now matches getPedDirectRelatives' walk.
    expect_setequal(
      result$id,
      getPedDirectRelatives(ids = "O1", ped = fixture)$id
    )
  }
)
