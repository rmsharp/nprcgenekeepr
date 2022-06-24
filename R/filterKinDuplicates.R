# Relations.R
# 2015-08-31
## Copyright(c) 2017-2022 R. Mark Sharp
## This file is part of nprcgenekeepr


###############################################################################
# filterKinDuplicates <- function(kin) {
#   # data.frame {id1, id2, kinship}
#   pairs <- c()
#   keep <- c()
#
#   for (i in 1:nrow(kin)) {
#     pair <- paste(kin$id1[i], kin$id2[i], sep = "")
#     rev.pair <- paste(kin$id2[i], kin$id1[i], sep = "")
#
#     if (!(rev.pair %in% pairs)) {
#       pairs <- c(pairs, pair)
#       keep <- c(keep, i)
#     }
#   }
#
#   return(kin[keep, ])
# }
