% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/groupMembersReturn.R
\name{groupMembersReturn}
\alias{groupMembersReturn}
\title{Forms return list of groupAddAssign function}
\usage{
groupMembersReturn(savedGroupMembers, savedScore, withKin, kmat)
}
\arguments{
\item{savedGroupMembers}{selected animal group}

\item{savedScore}{score of selected group, which is the group having the
largest minimum group size}

\item{withKin}{logical variable indicating to return kinship coefficients
when \code{TRUE}.}

\item{kmat}{numeric matrix of pairwise kinship values. Rows and columns
are named with animal IDs.}
}
\description{
@return A list with members \code{savedGroupMembers},
\code{savedScore}, and if \code{withKin == TRUE} \code{groupKin} as well.
}
