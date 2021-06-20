BASE_URL <- "https://kobo.correlaid.org"
#' -----------------------------------------------------------------------------
#' Testing basic properties, construction

test_that("the error from KoboClient is propagated correctly if we fail to provide a token", {
  withr::with_envvar(
    new = c("KBTBR_TOKEN" = ""),
    code = {
      expect_error(
        object = Kobo$new(base_url_v2 = BASE_URL),
        regexp = "No valid token detected."
      )
    }
  )
})

test_that("Kobo is initialized correctly if we provide a kobo_token manually with empty envvar.", {
  withr::with_envvar(
    new = c("KBTBR_TOKEN" = ""),
    code = {
      kobo_obj <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = "foo")
      expect_identical(
        class(kobo_obj),
        c("Kobo", "R6")
      )
    }
  )
})


test_that("Kobo is initialized correctly if we provide a KoboClient instance", {
  withr::with_envvar(
    new = c("KBTBR_TOKEN" = ""),
    code = {
      koboclient_instance <- KoboClient$new(BASE_URL, kobo_token = "foo")
      kobo_obj <- Kobo$new(session_v2 = koboclient_instance)
      expect_identical(
        class(kobo_obj),
        c("Kobo", "R6")
      )
    }
  )
})

test_that("we get a message if we do not specify base_url_v1, but Kobo is initialized.", {
  expect_message(
    {
      kobo_obj <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = "foo")
    },
    regexp = "You have not passed base_url_v1. This means you cannot use"
  )
  expect_identical(
    class(kobo_obj),
    c("Kobo", "R6")
  )
})
#' -----------------------------------------------------------------------------
#' Testing $get_* methods
test_that("Request to v1 throws error if v1 session is not initialized", {
  kobo <- Kobo$new(base_url_v2 = BASE_URL)
  expect_error(kobo$get("submissions/", version = "v1"),
    regexp = "Session for API v1 is not initalized"
  )
})

test_that("Kobo can fetch assets", {
  # the use_cassette command looks into the fixtures directory and checks
  # whether a "cassette" with the given name already exists. if yes, it loads it. if no, the
  # code is run and the response is saved as a cassette.
  vcr::use_cassette("kobo-get-assets", {
    kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
    assets <- kobo$get_assets()
  })
  expect_setequal(names(assets), c("count", "next", "previous", "results"))
  expect_true(all(c("url", "owner", "kind", "name", "asset_type") %in% colnames(assets$results)))
  expect_equal(nrow(assets$results), 8)
  expect_equal(assets$count, 8)
})

test_that("Kobo can fetch assets using simple get", {
  vcr::use_cassette("kobo-get-assets-simple-get", {
    kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
    assets <- kobo$get("assets/") # trailing slash again!
  })
  expect_setequal(names(assets), c("count", "next", "previous", "results"))
  expect_true(all(c("url", "owner", "kind", "name", "asset_type") %in% colnames(assets$results)))
  expect_equal(nrow(assets$results), 8)
  expect_equal(assets$count, 8)
})


vcr::use_cassette("kobo-get-404", {
  test_that("non existing route throws 404 error", {
    kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
    expect_error(kobo$get("doesnotexist/"), regexp = "404")
  })
})

test_that("non-existing kobo host throws error", {
  kobo <- Kobo$new(base_url_v2 = "https://nokobohere.correlaid.org", kobo_token = Sys.getenv("KBTBR_TOKEN"))
  expect_error(kobo$get("assets/"), regexp = "^SSL.+certificate.+")
})


#' -----------------------------------------------------------------------------
#' Testing POST methods
test_that("Kobo$post can clone assets", {
    vcr::use_cassette("kobo-clone-assets-simple-post", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        clone_asset <- kobo$post("assets/", body = list("clone_from" = "a84jmwwdPEsZMhK7s2i4SL",
                                                        "name" = "vcr_test_name",
                                                        "asset_type" = "survey"))
    })
    expect_equal(clone_asset$url,"https://kobo.correlaid.org/api/v2/assets/")
    expect_equal(clone_asset$method,"post")
    expect_equal(clone_asset$status_code,201)
    expect_equal(clone_asset$success(),TRUE)
    expect_equal(clone_asset$status_http()$message,"Created")
    expect_equal(clone_asset$status_http()$explanation,"Document created, URL follows")
})

test_that("kobo$clone_asset can clone assets", {
    vcr::use_cassette("kobo-post-clone-asset", {
        kobo <- suppressWarnings(Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN")))
        clone_asset <- kobo$clone_asset(clone_from = "a84jmwwdPEsZMhK7s2i4SL",
                                        name = "vcr_test_name",
                                        asset_type = "survey")
        })
    expect_equal(clone_asset$url,"https://kobo.correlaid.org/api/v2/assets/")
    expect_equal(clone_asset$method,"post")
    expect_equal(clone_asset$status_code,201)
    expect_equal(clone_asset$success(),TRUE)
    expect_equal(clone_asset$status_http()$message,"Created")
    expect_equal(clone_asset$status_http()$explanation,"Document created, URL follows")
})

test_that("kobo$deploy_asset can deploy assets", {
    vcr::use_cassette("kobo-post-deploy-asset", {
        kobo <- suppressWarnings(Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN")))
        deploy_asset <- kobo$deploy_asset(uid = "aQVGH8G68EP737tDBABRwC")
    })
    expect_equal(deploy_asset$url,
                 "https://kobo.correlaid.org/api/v2/assets/aQVGH8G68EP737tDBABRwC/deployment/")
    expect_equal(deploy_asset$method,"post")
    expect_equal(deploy_asset$status_code,200) # i don't understand why not 201. but with 200 it successfully deployed
    expect_equal(deploy_asset$success(),TRUE)
    expect_equal(deploy_asset$status_http()$message,"OK")
    expect_equal(deploy_asset$status_http()$explanation,"Request fulfilled, document follows")
})

# test_that("kobo$create_asset can create assets", {
#     vcr::use_cassette("kobo-post-create-asset", {
#         kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
#         create_asset <- kobo$create_asset(name="vcr_test_name",
#                                           description="vcr_test_description",
#                                           sector="vcr_test_sector",
#                                           country="vcr_test_country",
#                                           share_metadata="false",
#                                           asset_type="survey")
#     })
#     expect_equal(create_asset$url,"")
#     expect_equal(create_asset$method,"post")
#     expect_equal(create_asset$status_code,201)
#     expect_equal(create_asset$success(),TRUE)
#     expect_equal(create_asset$status_http()$message,"")
#     expect_equal(create_asset$status_http()$explanation,"")
# })

test_that("kobo$import_xls_form can import forms", {
    vcr::use_cassette("kobo-post-import-xls-form", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        import_xls_form <- kobo$import_xls_form(name="vcr_test_name",
                                                file="xls_form_via_post.xlsx")
    })
    expect_equal(import_xls_form$url,"https://kobo.correlaid.org/imports/")
    expect_equal(import_xls_form$method,"post")
    expect_equal(import_xls_form$status_code,201)
    expect_equal(import_xls_form$success(),TRUE)
    expect_equal(import_xls_form$status_http()$message,"Created")
    expect_equal(import_xls_form$status_http()$explanation,"Document created, URL follows")
})
