# kbtbr 
<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/CorrelAid/kbtbr/workflows/R-CMD-check/badge.svg)](https://github.com/CorrelAid/kbtbr/actions)
[![Codecov test coverage](https://codecov.io/gh/CorrelAid/kbtbr/branch/main/graph/badge.svg)](https://codecov.io/gh/CorrelAid/kbtbr?branch=main)
<!-- badges: end -->

R Wrapper for the [KoboToolbox API](https://support.kobotoolbox.org/api.html).


**This package is still under development. So far, there are no features here! Check back in a couple of weeks / months :)**
# Documentation
HTML documentation is available for:

- the latest version on the `main` branch: [https://correlaid.github.io/kbtbr/main/](https://correlaid.github.io/kbtbr/main/)
- the `dev` branch [here](https://correlaid.github.io/kbtbr/dev/)

# Contribute
## Development setup
This project uses the [`renv`](https://rstudio.github.io/renv/) package to ensure a consistent R environment across developer machines. 

To install the package dependencies:

```r
install.packages("renv")
renv::install()
```
## Package development workflow

## Branching model
We follow a [feature (or topic) branching workflow](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows). This means that you should create a new Git branch for each issue (or set of related issues) that you are working on. The branch name should contain the issue number to allow for easier cross-referencing.

### Long-lived branches

- `main`: default branch. Should only contain the releases of the package + hotfixes (small, critical bug fixes that can't wait until the next release)
- `dev`: this is where we develop and branch off the feature branches

### Short-lived branches
Short-lived branches for feature development and bugfixes ("feature branches") should be branched off from the `dev` branch. 

```bash
# create branch from dev branch
git checkout dev 
git switch -c 1-project-skeleton # or git checkout -b 1-project-skeleton
# ... work on your branch with add, commit, push 
```

before making a Pull Request to `dev`, pull in the changes from the `dev` branch to avoid running into merge conflicts. With your feature branch checked out, run: 

```bash
git merge dev 
```

