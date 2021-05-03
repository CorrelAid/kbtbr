#' KoboClient
#' @description a class to interact with the KoboToolbox API
KoboClient <- R6::R6Class(
    "KoboClient",
    private = list(
        base_url = "",
        kobo_token = ""
    ), 
    public = list(
        #' @param base_url character. The base URL of the API version 2 (known as /api/v2). For example: https://kobo.correlaid.org.
        #' @param kobo_token character. The API token. Defaults to NULL.
        initialize = function(base_url,
                              kobo_token = Sys.getenv("KBTBR_TOKEN")) {
            
            private$base_url <- base_url

            # set the token internally
            if (Sys.getenv("KBTBR_TOKEN") == "") {
                usethis::ui_stop(
                    "No valid token detected. Set the KBTBR_TOKEN environment variable or pass the token directly to the function (not recommended)."
                )
            }
            # check that the token is a character
            checkmate::assert_character(kobo_token)
            private$kobo_token <- kobo_token
            super$initialize(url = base_url, headers = list(Authorization = paste0("Token ", kobo_token)))
        },

        # TODO: understand ... 
        get = function(path, query = list(), ...) {
            res <- super$get(path = path, query = query, ...)
            res$raise_for_status()
            res$raise_for_ct_json()
            res$parse("UTF-8") %>% 
                jsonlite::fromJSON()
        }
    ),
    inherit = crul::HttpClient
)