#' Run Protein Set Enrichment Analysis (PSEA)
#'
#' @description This is the main function to run protein set enrichment analysis for a list of proteins and their score.
#'
#' @param protein A dataframe with two columns. Frist column should be protein accession code, second column is the score.
#' @param os.name A character vector of length one with exact taxonomy name of species. If you do not know the
#' the exact taxonomy name of species you are working with, please read \code{\link{getTaxonomyName}}.
#' @param pexponent Enrichment weighting exponent, p. For values of p < 1, one can detect incoherent patterns
#' in a set of protein. If one expects a small number of proteins to be coherent in a large set, then p > 1 is
#' a good choice.
#' @param nperm Number of permutation to estimate false discovery rate (FDR). Default value is 1000.
#' @param p.adj.method The adjustment method to correct pvalues for multiple testing in enrichment.
#' Run p.adjust.methods() to get a list of possible methods.
#' @param sig.level The significance level to filter PTM (applies on adjusted p-value)
#' @param minSize PTMs with the number of proteins below this threshold are excluded.
#' @return Returns a list of 6:
#' 1: A dataframe with protein set enrichment analysis (PSEA) results.
#' Every row corresponds to a post-translational modification (PTM) pathway.
#' - PTM: PTM keyword
#' - pval: p-value for singular enrichment analysis
#' - pvaladj: adjusted p-value
#' - FreqinUniProt: The frequency of PTM in UniProt
#' - FreqinList: The frequency of PTM in the given list
#' - ES: enrichment score
#' - NES: enrichmnt score normalized to mean enrichment of random samples of the same size
#' - nMoreExtreme: number of times the permuted sample resulted in a profile with a larger ES value than abs(ES)
#' - size: Number of proteins with the PTM
#' - Enrichment: Whether the proteins in the pathway have been enriched in the list.
#' - AC: Uniprot accession code (AC) of proteins with each PTM.
#' - leadingEdge:
#' @export
#'
#' @importFrom stats p.adjust.methods
#'
#' @examples
#' psea_res <- runPSEA(protein = exmplData2, os.name = 'Rattus norvegicus (Rat)', nperm = 10)
runPSEA = function(protein, os.name, pexponent = 1, nperm = 1000, p.adj.method = 'fdr', sig.level = 0.05, minSize = 1){


  ########################################################
  # Step 1: Check the input arguments
  ########################################################

  stopifnot( is.data.frame(protein) )

  stopifnot( class(os.name) == 'character' )

  stopifnot( length(os.name) == 1 )

  stopifnot( pexponent > 0 & pexponent <= 1 )

  stopifnot( nperm > 1 )

  stopifnot( class(p.adj.method)== 'character' )

  #stopifnot( p.adj.method %in% c('holm', 'hochberg', 'hommel', 'bonferroni', 'BH', 'BY', 'fdr', 'none') )
  stopifnot( p.adj.method %in% p.adjust.methods )

  stopifnot( sig.level > 0 & sig.level < 1 )

  stopifnot( minSize > 0 )

  # Check and remove if there is any duplicated proteins
  if ( any( duplicated(protein[,1]) ) ){
    warning('Duplicated proteins were removed.')
    protein <- protein[!duplicated(protein[,1]),]
  }




  ##############################################################################
  # Step2. Call peiman function to run ordinary enrichment analysis and get pathways
  ##############################################################################


  # Change colnames of protein dataframe
  colnames(protein) <- c('Protein', 'Score')
  protein           <- protein %>% mutate(Protein = as.character(Protein)) %>% arrange(desc(Score))
  protein           <- as.data.frame(protein)


  # Run ordinary enrichment
  enrich <- peiman(pro = protein[,1], os = os.name, am = p.adj.method)

  # Filter enrich result based on corrected p-values less than sig.level. Also filter on minSize
  enrich <- enrich[[1]] %>%
            filter(`corrected pvalue` < sig.level) %>%
            filter(`FreqinList` >= minSize)


  # Check if any pathway exists after filtering
  if(nrow(enrich) == 0){
    stop('No PTM remained after filtering. Change sig.level or miSize')
  }



  ##############################################################################
  # Step3. Run Protein Set Enrichment Analysis (PSEA)
  ##############################################################################


  # Setup objects to save results
  ES           <- vector(mode = 'numeric')
  NES          <- vector(mode = 'numeric')
  Enrichment   <- vector(mode = 'character')
  nMoreExtreme <- vector(mode = 'numeric')
  size         <- vector(mode = 'numeric')
  leadingEdge  <- list()
  psea.result  <- list()
  rug.indx     <- list()
  x.max.indx   <- list()
  y.max.indx   <- list()


  total   <- nrow(enrich)
  # Loop through all rows in enrich
  for( i in 1:total ){

    # Get proteins in the i-th pathway
    pro.pathway <- unlist( str_split(enrich[i,'AC'] ,pattern = '; ') )
    size[i]     <- length(pro.pathway)

    # Run PSEA for i-th pathway and save the results in temp
    profObj <- psea(x = protein, y = pro.pathway, p = pexponent, perm = FALSE)

    # Record the observed statistic for i-th pathway
    temp             <- calculateES( x = profObj )
    ES[i]            <- temp$ES
    mx.indx          <- temp$pos


    # Setup graphical settings for plotting
    rug.indx[[i]]    <- which( protein[,1] %in% pro.pathway )
    psea.result[[i]] <- profObj
    x.max.indx[[i]]  <- mx.indx
    y.max.indx[[i]]  <- max( abs(profObj$phit - profObj$pmiss) )


    # Find leading edge proteins
    if( ES[i] >=0 ){
      leadingEdge[[i]] <- paste0( protein[ which( protein[1:mx.indx,1] %in% pro.pathway ), 1], collapse = '; ' )
    }else{
      leadingEdge[[i]] <- paste0( protein[ which( protein[mx.indx:nrow(protein),1] %in% pro.pathway ), 1], collapse = '; ' )
    }

    # permute scores nperm times, save in perm_value, and extract in ES_perm
    perm_value  <- purrr::rerun(nperm, psea(x = protein, y = pro.pathway, p = pexponent, perm = TRUE) )
    ES_perm     <- unlist( sapply(X = perm_value, FUN = calculateES)[2,] )

    # Count number of times that permuted values are greater than ES[i]
    if( ES[i] >= 0){
      nMoreExtreme[i] <- sum( ES_perm >= ES[i] )
    }else{
      nMoreExtreme[i] <- sum( ES_perm <= ES[i] )
    }

    # Get the normalized ES (NES)
    NES[i] <- ES[i] / mean(ES_perm)

    if(NES[i] >= 0){
      Enrichment[i] = 'Significant'
    }else{
      Enrichment[i] = 'Not significant'
    }

  }

  # Create a dataframe as for PSEA output
  res <- data.frame(PTM = enrich[,'PTM'],
                    pval = enrich$pvalue,
                    pvaladj = enrich$`corrected pvalue`,
                    FreqinUniProt = enrich$`FreqinUniprot`,
                    FreqinList    = enrich$`FreqinList`,
                    ES = unlist(ES),
                    NES = NES,
                    nMoreExtreme = nMoreExtreme,
                    size = size,
                    Enrichment = Enrichment,
                    AC = enrich$AC,
                    stringsAsFactors = FALSE )

  temp <- data.frame( matrix( data = unlist(leadingEdge), nrow = length(leadingEdge), byrow = TRUE), stringsAsFactors = FALSE )
  colnames(temp) <- 'leadingEdge'
  res <- cbind(res, temp)


  return( list(res = res, psea.result = psea.result, rug.indx = rug.indx, x.max.indx = x.max.indx, y.max.indx = y.max.indx, nperm = nperm ) )

}
