peiman <- function(pro, os, am){

  #
  # pro: A character vector of proteins
  # os: OS name
  # am: adjustment method
  #
  # Note: This function is internal. No need to check the input arguments
  #


  if (!requireNamespace('dplyr', quietly = TRUE)) {
    stop(
      "Package \"dplyr\" must be installed to use this function.",
      call. = FALSE
    )
  }

  #library(dplyr)


  # Filter peiman database to include proteins
  tempDatabase <- peiman_database %>% filter(OS == os)


  # Identify which proteins are available in the current version of peiman database
  # Define list of proteins that are not available in the database
  # Update the proteinList
  pro              <- unique(pro)
  indx             <- which( pro %in% tempDatabase$AC )
  missing.protein  <- pro[-indx]
  pro              <- pro[indx]


  # Get the total number of proteins in the database (N)
  # Get the number of proteins in the sample list    (n)
  N <- length( unique(tempDatabase$AC) )
  n <- length(pro)


  # Define user dataframe containing two columns:
  # 1. PTM: The ptm terms
  # 2. Freq: The frequecncy of each PTM term in user's list
  temp1 <- tempDatabase[,c(1,3)] %>% filter( AC %in% pro )
  freq  <- table(temp1$PTM)
  user  <- data.frame(freq)
  colnames(user) <- c('PTM', 'Freq')

  # Apply getProteinperPTM() function to get the list of proteins carrying each PTM
  d <- temp1 %>% arrange(PTM) %>% group_split(PTM) %>% map( ~getProteinsperPTM(.) )
  ptm.by.ac <- data.frame( matrix(unlist(d), nrow = length(d), byrow = T), stringsAsFactors = FALSE )
  colnames(ptm.by.ac) <- c('PTM', 'AC')


  # Define uniprot dataframe containing two columns:
  # 1. PTM: The ptm terms
  # 2. The frequency of PTM term in the current version of UniProt
  temp2   <- tempDatabase[,c(1,3)]
  freq    <- table(temp2$PTM)
  uniprot <- data.frame(freq)
  colnames(uniprot) <- c('PTM', 'Freq')


  # Create the enriched dataframe with the following columns:
  # 1. PTM: The ptm terms
  # 2. Freq in Uniprot: The frequency of ptm in the current version of UniProt
  # 3. Freq in List: The frequency of ptm in the user list
  # 4. Sample: Number of proteins in the list
  # 5. Population: Number of proteins in the UniProt
  enrich           <- merge(uniprot, user, by = 'PTM')
  enrich$sample    <- rep(n, nrow(enrich))
  enrich$No        <- rep(N, nrow(enrich))
  colnames(enrich) <- c('PTM', 'FreqinUniprot', 'FreqinList', 'Sample', 'Population')


  # Run the hypergeometric test
  # Calculate p-value
  # Correct for multiple testing by adjusting pvalues according to am parameter
  x <- enrich$`FreqinList`
  m <- enrich$`FreqinUniprot`
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
