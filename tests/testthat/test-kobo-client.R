BASE_URL <- "https://kobo.correlaid.org"

#' Testing $get_* methods

vcr::use_cassette("kobo-client-403", {
    test_that("Requests with faulty token throw error", {
        # Case: Faulty token is via envvar, get request fails
        withr::with_envvar(
            new = c("KBTBR_TOKEN" = "foo"),
            code = {
                kc <- KoboClient$new(base_url = BASE_URL)
                expect_error(kc$get("api/v2/assets/"), regexp = "403")
            }
        )
    })
})

test_that("Kobo Client can fetch assets", {
    vcr::use_cassette("kobo-client-get-assets-simple-get", {
        koboclient <- KoboClient$new(base_url = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        assets <- koboclient$get("api/v2/assets/", query = list(format = "json")) # trailing slash again!
    })
    expect_setequal(names(assets), c("count", "next", "previous", "results"))
    expect_true(all(c("url", "owner", "kind", "name", "asset_type") %in% colnames(assets$results)))
    expect_equal(nrow(assets$results), 8)
    expect_equal(assets$count, 8)
})


vcr::use_cassette("kobo-client-get-404", {
    test_that("non existing route throws 404 error", {
        koboclient <- KoboClient$new(base_url = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        expect_error(koboclient$get("api/v2/doesnotexist/"), regexp = "404")
    })
})

#' Testing $post method
test_that("Kobo Client can clone assets", {
    vcr::use_cassette("kobo-client-clone-assets-simple-post", {
        koboclient <- KoboClient$new(base_url = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
        clone_asset <- koboclient$post("api/v2/assets/",
                                       body = list("clone_from" = "a84jmwwdPEsZMhK7s2i4SL",
                                                   "name" = "vcr_test_name", "asset_type" = "survey"))
    })
    expect_equal(clone_asset$url,"https://kobo.correlaid.org/api/v2/assets/")
    expect_equal(clone_asset$method,"post")
    expect_equal(clone_asset$status_code,201)
    expect_equal(clone_asset$success(),TRUE)
    expect_equal(clone_asset$status_http()$message,"Created")
    expect_equal(clone_asset$status_http()$explanation,"Document created, URL follows")
})
