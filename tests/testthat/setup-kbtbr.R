library("vcr") # *Required* as vcr is set up on loading

vcr_dir <- vcr::vcr_test_path("fixtures")

if (!nzchar(Sys.getenv("KBTBR_TOKEN"))) {
  if (dir.exists(vcr_dir)) {
    # Fake API token to fool our package
    Sys.setenv("KBTBR_TOKEN" = "fakebearertoken")
  } else {
    # If there's no mock files nor API token, impossible to run tests
    stop("No API key nor cassettes, tests cannot be run.",
      call. = FALSE
    )
  }
}

invisible(vcr::vcr_configure(
  dir = vcr_dir,
  filter_request_headers = list(Authorization = "fakebearertoken")
))
vcr::check_cassette_names()
