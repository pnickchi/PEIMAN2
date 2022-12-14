% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/sea2mass.R
\name{sea2mass}
\alias{sea2mass}
\title{Translate SEA results for Mass Spectrometry searching tools}
\usage{
sea2mass(x, sig.level = 0.05, number.rep = NULL)
}
\arguments{
\item{x}{A dataframe of single enrichment analysis results generated by \code{\link{runEnrichment}} function.}

\item{sig.level}{The significance level to filter pathways (applies on adjusted p-value). Default value is 0.05.}

\item{number.rep}{Only consider PTM terms that occurred more than a specific number of times in UniProt. This number is set
by number.rep parameter. The default value is NULL.}
}
\value{
A database of subset of protein modifications:
\itemize{
\item id: a unique identification for each subset of protein modifications, PSI-MOD.
\item name: the name of modification.
\item def: definition of PSI-MOD definition
}
}
\description{
This function translates singular enrichment analysis results and extracts the required information
for mass spectometry searching tools. The subset of protein modifications is from \url{https://raw.githubusercontent.com/HUPO-PSI/psi-mod-CV/master/PSI-MOD.obo}.
}
\examples{
enrich1 <- runEnrichment(protein = exmplData1$pl1, os.name = 'Homo sapiens (Human)')
MS      <- sea2mass(x = enrich1, sig.level = 0.05)
}
