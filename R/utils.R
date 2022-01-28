# functions to write
# url builder (take base url, asset type and identifier and output format?)
# if we write the functions outside the classes and set them later in the class
# code readability is higher imo

#' @title Check URL
#' @param path The path, for example appended to the base URL.
#' @return The path string with optionally an appended trailing slash.
#' @noRd
check_repair_path <- function(path) {
    if (substr(path, nchar(path), nchar(path)) != "/") {
        return(paste0(path, "/"))
    } else {
        return(path)
    }
}

#' Helper function to convert R list to JSON-like string
#'
#' @description
#' Converts R lists to JSON-like strings for POST request's body.
#'
#' #' @keywords internal
#'
#' @param list R list that should be converted to the JSON-like string
#'
#' @examples
#' \dontrun{
#' example_body <- list_as_json_char(list(
#'     "name" = "A survey object created via API/R",
#'     "asset_type" = "survey"
#' ))
#' }
#'
list_as_json_char <- function(list) {
    jsonlite::toJSON(x = list, pretty = TRUE, auto_unbox = TRUE) %>%
        as.character()
}
