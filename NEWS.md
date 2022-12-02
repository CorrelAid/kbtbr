# kbtbr 0.1.0
The first release of kbtbr adds an initial set of features to the package.

* high level `Kobo` class to interact with the kbtbr API using high-level methods:
  * get data: `get_assets`, `get_asset`, `get_surveys`, `get_submissions`
  * modify assets: `deploy_asset`, `create_asset`, `clone_asset`, `import_xls_form`
  * general `get` and `post` methods that can be used flexibly by the user
* lower-level `KoboClient` class which inherits from `crul::HttpClient`. Is used internally in `Kobo` but can also be used separately for more advanced use cases. 
  * `get` and `post` methods
* `Asset` class to represent individual assets:
  * methods `get_submissions` (for asset type survey) and `to_list`
* `CODE_OF_CONDUCT.md` and `CONTRIBUTING.md`
* pkgdown site, with separate pages for [stable](https://correlaid.github.io/kbtbr/main/) and [dev](https://correlaid.github.io/kbtbr/dev/) version.
* `NEWS.md` file to track changes to the package.
