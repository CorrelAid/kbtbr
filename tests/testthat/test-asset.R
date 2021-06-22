BASE_URL <- "https://kobo.correlaid.org"

test_that("Asset only takes Kobo not Kobo Client", {
    test_list <- list(
        uid = 'uid', 
        name = 'a very cool testing survey',
        url = 'url', 
        data = 'url', 
        owner__username = 'user',
        asset_type = 'survey'
    )
    kc <- KoboClient$new(BASE_URL)
    expect_error(Asset$new(test_list, kc), regexp = "Assertion on 'kobo' failed: Must inherit from class 'Kobo', but has classes 'KoboClient','HttpClient','R6'.")

})

test_that("Asset needs all necessary elements to be non-null", {
    test_list <- list(
        uid = 'uid', 
        name = 'a very cool testing survey',
        url = 'url', 
        data = 'url'
    )
    kobo <- Kobo$new(BASE_URL)
    expect_error(Asset$new(test_list, kobo), regexp = "Argument asset_list is missing the following required elements: owner__username, asset_type")
})

test_that("asset objects can be created for all assets", {
        vcr::use_cassette("kobo-create-asset-objects", {
            kobo <- Kobo$new(base_url_v2 = BASE_URL, kobo_token = Sys.getenv("KBTBR_TOKEN"))
            assets <- kobo$get_assets()
        })
                
        for(i in 1:nrow(assets$results)) {
            asset_list <- assets$results[i, , drop = TRUE]
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
        asset_obj <- kobo$get_asset('aRo4wg5utWT7dwdnQQEAE7')
    })
                
    expect_equal(asset_obj$uid, 'aRo4wg5utWT7dwdnQQEAE7')
    expect_equal(asset_obj$name, 'kbtbr Testing Survey')
    expect_equal(asset_obj$asset_url, 'https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/?format=json')
    expect_equal(asset_obj$data_url, 'https://kobo.correlaid.org/api/v2/assets/aRo4wg5utWT7dwdnQQEAE7/data/?format=json')
    expect_equal(asset_obj$type, 'survey')
    expect_equal(asset_obj$owner_username, 'api_user')

    #to list function
    expect_equal(length(asset_obj$to_list()), 6)
    expect_setequal(names(asset_obj$to_list()), c('uid', 'name', 'asset_url', 'data_url', 'type', 'owner_username'))

})
