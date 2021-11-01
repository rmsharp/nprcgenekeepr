# cummulateKValueCounts <- function(kValues, cummulatedKValueCounts) {
#   idCols <- c("id_1", "id_2")
#   valueCols <- names(kValues)[!is.element(names(kValues), idCols)]
#   kinshipIds <- kinshipValues <- kinshipCounts <-
#     vector(mode = "list", length = nrow(kValues))
#   for (row in seq_len(nrow(kValues))) {
#     valuesTable <- table(as.numeric(kValues[row, valueCols]))
#     kinshipIds[[row]] <- as.character(kValues[row, idCols])
#     kinshipValues[[row]] <- as.numeric(names(valuesTable))
#     kinshipCounts[[row]] <- as.numeric(valuesTable)
#   }
#   cummulatedKValuesCounts <-
# }
