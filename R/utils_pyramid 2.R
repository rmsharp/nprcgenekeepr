
#' Calculate age from birth date
#' @export
calculate_age <- function(birth_dates, unit = "years") {
  age_days <- as.numeric(Sys.Date() - as.Date(birth_dates))
  if (unit == "years") {
    return(age_days / 365.25)
  } else {
    return(age_days / 30.44)
  }
}

#' Validate pedigree data
#' @export
validate_pyramid_data <- function(data) {
  required <- c("id", "sex", "birth_date")
  missing <- setdiff(required, names(data))

  if (length(missing) > 0) {
    return(list(valid = FALSE,
                messages = paste("Missing columns:", paste(missing, collapse = ", "))))
  }
  return(list(valid = TRUE, messages = character(0)))
}
