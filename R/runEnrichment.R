#' Run singular enrichment analysis (SEA) for a given list of protein
#'
#' @description This function takes proteins with their UniProt accession code, runs singular
#' enrichment (SEA) analysis, and returns enrichment results.
#'
#' @param protein A character vector with protein UniProt accession codes.
#' @param os.name A character vector of length one with exact taxonomy name of species. If you do not know the
#' the exact taxonomy name of species you are working with, please read \code{\link{getTaxonomyName}}.
#' @param p.adj.method The adjustment method to correct for multiple testing. The default value is 'BH'.
#' Run/see \code{\link[stats]{p.adjust.methods}} to get a list of possible methods.
#'
#' @return The result is a dataframe with the following columns:
#' - PTM: Post-translational modification (PTM) keyword
#' - FreqinUniprot: The total number of proteins in UniProt with this PTM.
#' - FreqinList: The total number of proteins in the given list with this PTM.
#' - Sample: Number of proteins in the given list.
#' - Population: Total number of proteins in the current version of PEIMAN database with this PTM.
#' - pvalue: The p-value obtained from hypergeometric test (enrichment analysis).
#' - corrected pvalue: Adjusted p-value to correct for multiple testing.
#' - AC: Uniprot accession code (AC) of proteins with each PTM.
#'
#' @export
#'
#' @examples
#' enrich1 <- runEnrichment(protein = exmplData1$pl1, os.name = 'Homo sapiens (Human)')
runEnrichment = function(protein, os.name, p.adj.method = 'BH'){

  #####################################
  # Step 1: Check the input arguments #
  #####################################

  # stopifnot( class(protein) == 'character')
  #
  # stopifnot( is.vector(protein) )

  flag = FALSE

  stopifnot( class(p.adj.method)== 'character' )

  stopifnot( p.adj.method %in% c('holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY', 'fdr', 'none') )

  if( sum(protein %in% peiman_database$AC) == 0 ){
    stop('None of the proteins are in the current version of PEIMAN databse.')
  }


  # Check and remove if there is any duplicated proteins
  if ( any( duplicated(protein) ) ){
    flag = TRUE
  }


  temp <- peiman_database %>% filter(OS == os.name)
  if( nrow( temp %>% filter( AC %in% protein ) ) == 0 ){
     msg <- 'None of the proteins seem to belong to this OS. Please check OS name again.'
     msg <- paste0(msg, 'You can get a list of OS names and protein information at https://www.uniprot.org/docs/speclist')
     stop(msg)
  }
  rm(temp)


  ##############################################################################
  # Step2. Call peiman function to run singular enrichment analysis (SEA)
  ##############################################################################
  res <- peiman(pro = protein, os = os.name, am = p.adj.method)


  # Let user know if some of the proteins were not in the current version of database.
  if(flag){
    print('The following proteins are not in the current version of database:')
    print( as.character(res[[2]]) )
    print('Therefore they were excluded from final analysis.')
  }

  return(res[[1]])

}
