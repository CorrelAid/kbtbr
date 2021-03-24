#' KoboClient
#' @description a class to interact with the KoboToolbox API
KoboClient <- R6::R6Class("KoboClient",
    private = list(
        kobo_token = "",
        base_url = NULL # we could make this an active, read only field!
    ),
    public = list(
        v1_enabled = FALSE,
        #' @param base_url character. The base URL of the API version 2 (known as /api/v2).
        #' @param kobo_token character. The API token. Defaults to NULL.
        #' @param base_url_v1 character. The base URL of the API of your KoBoCAT API (also known as /api/v1). Defaults to NULL.
        initialize = function(base_url, kobo_token = NULL, base_url_v1 = NULL) {
            private$base_url <- base_url

            # set the token internally
            if (checkmate::test_null(kobo_token) & Sys.getenv("KBTBR_TOKEN") == "") {
                usethis::ui_stop("No valid token detected. Set the KBTBR_TOKEN environment variable or pass the token directly to the function (not recommended).")
            }
            # check that the token is a character
            checkmate::assert_character(kobo_token)
            private$kobo_token <- kobo_token

            # if specified, set the base url for api/v1 internally
            if (!checkmate::test_null(base_url_v1)) {
                checkmate::assert_character(base_url_v1)
                self$v1_enabled <- TRUE
            }
        }
    ),
    inherit = crul::HttpClient
)