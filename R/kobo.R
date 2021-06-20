#' @title Kobo Class
#' @description
#' Interface object for the Kobo API that can handle KoboClient instances
#' (sessions) for both API versions.
#' The Class exposes both generic and specific methods for HTTP requests /
#' interactions with the various endpoints.
#' @export
Kobo <- R6::R6Class("Kobo",
    # private = list(
    # ),
    public = list(
        session_v2 = NULL,
        session_v1 = NULL,

        #' @description
        #' Initialization method for class "Kobo".
        #' @param base_url_v2 character. The base URL of the API version 2
        #'  (known as /api/v2). For example: https://kobo.correlaid.org.
        #' @param base_url_v1 character. The base URL of the API of your KoBoCAT
        #'  API (also known as /api/v1). Defaults to NULL.
        #'  For example: https://kc.correlaid.org.
        #' @param kobo_token character. The API token. Defaults to requesting
        #'  the systen environment `KBTBR_TOKEN`.
        #' @param session_v2 KoboClient. Alternatively, pass directly
        #' a KoboClient instance for the API version v2.
        #' @param session_v1 KoboKlient. In addition to session_v2 one can pass
        #' also a KoboClient instance for the API version v1.
        initialize = function(
            base_url_v2 = NULL, base_url_v1 = NULL,
            kobo_token = Sys.getenv("KBTBR_TOKEN"),
            session_v2 = NULL, session_v1 = NULL) {

            # one has to pass at least base_url_v2 or session_v2
            if (!xor(checkmate::test_null(base_url_v2),
                     checkmate::test_null(session_v2)) ){
                stop("Either base_url_v2 or session_v2 must be provided")
            }

            if (!checkmate::test_null(base_url_v2)){
                self$session_v2 <- KoboClient$new(base_url_v2, kobo_token)
            }else {
                self$session_v2 <- session_v2
            }

            if (!checkmate::test_null(base_url_v1)) {
                self$session_v1 <- KoboClient$new(base_url_v1, kobo_token)
            } else if(!checkmate::test_null(session_v1)) {
                self$session_v1 <- session_v1
            } else {
                # TODO: add to warning once we know what functnality is covered by v1.
                usethis::ui_info("You have not passed base_url_v1. This means you cannot use the following functions:")
            }
        },
        #' @description
        #' Wrapper for the GET method of internal session objects.
        #' @param path character. Path component of the endpoint.
        #' @param query list. A named list which is parsed to the query
        #'  component. The order is not hierarchical.
        #' @param version character. Indicates on which API version the request
        #' @param format character. the format to request from the server. either 'json' or 'csv'. defaults to 'json'
        #' @param parse whether or not to parse the HTTP response. defaults to TRUE. 
        #'  should be executed (available: `v1`, `v2`). Defaults to `v2`.
        get = function(path, query = list(), version = "v2", format = "json",
                       parse = TRUE) {
            if (!format %in% c('json', 'csv')) {
                usethis::ui_stop("Unsupported format. Only 'json' and 'csv' are supported")
            }

            query$format = format

            if (version == "v2") {
                res <- self$session_v2$get(path = paste0("api/v2/", path),
                                       query = query)

            } else if (version == "v1") {
                if (checkmate::test_null(self$session_v1)) {
                    usethis::ui_stop(
                        paste("Session for API v1 is not initalized.",
                        "Please re-initalize the Kobo client with the",
                        "base_url_v1 argument."))
                }
                res <- self$session_v1$get(path = paste0("api/v1/", path),
                                       query = query)

            } else {
                usethis::ui_stop(
                    "Invalid version. Must be either v1 or v2.
                    Come back in a couple of years."
                )
            }

            res$raise_for_status()

            if (format=="json" & parse) {
                res$raise_for_ct_json()
                return(res$parse("UTF-8") %>%jsonlite::fromJSON())
            } else if(format=="csv" & parse){
                usethis::ui_stop(
                    "TODO: Not supported yet"
                )
            } else if(parse) {
                usethis::ui_stop(
                    "TODO: Not supported yet"
                )
            }
            return(res)


        },

        #' @description
        #' Wrapper for the POST method of internal session objects.
        #' @param path character. Path component of the endpoint.
        #' @param body R list or json-like string. A data payload to be sent
        #' to the server.
        #' @param version character. Indicates on which API version the request
        #'  should be executed (available: `v1`, `v2`). Defaults to `v2`.
        post = function(path, body, version = "v2") {
            if (version == "v2") {
                self$session_v2$post(path = paste0("api/v2/", path), body = body)
            } else if (version == "v1") {
                if (checkmate::test_null(self$session_v1)) {
                    usethis::ui_stop("Session for API v1 is not initalized.
                    Please re-initalize the Kobo client with the base_url_v1 argument.")
                }
                self$session_v1$post(path = paste0("api/v1/", path), body = body)
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
        },

        #' @description
        #' High-level POST request to clone an asset. `assets` endpoint
        #' (due to default to `v2`, no further specification is needed).
        clone_asset = function(clone_from, name, asset_type) {
            body = list("clone_from" = clone_from,
                        "name" = name,
                        "asset_type" = asset_type)
            print(body)
            self$post("assets/", body=body)
        }

    )
)
