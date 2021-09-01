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
    expect_equal(nrow(assets$results), 8)
})

test_that("Kobo can fetch assets using simple get", {
    vcr::use_cassette("kobo-get-assets-simple-get", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        assets <- kobo$get("assets/", parse = TRUE) # trailing slash again!
    })
    expect_setequal(names(assets), c("count", "next", "previous", "results"))
    expect_true(all(c("url", "owner", "kind", "name", "asset_type") %in% colnames(assets$results)))
    expect_equal(nrow(assets$results), 8)
    expect_equal(assets$count, 8)
})

test_that("Kobo can a single asset", {
    vcr::use_cassette("kobo-get-single-asset", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        asset <- kobo$get_asset("aRo4wg5utWT7dwdnQQEAE7")
    })
    expect_identical(
        class(asset),
        c("Asset", "R6")
    )
})

# ERRORS -----------
vcr::use_cassette("kobo-get-404", {
    test_that("non existing route throws 404 error", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        expect_error(kobo$get("doesnotexist/"), regexp = "404")
    })
})

#' -----------------------------------------------------------------------------
#' Testing POST methods
test_that("Kobo$post can clone assets", {
    vcr::use_cassette("kobo-clone-assets-simple-post", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))

        clone_asset <- kobo$post("assets/",
            body = list(
                "clone_from" = "a84jmwwdPEsZMhK7s2i4SL",
                "name" = "vcr_test_name",
                "asset_type" = "survey"
            )
        )
    })
    expect_equal(clone_asset$url, "https://kobo.correlaid.org/api/v2/assets/")
    expect_equal(clone_asset$method, "post")
    expect_equal(clone_asset$status_code, 201)
    expect_true(clone_asset$success())
    expect_equal(clone_asset$status_http()$message, "Created")
    expect_equal(clone_asset$status_http()$explanation, "Document created, URL follows")
})

vcr::use_cassette("Kobo$post-404", {
    test_that("Kobo$post with non existing route throws 404 error", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))

        expect_error(kobo$post("doesnotexist/",
            body = list(
                "clone_from" = "a5jjyWLUEmi49EHML6t9Nr",
                "name" = "vcr_test_name",
                "asset_type" = "survey"
            )
        ),
        regexp = "404"
        )
    })
})

#' Testing kobo$clone_asset
test_that("kobo$clone_asset can clone assets", {
    vcr::use_cassette("kobo-post-clone-asset", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))

        clone_asset <- kobo$clone_asset(
            clone_from = "a84jmwwdPEsZMhK7s2i4SL",
            new_name = "vcr_test_name",
            asset_type = "survey"
        )
    })
    expect_equal(clone_asset$url, "https://kobo.correlaid.org/api/v2/assets/")
    expect_equal(clone_asset$method, "post")
    expect_equal(clone_asset$status_code, 201)
    expect_true(clone_asset$success())
    expect_equal(clone_asset$status_http()$message, "Created")
    expect_equal(clone_asset$status_http()$explanation, "Document created, URL follows")
})

test_that("kobo$clone_asset returns error for the attempt to clone non-existing asset", {
    vcr::use_cassette("kobo-post-clone-asset-err1", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$clone_asset(
            clone_from = "smth_wrong",
            new_name = "vcr_test_name",
            asset_type = "survey"
        ), regexp = "404")
    })
})

test_that("kobo$clone_asset returns error when cloning question to block", {
    vcr::use_cassette("kobo-post-clone-asset-err2", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$clone_asset(
            clone_from = "a7AV5JhRHKf8EWGBJLswwC",
            new_name = "vcr_test_name",
            asset_type = "block"
        ), regexp = "500")
    })
})

test_that("kobo$clone_asset returns error when cloning template to block", {
    vcr::use_cassette("kobo-post-clone-asset-err3", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$clone_asset(
            clone_from = "anxTvsL3xZd7CSvpt63qAd",
            new_name = "vcr_test_name",
            asset_type = "block"
        ), regexp = "500")
    })
})

test_that("kobo$clone_asset returns error when cloning template to question", {
    vcr::use_cassette("kobo-post-clone-asset-err4", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$clone_asset(
            clone_from = "anxTvsL3xZd7CSvpt63qAd",
            new_name = "vcr_test_name",
            asset_type = "question"
        ), regexp = "500")
    })
})

test_that("kobo$clone_asset returns error when asset id isn't provided", {
    kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
    expect_error(kobo$clone_asset(
        new_name = "vcr_test_name",
        asset_type = "survey"
    ), regexp = "is missing")
})

test_that("kobo$clone_asset returns error when asset name isn't provided", {
    kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
    expect_error(kobo$clone_asset(
        clone_from = "a84jmwwdPEsZMhK7s2i4SL",
        asset_type = "survey"
    ), regexp = "is missing")
})

test_that("kobo$clone_asset returns error when asset type isn't provided", {
    kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
    expect_error(kobo$clone_asset(
        clone_from = "a84jmwwdPEsZMhK7s2i4SL",
        new_name = "vcr_test_name"
    ), regexp = "is missing")
})


