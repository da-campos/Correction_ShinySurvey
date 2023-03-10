# Create a new environment for access within a survey
survey_env <- base::new.env(parent = base::emptyenv())

#' Extract user ID from query string
#'
#'
#' @param query_list The query list object from \code{shiny::parseQueryString}
#'
#' @keywords internal
#' @return User ID
#'
base_extract_user_id <- function(query_list) {
  regmatches(query_list[["user_id"]], regexpr(pattern = "[^*/]+", text = query_list[["user_id"]]))
}


#' Get unique questions from user-input dataframe
#'
#' @param df User-input dataframe of questions
#'
#' @keywords internal
#'
#' @return List of questions
#'
get_questions <- function(df) {

  output <- split(df, factor(df$input_id, levels = unique(df$input_id)))
  names(output) <- NULL
  return(output)

}

#' Split questions based on dependency
#'
#' @param df A data frame subset for one question
#'
#' @keywords internal
#'
#' @return A list where each element is one UI question.
#'
split_dependence <- function(df) {
  if (all(is.na(df$dependence)) | all(!is.na(df$dependence))) {
    list(df)
  } else {
    list(
      df[is.na(df$dependence),],
      df[!is.na(df$dependence),]
    )
  }
}

#' Simple pluck
#'
#' simple and specific version of purrr::pluck to meet use-case
#' @param list A list object
#' @param index A numeric index
#'
#'
#' @keywords internal
#'
#' @return Returns list element.
#'
pluck_by_index <- function(list, index) {
  list[[index]]
}


#' Convert dataframe of questions to list for use in Shiny UI
#'
#' @param df A user supplied dataframe in the format of teaching_r_questions.
#'
#'
#' @keywords internal
#'
#' @return A list of unique questions for each UI element
#'
listUniqueQuestions <- function(df) {

  # Replace any NAs in the option column with "Placeholder"
  df[["option"]][is.na(df[["option"]])] <- "Placeholder"

  # separate unique questions partially -- some in nested list
  partial <- lapply(get_questions(df), split_dependence)

  # pull each element so every UI element (dependence/question combo) is in one list
  output <- NULL

  for (question in 1:length(partial)) {
    output <- c(output, pluck_by_index(partial, question))
  }

  return(output)
}



