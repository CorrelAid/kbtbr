#' KoboClient
#' @description a class to interact with the KoboToolbox API
KoboClient <- R6::R6Class(
    "KoboClient",
    public = list(
        #' @param base_url character. The full base URL of the API version 2 (known as /api/v2). For example: https://kobo.correlaid.org/api/v2.
        #' @param kobo_token character. The API token. Defaults to Sys.getenv("KBTBR_TOKEN").
        #' @param base_url_v1 character. The base URL of the API of your KoBoCAT API (also known as /api/v1). Defaults to NULL. For example: https://kc.correlaid.org/api/v1/.
        initialize = function(base_url,
                              kobo_token = Sys.getenv("KBTBR_TOKEN"),
                              base_url_v1 = NULL) {

            # set the token in the authorization header
            if (kobo_token == "") {
                usethis::ui_stop(
                    "No valid token detected. Set the KBTBR_TOKEN environment variable or pass the token directly to the function (not recommended)."
                )
            }
            # check that the token is a character
            checkmate::assert_character(kobo_token)
            super$initialize(url = base_url, headers = list(Authorization = paste0("Bearer ", kobo_token)))
        }
    ),
    inherit = crul::HttpClient
)
