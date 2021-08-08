#' @title KoboClient
#' @description
#' A class to interact with the KoboToolbox API, extending [`crul::HttpClient`].
#' @importFrom crul HttpClient
#' @importFrom checkmate assert_character
#' @importFrom usethis ui_stop
#' @export
KoboClient <- R6::R6Class("KoboClient",
    inherit = crul::HttpClient,
    private = list(
        base_url = "",
        kobo_token = ""
    ), # <end private>

    public = list(
        #' @description
        #' Initialization method for class "KoboClient".
        #' @param base_url character. The full base URL of the API.
        #' @param kobo_token character. The API token. Defaults to requesting
        #'  the system environment variable `KBTBR_TOKEN`.
        initialize = function(base_url,
                              kobo_token = Sys.getenv("KBTBR_TOKEN")) {

            # Check and set private fields
            checkmate::assert_character(kobo_token)
            if (kobo_token == "") {
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
                    Authorization = paste0("Token ", kobo_token),
                    Accept = "application/json"
                    # "content-type" = "application/json"
                )
            )
        },
        #' @description
        #' Perform a GET request (with additional checks)
        #'
        #' @details
        #' Extension of the `crul::HttpClient$get()` method that checks
        #' the HttpResponse object on status, that it is of type
        #' `application/json`, and parses the response text subsequently from
        #' JSON to R list representation.
        #' @param path character. Path component of the endpoint.
        #' @param query list. A named list which is parsed to the query
        #'  component. The order is not hierarchical.
        #' @param ... crul-options. Additional option arguments, see
        #'  [`crul::HttpClient`] for reference
        #' @return the server response as a crul::HttpResponse object.
        get = function(path, query = list(), ...) {
            path <- check_repair_path(path)
            res <- super$get(path = path, query = query, ...)
            return(res)
        },

        #' @description
        #' Perform a POST request
        #'
        #' @details
        #' Extension of the `crul::HttpClient$post()` method.
        #' @param path character. Path component of the endpoint.
        #' @param body R list. A data payload to be sent to the server.
        #' @param ... crul-options. Additional option arguments, see
        #'  [`crul::HttpClient`] for reference
        #' @return Returns an object of class `crul::HttpResponse`.
        post = function(path, body, ...) {
            path <- check_repair_path(path)
            res <- super$post(path = path, body = body, ...)
            res$raise_for_status()
            return(res)
        }
    ) # <end public>
)