#' Testing kobo$deploy_asset
test_that("kobo$deploy_asset can deploy assets", {
    vcr::use_cassette("kobo-post-deploy-asset", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))

        deploy_asset <- kobo$deploy_asset(uid = "aQVGH8G68EP737tDBABRwC")
    })
    expect_equal(
        deploy_asset$url,
        "https://kobo.correlaid.org/api/v2/assets/aQVGH8G68EP737tDBABRwC/deployment/"
    )
    expect_equal(deploy_asset$method, "post")
    expect_equal(deploy_asset$status_code, 200) # i don't understand why not 201.
    # but with 200 it successfully deployed
    expect_true(deploy_asset$success())
    expect_equal(deploy_asset$status_http()$message, "OK")
    expect_equal(deploy_asset$status_http()$explanation, "Request fulfilled, document follows")
})

test_that("kobo$deploy_asset returns error when asset doesn't exist", {
    vcr::use_cassette("kobo-post-deploy-asset-err1", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$deploy_asset(uid = "smth_wrong"), regexp = "404")
    })
})

test_that("kobo$deploy_asset returns error when asset has deployment", {
    vcr::use_cassette("kobo-post-deploy-asset-err2", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$deploy_asset(uid = "ajzghKK6NELaixPQqsm49e"), regexp = "405")
    })
})

test_that("kobo$deploy_asset returns error when asset is template", {
    vcr::use_cassette("kobo-post-deploy-asset-err3", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$deploy_asset(uid = "anxTvsL3xZd7CSvpt63qAd"), regexp = "500")
    })
})

test_that("kobo$deploy_asset returns error when asset is question", {
    vcr::use_cassette("kobo-post-deploy-asset-err4", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$deploy_asset(uid = "a7AV5JhRHKf8EWGBJLswwC"), regexp = "500")
    })
})

test_that("kobo$deploy_asset returns error when asset is block", {
    vcr::use_cassette("kobo-post-deploy-asset-err5", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))
        expect_error(kobo$deploy_asset(uid = "aYKJ5czzHiustZFpBBiWHk"), regexp = "500")
    })
})

test_that("kobo$deploy_asset returns error when asset id isn't provided", {
    kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
    expect_error(kobo$deploy_asset(), regexp = "is missing")
})


#' Testing kobo$import_xls_form
test_that("kobo$import_xls_form can import forms", {
    vcr::use_cassette("kobo-post-import-xls-form", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))

        import_xls_form <- kobo$import_xls_form(
            name = "vcr_test_name",
            file_path = "xls_form_via_post.xlsx"
        )
    })
    expect_equal(import_xls_form$url, "https://kobo.correlaid.org/imports/")
    expect_equal(import_xls_form$method, "post")
    expect_equal(import_xls_form$status_code, 201)
    expect_true(import_xls_form$success())
    expect_equal(import_xls_form$status_http()$message, "Created")
    expect_equal(
        import_xls_form$status_http()$explanation,
        "Document created, URL follows"
    )
})

test_that("kobo$create_asset can create assets with settings as parameters", {
    vcr::use_cassette("kobo-post-create-asset", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))

        create_asset <- kobo$create_asset(
            name = "vcr_test_name",
            asset_type = "survey",
            description = "description",
            sector = list(label = "Environment", value = "ENV"),
            country = list(label = "Angola", value = "AGO"),
            share_metadata = FALSE
        )
    })
    expect_equal(create_asset$url, "https://kobo.correlaid.org/api/v2/assets/")
    expect_equal(create_asset$method, "post")
    expect_equal(create_asset$status_code, 201)
    expect_true(create_asset$success())
    expect_equal(create_asset$status_http()$message, "Created")
    expect_equal(create_asset$status_http()$explanation, "Document created, URL follows")
})

test_that("kobo$create_asset can create assets with dafault settings", {
    vcr::use_cassette("kobo-post-create-asset1", {
        kobo <- suppressMessages(Kobo$new(
            base_url_v2 = BASE_URL,
            kobo_token = Sys.getenv("KBTBR_TOKEN")
        ))

        create_asset <- kobo$create_asset(
            name = "vcr_test_name",
            asset_type = "survey"
        )
    })
    expect_equal(create_asset$url, "https://kobo.correlaid.org/api/v2/assets/")
    expect_equal(create_asset$method, "post")
    expect_equal(create_asset$status_code, 201)
    expect_true(create_asset$success())
    expect_equal(create_asset$status_http()$message, "Created")
    expect_equal(create_asset$status_http()$explanation, "Document created, URL follows")
})

test_that("kobo$create_asset returns error when name isn't provided", {
	    kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
	    expect_error(kobo$create_asset(asset_type = "survey"), regexp = "is missing")
})

test_that("kobo$create_asset returns error when asset_type isn't provided", {
	   kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
	   expect_error(kobo$create_asset(name = "vcr_test_name"), regexp = "is missing")
})

test_that("kobo$import_xls_form fails because of an incorrect path", {
    kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
    expect_error(kobo$import_xls_form(
        name = "vcr_test_name",
        file_path = "smth_wrong.xlsx"
    ))
})

test_that("kobo$import_xls_form fails because of the missing path", {
	   kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
    expect_error(kobo$import_xls_form(file_path = "xls_form_via_post.xlsx"),
        regexp = "is missing"
    )
})

test_that("kobo$import_xls_form fails because of the missing name", {
   kobo <- suppressMessages(Kobo$new(
        base_url_v2 = BASE_URL,
        kobo_token = Sys.getenv("KBTBR_TOKEN")
    ))
    expect_error(kobo$import_xls_form(name = "vcr_test_name"),
        regexp = "is missing"
    )
    })
