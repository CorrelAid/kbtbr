# How to contribute to kbtbr

## Code of Conduct
`kbtbr` was initiated within [CorrelAid](https://correlaid.org). As such, it falls under the [CorrelAid Code of Conduct](https://correlaid.org/about/codeofconduct/).

## Reporting issues
Issue reports are always welcome. Please provide a [Reprex](https://www.tidyverse.org/help/) if possible. This might not be possible because of the nature of the `kbtbr` package. In this case, please describe your problem as well as possible, including screenshots and HTTP responses (excluding sensitive data such as API tokens).

## Contribute
We welcome contributions in the form of Pull Requests. Before opening a PR, please open an issue describing what problem you'd like to be working on so that the maintainers can discuss the issue with you and propose feasible solution approaches. 

### Code styling
Please style any code with the following [styler](https://styler.r-lib.org/) command:

```r
styler::style_pkg(style = styler::tidyverse_style, indent_by = 4)
```
### Package development workflow

#### Branching model
We follow a [feature (or topic) branching workflow](https://git-scm.com/book/en/v2/Git-Branching-Branching-Workflows). This means that you should create a new Git branch for each issue (or set of related issues) that you are working on. The branch name should contain the issue number to allow for easier cross-referencing.

#### Long-lived branches

- `main`: default branch. Should only contain the releases of the package + hotfixes (small, critical bug fixes that can't wait until the next release)
- `dev`: this is where we develop and branch off the feature branches

#### Short-lived branches
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
