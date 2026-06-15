#' Run internal PEIMAN singular enrichment analysis
#'
#' @description
#' Internal helper function used by \code{\link{runEnrichment}} to run singular
#' enrichment analysis for a given protein list, organism, background list, and
#' PEIMAN database version.
#'
#' @param pro A character vector of UniProt accession codes.
#'
#' @param os A character string giving the exact taxonomy name of the organism.
#'
#' @param background Optional character vector of UniProt accession codes to use
#'   as the background protein list. If \code{NULL}, all reviewed proteins for
#'   the selected organism in the PEIMAN database are used as the background.
#'
#' @param am Character string specifying the p-value adjustment method. This is
#'   passed to \code{\link[stats]{p.adjust}}.
#'
#' @param db_version Character string specifying which PEIMAN database version to
#'   use. Use \code{'bundled'} for the database included with the package,
#'   \code{'latest'} for the newest cached database, or a specific version such
#'   as \code{'2026-05-01'}.
#'
#' @return A list with two elements:
#' \describe{
#'   \item{\code{enrich}}{A data frame containing the enrichment results.}
#'   \item{\code{ms}}{A character vector of proteins missing from the selected
#'   PEIMAN database.}
#' }
#'
#' @details
#' This function is intended for internal package use. User-facing enrichment
#' analysis should be performed with \code{\link{runEnrichment}}.
#'
#' @keywords internal
#'
#' @importFrom magrittr %>%
#' @importFrom stats phyper
#' @importFrom stats p.adjust
#' @importFrom dplyr arrange filter group_split
#' @importFrom purrr map
peiman <- function(pro, os, background = NULL, am, db_version = 'bundled'){

  #
  # pro: A character vector of proteins
  # os: OS name
  # am: adjustment method
  #
  # Note: This function is internal.
  # No need to check the inputs arguments
  #

  if (!requireNamespace('dplyr', quietly = TRUE)) {
    stop(
      "Package \"dplyr\" must be installed to use this function.",
      call. = FALSE
    )
  }

  peiman_database <- load_peiman_database(version = db_version)

  #
  # Filter peiman database to include os specific proteins
  #
  population <- peiman_database %>% filter(OS == os)

  if( !is.null(background) ){
    population <-  population %>% filter(AC %in% background)

    if( nrow(population) == 0 ){
      stop('Filter on background list does not return any protein. Did you use the correct background list or pass the os.name correctly?')
    }

  }



  # Identify which proteins are available in the current version of peiman database
  # Define list of proteins that are not available in the database
  # Update the proteinList
  pro              <- unique(pro)
  indx             <- which( pro %in% population$AC )
  missing.protein  <- pro[-indx]
  pro              <- pro[indx]


  # Get the total number of proteins in the database (N)
  # Get the number of proteins in the sample list    (n)
  N <- length( unique(population$AC) )
  n <- length(pro)


  # Define sample dataframe containing two columns:
  # 1. PTM: The ptm terms
  # 2. Freq: The frequecncy of each PTM term in sample's list
  temp1 <- population[,c(1,3)] %>% filter( AC %in% pro )
  freq  <- table(temp1$PTM)
  sample  <- data.frame(freq)
  colnames(sample) <- c('PTM', 'Freq')

  # Apply getProteinperPTM() function to get the list of proteins carrying each PTM
  d <- temp1 %>% arrange(PTM) %>% group_split(PTM) %>% map( ~getProteinsperPTM(.) )
  ptm.by.ac <- data.frame( matrix(unlist(d), nrow = length(d), byrow = T), stringsAsFactors = FALSE )
  colnames(ptm.by.ac) <- c('PTM', 'AC')


  # Define uniprot dataframe containing two columns:
  # 1. PTM: The ptm terms
  # 2. The frequency of PTM term in the current version of UniProt
  temp2   <- population[,c(1,3)]
  freq    <- table(temp2$PTM)
  uniprot <- data.frame(freq)
  colnames(uniprot) <- c('PTM', 'Freq')


  # Create the enriched dataframe with the following columns:
  # 1. PTM: The ptm terms
  # 2. Freq in Uniprot: The frequency of ptm in the current version of UniProt
  # 3. Freq in List: The frequency of ptm in the sample list
  # 4. Sample: Number of proteins in the list
  # 5. Population: Number of proteins in the UniProt
  enrich           <- merge(uniprot, sample, by = 'PTM')
  enrich$sample    <- rep(n, nrow(enrich))
  enrich$No        <- rep(N, nrow(enrich))
  colnames(enrich) <- c('PTM', 'FreqinPopulation', 'FreqinSample', 'Sample', 'Population')


  # Run the hypergeometric test
  # Calculate p-value
  # Correct for multiple testing by adjusting pvalues according to am parameter
  x <- enrich$`FreqinSample`
  m <- enrich$`FreqinPopulation`
  k <- n
  enrich$pvalue             <- 1 - phyper(x , m , N-m , k)
  enrich$`corrected pvalue` <- p.adjust(enrich$pvalue, method = am)


  # Sort the enrich output based on corrected pvalues
  enrich <-  arrange( enrich, `corrected pvalue` )

  # Merge ptm.by.ac with enrich list to add a column to present the AC of proteins carrying each PTM
  enrich <- merge(enrich, ptm.by.ac, by = 'PTM')

  # Sort the output based on corrected p-value
  enrich <- enrich %>% arrange(`corrected pvalue`)

  # Change pvalues to scientific notation
  # formatC function from base package
  enrich$`pvalue`           <- as.numeric( formatC(enrich$`pvalue`,           format = "e", digits = 0) )
  enrich$`corrected pvalue` <- as.numeric( formatC(enrich$`corrected pvalue`, format = "e", digits = 0) )

  res = list( enrich = enrich, ms = missing.protein)

  return(res)

}
