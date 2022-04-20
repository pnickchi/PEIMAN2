getProteinsperPTM = function(x){

  AC  <- as.character( unlist(x[,1])  )
  AC  <- paste0(AC, collapse = '; ')
  PTM <- as.character( unlist(x[1,2]) )

  return( list(PTM = PTM, AC = AC) )

}



findMaxProf = function(x, mx){

  prof <- x$phit - x$pmiss
  indx <- which( abs(prof) == mx)

  return(indx)

}



getProteinsperPTM = function(x){
  AC <- as.character(unlist(x[, 1]))
  AC <- paste0(AC, collapse = "; ")
  PTM <- as.character(unlist(x[1, 2]))
  return(list(PTM = PTM, AC = AC))
}



#' Return the exact taxonomy name for list of protein
#'
#' \code{getTaxonomyName} get a character vector of proteins with their UniProt accession code and returns
#' the exact taxonomy code.
#'
#' @param x A character vector with each entry presenting a protein UniProt accession code.
#' @return The exact taxonomy name
#' @export
#'
#' @examples
#' getTaxonomyName(x = exmplData1$pl1)

getTaxonomyName = function(x){

  # Find user protein list
  temp <- peiman_database %>% filter(AC %in% x)

  if( nrow(temp) > 0 ){
    res <- table(temp$OS)
  }else{
    res <- NA
  }

  if( length(res) > 1 ){
    stop('The list of proteins are mapped to more than one species. Please double check proteins.')
  }

  if( !is.na(res) ){
    print( paste0('Please use os.name = ', '`', names(res) ,'`') )
  }

}

