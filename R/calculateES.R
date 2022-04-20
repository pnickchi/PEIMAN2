calculateES = function(x){

  # Calculate the profile
  prof     <- x$phit - x$pmiss

  # Calculate abs(profile) to find the maximum deviation of profile from zero and find the position where this maximum occurs
  abs.diff <- abs( prof )
  mx       <- max( abs.diff )
  mx.indx  <- which( abs.diff == mx)

  # Get the ES value
  ES       <- prof[mx.indx]

  # Return resultss
  res <- list(pos = mx.indx, ES = ES)
  return(res)

}
