#' Kobo
#' @description a class to interact with the KoboToolbox API
Kobo <- R6::R6Class(
    "Kobo",
    private = list(
        session_v2 = NULL,
        session_v1 = NULL
    ), 
    public = list(
        #' @param base_url_v2 character. The base URL of the API version 2 (known as /api/v2). For example: https://kobo.correlaid.org.
        #' @param base_url_v1 character. The base URL of the API of your KoBoCAT API (also known as /api/v1). Defaults to NULL. For example: https://kc.correlaid.org.
        #' @param kobo_token character. The API token. Defaults to NULL.
        initialize = function(base_url_v2, base_url_v1 = NULL, kobo_token = NULL) {

            if (checkmate::test_null(kobo_token) & Sys.getenv("KBTBR_TOKEN") == "") {
                usethis::ui_stop(
                    "No valid token detected. Set the KBTBR_TOKEN environment variable or pass the token directly to the function (not recommended)."
                )
            }

            if (checkmate::test_null(base_url_v2) & checkmate::test_null(base_url_v1)) {
                usethis::ui_stop("Please provide either base_url_v2 or base_url_v1")
            }


            if (!checkmate::test_null(base_url_v2)) {
               private$session_v2 = KoboClient$new(base_url_v2, kobo_token)
            }

            if (!checkmate::test_null(base_url_v1)) {
               private$session_v1 = KoboClient$new(base_url_v1, kobo_token)
            }
        },
        get = function(path, query = list(format = "json"), version = "v2") {
            if (version == "v2") {
                private$session_v2$get(path = paste0("api/v2/", path), query = query)
            } else if (version == "v1") {
                private$session_v1$get(path = paste0("api/v1/", path), query = query)
            } else {
                usethis::ui_stop("Invalid version. Must be either v1 or v2. Come back in a couple of years.")
            }
        },
        get_assets = function() {
            self$get("assets")
        }
    ),
    inherit = crul::HttpClient
)