#' Copyright(c) 2017-2022 R. Mark Sharp
#' This file is part of nprcgenekeepr
context("getPotentialPartents")
pedOne <- nprcgenekeepr::rhesusPedigree
pedOne$id <- as.character(pedOne$id)
pedOne$sire <- as.character(pedOne$sire)
pedOne$dam <- as.character(pedOne$dam)
pedOne$birth <- as.Date(pedOne$birth)
pedOne$fromCenter <- TRUE
potentialParents <-
  getPotentialParents(ped = pedOne, minParentAge = 2,
                      maxGestationalPeriod = 210)
ids <- c("BRI2MW", "FEEN9W")
dams_1 <- c("HR70BU", "I2G9D6", "0B7XRI", "J8XZ81", "PHCADH", "HV7LZ3",
           "IMF6BL")
dams_4 <- c("1SIP4V", "DMI0QY", "3PD3U5", "J8XZ81", "73Z6NI", "T5S3BR",
           "PHCADH", "A792ZU", "HV7LZ3", "F3QIL7")
sires_1 <- c("HKTQ40", "MY1AEU", "QWUKUY", "1X40V5", "WDBGPF", "6MGJYG",
             "8LWCAD", "SLN0TF", "Q7F87W", "IQLWH8", "M0YNUR", "RYP77M",
             "8LKBV9", "D0Z114", "1W4GNT", "D1WP48", "CAN12C", "KUENM8",
             "QP1WMJ", "WCPXHD", "DKMJ2Z", "1Y8P15", "4F3ASD", "DKDP5B",
             "XL7AVE", "YPHFHF", "A3UZAN", "7U5NJD", "ELGVC6", "L07M06",
             "4U7JTW", "270UK6", "LUPGF8", "S0ZHJP", "WWZRCW", "H16EC4",
             "81MJXH", "K9TMQP", "GA204Z", "V1X2X3", "P49ZD1", "KY4G8M",
             "9JC6RF", "M5DJVP", "HJLX2B", "SPHGC9", "62PLX3", "QQ24T8",
             "9LZVTE", "VTZFWZ")
sires_4 <- c("HKTQ40", "MY1AEU", "QWUKUY", "1X40V5", "WDBGPF", "6MGJYG",
             "8LWCAD", "SLN0TF", "Q7F87W", "IQLWH8", "M0YNUR", "RYP77M",
             "8LKBV9", "D0Z114", "1W4GNT", "D1WP48", "CAN12C", "KUENM8",
             "QP1WMJ", "WCPXHD", "DKMJ2Z", "1Y8P15", "4F3ASD", "DKDP5B",
             "XL7AVE", "YPHFHF", "A3UZAN", "ELGVC6", "L07M06", "4U7JTW",
             "270UK6", "LUPGF8", "S0ZHJP", "WWZRCW", "H16EC4", "GA204Z",
             "P49ZD1", "KY4G8M", "9JC6RF", "HJLX2B", "QQ24T8", "9LZVTE")
dams <- list(BRI2MW = dams_1, FEEN9W = dams_4)
sires <- list(BRI2MW = sires_1, FEEN9W = sires_4)

test_that("getPotentialParents forms list with correct lists", {
  expect_equal(potentialParents[[1]]$id, ids[1])
  expect_equal(potentialParents[[4]]$id, ids[2])
  expect_equal(potentialParents[[1]]$dams, dams$BRI2MW)
  expect_equal(potentialParents[[4]]$dams, dams$FEEN9W)
  expect_equal(potentialParents[[1]]$sires, sires$BRI2MW)
  expect_equal(potentialParents[[4]]$sires, sires$FEEN9W)
})

