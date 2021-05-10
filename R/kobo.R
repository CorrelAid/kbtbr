#' @title Kobo Class
#' @description
#' Interface object for the Kobo API that can handle KoboClient instances
#' (sessions) for both API versions.
#' The Class exposes both generic and specific methods for HTTP requests /
#' interactions with the various endpoints.
#' @export
Kobo <- R6::R6Class("Kobo",
    private = list(
        session_v2 = NULL,
        session_v1 = NULL
    ), 
    public = list(
        #' @description
        #' Initialization method for class "Kobo".
        #' @param base_url_v2 character. The base URL of the API version 2
        #'  (known as /api/v2). For example: https://kobo.correlaid.org.
        #' @param base_url_v1 character. The base URL of the API of your KoBoCAT
        #'  API (also known as /api/v1). Defaults to NULL.
        #'  For example: https://kc.correlaid.org.
        #' @param kobo_token character. The API token. Defaults to requesting
        #'  the systen environment `KBTBR_TOKEN`.
        initialize = function(base_url_v2, base_url_v1 = NULL, kobo_token = Sys.getenv("KBTBR_TOKEN")) {

            if (Sys.getenv("KBTBR_TOKEN") == "") {
                usethis::ui_stop(
                    "No valid token detected. Set the KBTBR_TOKEN environment
                    variable or pass the token directly to the function
                    (not recommended)."
                )
            }

            if (!checkmate::test_null(base_url_v2)) {
               private$session_v2 <- KoboClient$new(base_url_v2, kobo_token)
            }

            if (!checkmate::test_null(base_url_v1)) {
               private$session_v1 <- KoboClient$new(base_url_v1, kobo_token)
            }
        },
        #' @description
        #' Wrapper for the GET method of internal session objects.
        #' @param path character. Path component of the endpoint.
        #' @param query list. A named list which is parsed to the query
        #'  component. The order is not hierarchical.
        #' @param version character. Indicates on which API version the request
        #'  should be executed (available: `v1`, `v2`). Defaults to `v2`.
        get = function(path, query = list(format = "json"), version = "v2") {
            if (version == "v2") {
                private$session_v2$get(path = paste0("api/v2/", path), query = query)
            } else if (version == "v1") {
                private$session_v1$get(path = paste0("api/v1/", path), query = query)
            } else {
                usethis::ui_stop(
                    "Invalid version. Must be either v1 or v2.
                    Come back in a couple of years."
                    )
            }
        },
        #' @description
        #' Example method to send a GET request to the `assets` endpoint
        #' (due to default to `v2`, no further specification is needed).
        get_assets = function() {
            self$get("assets/")
        }
    )
)
