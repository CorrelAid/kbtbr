#' @title Kobo Class
#' @description
#' Interface class for the Kobo API that can handle [KoboClient] instances
#' (sessions) for both API versions.
#' The Class exposes both generic and specific methods for HTTP requests /
#' interactions with the various endpoints.
#' @export
Kobo <- R6::R6Class("Kobo",
  # private = list(
  # ),
  public = list(

    # Public Fields ============================================================

    #' @field session_v2 [kbtbr::KoboClient] session for v2 of the API
    session_v2 = NULL,
    #' @field session_v1 `KoboClient` session for v1 of the API
    session_v1 = NULL,

    # Public Methods ===========================================================

    #' @description
    #' Initialization method for class "Kobo".
    #' @param base_url_v2 character. The base URL of the API version 2
    #'  (known as /api/v2). For example: https://kobo.correlaid.org.
    #' @param base_url_v1 character. The base URL of the API of your KoBoCAT
    #'  API (also known as /api/v1). Defaults to NULL.
    #'  For example: https://kc.correlaid.org.
    #' @param kobo_token character. The API token. Defaults to requesting
    #'  the systen environment `KBTBR_TOKEN`.
    #' @param session_v2 [KoboClient] To pass directly
    #' a [KoboClient] instance for the API version v2.
    #' @param session_v1 [KoboClient] In addition to session_v2 one can pass
    #' also a [KoboClient] instance for the API version v1.
    initialize = function(base_url_v2 = NULL, base_url_v1 = NULL,
                          kobo_token = Sys.getenv("KBTBR_TOKEN"),
                          session_v2 = NULL, session_v1 = NULL) {

      # one has to pass at least base_url_v2 or session_v2
      if (!xor(
        test_null(base_url_v2),
        test_null(session_v2)
      )) {
        stop("Either base_url_v2 or session_v2 must be provided")
      }

      if (!test_null(base_url_v2)) {
        self$session_v2 <- KoboClient$new(base_url_v2, kobo_token)
      } else {
        self$session_v2 <- session_v2
      }

      if (!test_null(base_url_v1)) {
        self$session_v1 <- KoboClient$new(base_url_v1, kobo_token)
      } else if (!test_null(session_v1)) {
        self$session_v1 <- session_v1
      } else {
        # TODO: add to warning once we add functionality enabled by v1 only
        # ui_info("You have not passed base_url_v1. You cannot use the following functions:")
      }
    },
    #' @description
    #' Wrapper for the GET method of internal session objects.
    #' @param path character. Path component of the endpoint.
    #' @param query list. A named list which is parsed to the query
    #'  component. The order is not hierarchical.
    #' @param version character. Indicates on which API version the request should be executed (available: `v1`, `v2`). Defaults to `v2`.
    #' @param format character. the format to request from the server. either 'json' or 'csv'. defaults to 'json'
    #' @param parse whether or not to parse the HTTP response. defaults to TRUE.
    #' @return a list encoding of the json server reply if parse=TRUE.
    #'   Otherwise, it returns the server response as a crul::HttpResponse
    #'   object.
    get = function(path, query = list(), version = "v2", format = "json",
                   parse = TRUE) {
      assert_string(path)
      assert_list(query)
      assert_flag(parse)

      if (!format %in% c("json", "csv")) {
        ui_stop("Unsupported format. Only 'json' and 'csv' are supported")
      }

      query$format <- format
      if (version == "v2") {
        res <- self$session_v2$get(
          path = paste0("api/v2/", path),
          query = query
        )
      } else if (version == "v1") {
        if (test_null(self$session_v1)) {
          ui_stop(
            paste(
              "Session for API v1 is not initalized.",
              "Please re-initalize the Kobo client with the",
              "base_url_v1 argument."
            )
          )
        }
        res <- self$session_v1$get(
          path = paste0("api/v1/", path),
          query = query
        )
      } else {
        ui_stop(
          "Invalid version. Must be either v1 or v2.
                    Come back in a couple of years."
        )
      }

      res$raise_for_status()

      if (format == "json" & parse) {
        res$raise_for_ct_json()
        return(res$parse("UTF-8") %>% jsonlite::fromJSON())
      } else if (format == "csv" & parse) {
        ui_stop(
          "TODO: Not supported yet"
        )
      } else if (parse) {
        ui_stop(
          "TODO: Not supported yet"
        )
      }
      return(res)
    },

    #' @description
    #' Wrapper for the POST method of internal session objects.
    #' @param path character. Path component of the endpoint.
    #' @param body R list. A data payload to be sent to the server.
    #' @param version character. Indicates on which API version the request
    #'  should be executed (available: `v1`, `v2`). Defaults to `v2`.
    #' @return Returns an object of class `crul::HttpResponse`.
    post = function(path, body, version = "v2") {
      assert_string(path)
      assert_list(body)

      if (version == "v2") {
        if (path != "imports/") {
          self$session_v2$post(path = paste0("api/v2/", path), body = body)
        } else {
          self$session_v2$post(path = path, body = body)
        }
      } else if (version == "v1") {
        if (test_null(self$session_v1)) {
          ui_stop("Session for API v1 is not initalized.
          Please re-initalize the Kobo client with the base_url_v1 argument.")
        }
        self$session_v1$post(path = paste0("api/v1/", path), body = body)
      } else {
        ui_stop(
          "Invalid version. Must be either v1 or v2.
          Come back in a couple of years."
        )
      }
    },

    #' @description
    #' Returns a list of all assets available in the server as tibble
    #' @importFrom tibble tibble
    get_assets = function() {
      return(tibble(self$get("assets/")$results))
    },

    #' @description
    #' High-level GET request for `surveys` endpoints endpoint
    #' @param show_all_cols if true returns all the columns available
    #' for an asset
    #' @return An user-friendly summary of the available surveys as a tibble
    get_surveys = function(show_all_cols = FALSE) {
      assert_flag(show_all_cols)

      assets_res <- self$get_assets()
      fil <- assets_res$asset_type == "survey"
      columns_of_interest <- c(
        "name", "uid", "date_created", "date_modified",
        "owner__username", "parent", "has_deployment",
        "deployment__active", "deployment__submission_count"
      )
      if (show_all_cols) {
        return(assets_res[fil, ])
      } else {
        return(assets_res[fil, columns_of_interest])
      }
    },

    #' @description
    #' Get an asset given its id.
    #' @param id character. ID of the asset within the Kobo API.
    #' @return Asset. object of class [kbtbr::Asset]
    get_asset = function(id) {
      assert_string(id)

      res <- self$get(sprintf("assets/%s/", id))
      Asset$new(res, self)
    },

    #' @description
    #' Get the submissions for a survey.
    #' @param id character. ID of the survey asset within the Kobo API.
    #' @return tibble. submissions as a tibble. if no submissions were made yet, the tibble will have no columns.
    get_submissions = function(id) {
      assert_string(id)

      asset <- self$get_asset(id)
      asset$get_submissions()
    },
    #' High-level POST request to clone an asset. `assets` endpoint
    #' (due to default to `v2`, no further specification is needed).
    #' @param clone_from character. UID of the asset to be cloned.
    #' @param new_name character. Name of the new asset.
    #' @param asset_type character. Type of the new asset. Can be
    #' "block", "question", "survey", "template".
    #' @return Returns an object of class `crul::HttpResponse`.
    clone_asset = function(clone_from, new_name, asset_type) {
      assert_string(clone_from)
      assert_string(new_name)
      assert_choice(asset_type, choices = c("block", "question", "survey", "template"))

      body <- list(
        "clone_from" = clone_from,
        "name" = new_name,
        "asset_type" = asset_type
      )
      self$post("assets/", body = body)
    },

    #' @description
    #' High-level POST request to deploy an asset.
    #' `assets/{uid}/deployment/` endpoint (due to
    #' default to `v2`, no further specification is needed).
    #' @param uid character. UID of the asset to be deployed.
    #' @return Returns an object of class `crul::HttpResponse`.
    deploy_asset = function(uid) {
      assert_string(uid)

      body <- list("active" = "true")
      endpoint <- sprintf("assets/%s/deployment/", uid)
      self$post(endpoint, body = body)
    },

    #' @description
    #' High-level POST request to import an XLS form. `imports` endpoint
    #' (due to default to `v2`, no further specification is needed).
    #' @param name character. Name of the new asset.
    #' @param file_path  character. The path to the XLS form file.
    #' @return Returns an object of class `crul::HttpResponse`.
    import_xls_form = function(name, file_path) {
      assert_string(name)
      assert_file_exists(file_path)

      body <- list(
        "name" = name,
        "library" = "false",
        "file" = crul::upload(file_path)
      )
      self$post("imports/", body = body)
    },

    #' @description
    #' High-level POST request to create an empty asset. `assets/` endpoint
    #' (due to default to `v2`, no further specification is needed).
    #' @param name character. Name of the new asset.
    #' @param description character. Optional.
    #' @param sector A list with elements `label` and `value`.
    #'  Optional. Corresponding labels and values can be found
    #'  \href{https://github.com/kobotoolbox/kpi/blob/master/kobo/static_lists.py}{here}.
    #' @param country A list with elements `label` and `value`.
    #'  Optional. Corresponding labels and values can be found
    #'  \href{https://github.com/kobotoolbox/kpi/blob/master/kobo/static_lists.py}{here}.
    #' @param share_metadata boolean. Optional.
    #' @param asset_type character. Type of the new asset. Can be
    #' "block", "question", "survey", "template".
    #' @return Returns an object of class `crul::HttpResponse`.
    create_asset = function(name,
                            asset_type,
                            description = "",
                            sector = list(label = "", value = ""),
                            country = list(label = "", value = ""),
                            share_metadata = FALSE) {

      # Input validation / assertions
      assert_character(name)
      assert_character(asset_type)
      assert_logical(share_metadata)
      assert_list(sector, names = "named")
      assert_list(country, names = "named")
      assert_set_equal(names(sector), c("label", "value"))
      assert_set_equal(names(country), c("label", "value"))

      body <- list(
        "name" = name,
        "asset_type" = asset_type,
        "settings" = list_as_json_char(
          list(
            "description" = description,
            "sector" = sector,
            "country" = country,
            "share-metadata" = share_metadata
          )
        )
      )
      self$post("assets/", body = body)
    }
  ) # <end public>
)
