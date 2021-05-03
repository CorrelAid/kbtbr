#' @title KoboClient
#' @description 
#' A class to interact with the KoboToolbox API, extending `crul::HttpClient`.
#' @seealso \code{\link[crul]{HttpClient}}
#' @export
KoboClient <- R6::R6Class("KoboClient",
    inherit = crul::HttpClient,
    private = list(
        base_url = "",
        kobo_token = ""
    ), 
    public = list(
        #' @description
        #' Initialization method for class "KoboClient".
        #' @param base_url character. The full base URL of the API.
        #' @param kobo_token character. The API token. Defaults to a request to
        #'  the system environment.
        initialize = function(base_url,
                              kobo_token = Sys.getenv("KBTBR_TOKEN")) {
            
            # Check and set private fields 
            checkmate::assert_character(kobo_token)
            if (Sys.getenv("KBTBR_TOKEN") == "") {
                usethis::ui_stop(
                    "No valid token detected. Set the KBTBR_TOKEN environment
                    variable or pass the token directly to the function
                    (not recommended)."
                )
            }
            private$kobo_token <- kobo_token
            private$base_url <- base_url

            super$initialize(
                url = base_url,
                headers = list(
                    Authorization = paste0("Token ", kobo_token)
                    )
                )
        },
        #' @description #TODO Foster further understanding. 
        #' @param path character. Path component of the endpoint. 
        #' @param query list. A named list which is parsed to the query
        #'  component. The order is not hierarchical.
        #' @param ... crul-options. Additional option arguments, see
        #'  crul::HttpClient for reference
        get = function(path, query = list(), ...) {
            res <- super$get(path = path, query = query, ...)
            res$raise_for_status()
            res$raise_for_ct_json()
            res$parse("UTF-8") %>% 
                jsonlite::fromJSON()
        }
    )
)