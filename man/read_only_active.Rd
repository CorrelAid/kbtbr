% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{read_only_active}
\alias{read_only_active}
\title{Access Read-Only Active Bindings}
\usage{
read_only_active(private, field, val)
}
\arguments{
\item{private}{Pointer to the private env of an object}

\item{field}{character(1) the name of the active binding field. It is assumed
that a private field prefixed with a single dot exists, that serves as
storage.}

\item{val}{The value passed to the active binding. If it is not missing,
the function will stop.}
}
\value{
The value of the active binding-related storage field.
}
\description{
Template function to create a read-only active binding.
}
