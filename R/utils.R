# functions to write
# url builder (take base url, asset type and identifier and output format?)
# if we write the functions outside the classes and set them later in the class
# code readability is higher imo


#' @title Check URL
#' @param path The path, for example appended to the base URL.
#' @return The path string with optionally an appended trailing slash.
check_repair_path <- function(path) {
    if (substr(path, nchar(path), nchar(path)) != "/") {
        return(paste0(path, "/"))
    } else {
        return(path)
    }
}
