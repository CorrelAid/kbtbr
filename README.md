kbtbr
================

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/CorrelAid/kbtbr/workflows/R-CMD-check/badge.svg)](https://github.com/CorrelAid/kbtbr/actions)
[![Codecov test
coverage](https://codecov.io/gh/CorrelAid/kbtbr/branch/main/graph/badge.svg)](https://codecov.io/gh/CorrelAid/kbtbr?branch=main)
<!-- badges: end -->

`kbtbr` is a wrapper for the [KoBoToolbox
APIs](https://support.kobotoolbox.org/api.html). It focuses on API v2
but also makes use of v1 if required (currently no dependencies on v1).
`kbtbr` not only allows you to pull answers to your surveys directly
into your R session but also lets you create and clone assets and import
XLS forms straight from your R console. Finally, it provides flexible
low-level functions to implement functionalities currently missing from
the package yourself.

# Installation

`kbtbr` is not on CRAN yet. You can install the current version from
GitHub:

``` r
remotes::install_github("CorrelAid/kbtbr")
```

Install the development version (unstable!)

``` r
remotes::install_github("CorrelAid/kbtbr", ref = "dev")
```

# Get started

``` r
library(kbtbr)
# replace with https://kobo.humanitarianresponse.info for the humanitarian server or your own if you self-host
base_url_v2 <- "https://kf.kobotoolbox.org" 
token <- Sys.getenv("KBTBR_TOKEN")

kobo <- Kobo$new(base_url_v2, base_url_v1, token)
kobo$get_surveys()
```

See the documentation for more!

# Documentation

Documentation is available as a [`pkgdown`](https://pkgdown.r-lib.org/)
website:

-   [stable version](https://correlaid.github.io/kbtbr/)
-   [development version](https://correlaid.github.io/kbtbr/dev/)

# Contributing to kbtbr

Please refer to the
[CONTRIBUTING.md](https://github.com/correlaid/kbtbr/blob/main/.github/CONTRIBUTING.md).
