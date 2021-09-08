BASE_URL <- "https://kobo.correlaid.org"

test_that("Asset only takes Kobo not Kobo Client", {
    test_list <- list(
        uid = "uid",
        name = "a very cool testing survey",
        url = "url",
        data = "url",
        owner__username = "user",
        asset_type = "survey"
    )
    kc <- KoboClient$new(BASE_URL)
    expect_error(Asset$new(test_list, kc), regexp = "Assertion on 'kobo' failed: Must inherit from class 'Kobo', but has classes 'KoboClient','HttpClient','R6'.")
})

test_that("Asset needs all necessary elements to be non-null", {
    test_list <- list(
        uid = "uid",
        name = "a very cool testing survey",
        url = "url",
        data = "url"
    )
    kobo <- Kobo$new(BASE_URL)
    expect_error(Asset$new(test_list, kobo), regexp = "Argument asset_list is missing the following required elements: owner__username, asset_type")
})

test_that("asset objects can be created for all asset types", {
    vcr::use_cassette("kobo-create-asset-objects", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        assets <- kobo$get_assets()
    })

    # get one of each type to make sure it works for all asset types
    survey <- assets$results %>%
        dplyr::filter(asset_type == "survey") %>%
        dplyr::slice(1)
    question <- assets$results %>%
        dplyr::filter(asset_type == "question") %>%
        dplyr::slice(1)
    block <- assets$results %>%
        dplyr::filter(asset_type == "block") %>%
        dplyr::slice(1)
    template <- assets$results %>%
        dplyr::filter(asset_type == "template") %>%
        dplyr::slice(1)

    test_cases <- dplyr::bind_rows(survey, question, block, template)

    for (i in 1:nrow(test_cases)) {
        asset_list <- test_cases[i, , drop = TRUE]
        asset_obj <- Asset$new(asset_list, kobo)
        expect_equal(asset_obj$uid, asset_list$uid)
        expect_equal(asset_obj$name, asset_list$name)
        expect_equal(asset_obj$asset_url, asset_list$url)
        expect_equal(asset_obj$data_url, asset_list$data)
        expect_equal(asset_obj$type, asset_list$asset_type)
        expect_equal(asset_obj$owner_username, asset_list$owner__username)
    }
})


test_that("get asset returns asset instance", {
    vcr::use_cassette("kobo-get-asset-object", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        asset_obj <- kobo$get_asset("aRo4wg5utWT7dwdnQQEAE7")
    })

    expect_equal(asset_obj$uid, "aRo4wg5utWT7dwdnQQEAE7")
    expect_equal(asset_obj$name, "kbtbr Testing Survey")
    expect_equal(asset_obj$asset_url, "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/?format=json")
    expect_equal(asset_obj$data_url, "https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/data/?format=json")
    expect_equal(asset_obj$type, "survey")
    expect_equal(asset_obj$owner_username, "api_user")

    # to list function
    expect_equal(length(asset_obj$to_list()), 6)
    expect_setequal(names(asset_obj$to_list()), c("uid", "name", "asset_url", "data_url", "type", "owner_username"))
})

test_that("can get survey submissions from survey", {
    vcr::use_cassette("kobo-asset-submissions-asset", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        asset_obj <- kobo$get_asset("aRo4wg5utWT7dwdnQQEAE7")
    })

    vcr::use_cassette("kobo-asset-submissions-data", {
        submissions_df <- asset_obj$get_submissions()
    })
    expect_true(tibble::is_tibble(submissions_df))
    expect_equal(nrow(submissions_df), 6)
    print(str(submissions_df))
})

test_that("getting submissions works for survey without submissions so far", {
    vcr::use_cassette("kobo-asset-submissions-asset-nosubs", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        asset_obj <- kobo$get_asset("ajzghKK6NELaixPQqsm49e")
    })

    vcr::use_cassette("kobo-asset-submissions-data-nosubs", {
        submissions_df <- asset_obj$get_submissions()
    })
    expect_true(tibble::is_tibble(submissions_df))
    expect_equal(nrow(submissions_df), 0)
    expect_equal(ncol(submissions_df), 0)
})

test_that("get_submissions throws error for asset which is not a survey", {
    vcr::use_cassette("kobo-asset-submissions-asset-notsurvey", {
        kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        asset_obj <- kobo$get_asset("apxYrm7i4mGc3Wxqu2eZ2r")
    })

    expect_error(asset_obj$get_submissions(), regexp = "Only valid for assets of type 'survey'. Current asset is of type 'block'.")
})
