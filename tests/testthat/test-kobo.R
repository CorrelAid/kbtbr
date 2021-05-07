base_url <- "https://kobo.correlaid.org"



#' -----------------------------------------------------------------------------
#' Testing basic properties, construction

test_that("Construction & token passing works", {

    # Case: No token is set in envvar. Testing argument:
    withr::with_envvar(
        new = c("KBTBR_TOKEN" = ""),
        code = {

            # a) no `kobo_token` is provided, is the error from 
            #    KoboClient propagated correctly?
            expect_error(
                object = Kobo$new(base_url_v2 = base_url),
                regexp = "No valid token detected."
                )

            # b) `kobo_token` argument is provided, supersedes env var. 
            #    is this propagated correctly to KoboClient?
            kobo_obj <- Kobo$new(base_url_v2 = base_url, kobo_token = "foo")
            expect_identical(
                class(kobo_obj),
                c("Kobo", "R6")
            )
        }
    )

})

#' -----------------------------------------------------------------------------
#' Testing $get_* methods

test_that("Requests with faulty token throw error", {
    # Case: Faulty token is via envvar, get request fails
    #TODO Replace this with http / vcr testing etc
    #TODO Discuss: should this only be tested within KoboClient?
    #TODO Discuss: should we think about custom errors for http stuff? -> probably not
    withr::with_envvar(
        new = c("KBTBR_TOKEN" = "foo"),
        code = {
            kobo <- Kobo$new(base_url_v2 = base_url)
            expect_error(kobo$get_assets(), regexp = "403")
        }
    )


})


#' -----------------------------------------------------------------------------
#' Testing `$post_*`` methods