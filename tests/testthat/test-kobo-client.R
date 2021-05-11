base_url <- "https://kobo.correlaid.org"
#' Testing $get_* methods

test_that("Requests with faulty token throw error", {
    # Case: Faulty token is via envvar, get request fails
    #TODO Replace this with http / vcr testing etc
    #TODO Discuss: should this only be tested within KoboClient?
    #TODO Discuss: should we think about custom errors for http stuff? -> probably not
    withr::with_envvar(
        new = c("KBTBR_TOKEN" = "foo"),
        code = {
            kc <- KoboClient$new(base_url = base_url)
            expect_error(kc$get("assets/"), regexp = "403")
        }
    )
})