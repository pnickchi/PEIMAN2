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
#' @param database_version Character string specifying which PEIMAN database
#'   version to use. The default is \code{'bundled'}, which uses the database
#'   included with the package. Use \code{'latest'} for the newest cached
#'   database, or a specific version such as \code{'2026-05-01'}.
#' @return The exact taxonomy name
#' @export
#'
#' @examples
#' getTaxonomyName(x = exmplData1$pl1)

getTaxonomyName <- function(x, database_version = 'bundled'){

  # Load the requested db version
  peiman_database <- load_peiman_database(version = database_version)

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



#' Load a PEIMAN database
#'
#' Loads the PEIMAN database used internally by PEIMAN2. By default, this
#' function loads the database bundled with the package. It can also load the
#' latest cached database or a specific cached database version.
#'
#' @param version Character string specifying which database version to load.
#'   Use \code{'bundled'} to load the database included with the package,
#'   \code{'latest'} to load the newest cached database, or a specific version
#'   such as \code{'2026_05_01'}.
#'
#' @return A data frame containing the PEIMAN database.
#'
#' @details
#' Cached databases are expected to be stored in the PEIMAN2 user cache
#' directory, given by:
#'
#' \code{tools::R_user_dir('PEIMAN2', which = 'cache')}
#'
#' Cached database files should follow the naming format:
#'
#' \code{peiman_database_YYYY_MM_DD.rds}
#'
#' This function is intended mainly for internal package use.
#'
#' @keywords internal
load_peiman_database <- function(version = 'bundled'){

  if (version == 'bundled') {
    return(peiman_database)
  }

  cache_dir <- tools::R_user_dir('PEIMAN2', which = 'cache')

  if (version == 'latest') {

    files <- list.files(cache_dir, pattern = '^peiman_database_\\d{4}-\\d{2}-\\d{2}\\.rds$', full.names = TRUE)

    if (length(files) == 0) {
      stop(
        'No cached PEIMAN database found. ',
        'Run update_peiman_database() first, or use version = "bundled".',
        call. = FALSE
      )
    }

    latest_file <- sort(files)[ length(files) ]

    return(readRDS(latest_file))
  }

  file <- file.path( cache_dir, paste0('peiman_database_', version, '.rds') )

  if ( !file.exists(file) ){
    stop(
      'PEIMAN database version "', version, '" is not cached. ',
      'Run update_peiman_database(version = "', version, '") first.',
      call. = FALSE
    )
  }

  readRDS(file)
}
