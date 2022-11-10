#' @importFrom magrittr %>%
#' @importFrom dplyr arrange
psea <- function(x, y, p, perm){

  # x = the same as D in the paper, with N proteins
  # y = the same as S in the paper, with Nh proteins

  # Check to see if we need to run permutation
  if(perm){
    x[,2] <- sample(x[,2])
    x <- x %>% arrange(desc(Score))
  }


  # Define N and NH as defined in: https://doi.org/10.1073/pnas.0506580102
  # Calculate phit and pmiss (Page 6 paper - Appendix)
  N    <- nrow(x)
  NH   <- length(y)
  indx <- which( as.character(x[,1]) %in% y )
  NR   <- sum( abs(x[indx,2])^p )

  posindx <- as.character(x[,1]) %in% y
  phit    <- cumsum( x[,2] * posindx ) / NR
  pmiss   <- cumsum(!posindx) / (N - NH)

  return(list(phit = phit, pmiss = pmiss))

}
