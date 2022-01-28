

# Testing URL functions --------------------------------------------------------

test_that("Enforcing trailing slash to a string works", {
    path_correct <- "this/is/my/url/"
    path_wrong <- "this/is/my/url"
    expect_equal(
        append_slash(path_correct),
        path_correct
    )

    expect_equal(
        append_slash(path_wrong),
        path_correct
    )
})
