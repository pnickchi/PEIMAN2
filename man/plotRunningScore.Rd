% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotRunningScore.R
\name{plotRunningScore}
\alias{plotRunningScore}
\title{Plot running score plot for the results of psea}
\usage{
plotRunningScore(
  x,
  nplot = length(x$psea.result),
  type = "l",
  lty = 1,
  lwd = 3,
  cex = 1.2,
  cex.axis = 1.2,
  cex.lab = 1.1,
  col = "blue"
)
}
\arguments{
\item{x}{A list of 6 generated by runPSEA function.}

\item{nplot}{An integer that defines the number of running score plots to show. Default value is the number of enriched PTMs in x.}

\item{type}{Type of line used in the plot.}

\item{lty}{A list of 6 generated by runPSEA function.}

\item{lwd}{line width}

\item{cex}{Specify the size of the title text}

\item{cex.axis}{Specify the size of the tick label}

\item{cex.lab}{Specify the size of the axis label text}

\item{col}{Color of running enrichment score line}
}
\value{
Plot
}
\description{
This function takes results generated by \code{\link{runPSEA}}. It plots running enrichment score of
ranked protein for each PTM.
}
\examples{
# We recommend at least nperm = 1000.
# The number of permutations was reduced to 10
# to accommodate CRAN policy on examples (run time <= 5 seconds).
psea_res <- runPSEA(protein = exmplData2, os.name = 'Rattus norvegicus (Rat)', nperm = 10)
plotRunningScore(x = psea_res)
}
