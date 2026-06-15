#' Download and cache a PEIMAN database version
#'
#' @description
#' Downloads a PEIMAN database file from the online PEIMAN database repository
#' and stores it in the user's local PEIMAN2 cache directory.
#'
#' @param version Character string specifying which database version to
#'   download. The default is \code{'latest'}, which downloads the newest
#'   available database version listed in the online database log. A specific
#'   version such as \code{'2026-05-01'} can also be supplied.
#'
#' @param refresh Logical. If \code{FALSE}, the database is not downloaded again
#'   if it already exists in the local cache. If \code{TRUE}, the database is
#'   downloaded again and replaces the cached file.
#'
#' @return Invisibly returns the path to the cached database file.
#'
#' @details
#' Database files are stored in the PEIMAN2 user cache directory:
#'
#' \code{tools::R_user_dir('PEIMAN2', which = 'cache')}
#'
#' This function requires internet access. It is not called automatically when
#' the package is loaded.
#'
#' @export
update_peiman_database <- function(version = 'latest', refresh = FALSE) {

  cache_dir <- tools::R_user_dir('PEIMAN2', which = 'cache')
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  database_log_url <- 'https://raw.githubusercontent.com/pnickchi/PEIMAN2-database/main/databases/config.json'

  database_log <- tryCatch(
    {
      jsonlite::fromJSON(database_log_url)
    },
    error = function(e) {
      stop(
        'Could not read the PEIMAN database config json file. ',
        'Please check your internet connection or try again later.',
        call. = FALSE
      )
    }
  )


  if (version == 'latest') {
    version <- sort(database_log$version)[length(database_log$version)]
  }

  selected <- database_log[database_log$version == version, ]

  if (nrow(selected) == 0) {
    stop(
      'Database version "', version, '" was not found in the online database log.',
      call. = FALSE
    )
  }

  destfile <- file.path(cache_dir, selected$file)

  if (file.exists(destfile) && !refresh) {
    message('PEIMAN database version ', version, ' is already cached.')
    return(invisible(destfile))
  }

  tryCatch(
    {
      utils::download.file(
        url = selected$url,
        destfile = destfile,
        mode = 'wb',
        quiet = TRUE
      )
    },
    error = function(e) {
      stop(
        'Could not download the PEIMAN database. ',
        'Please check your internet connection or try again later.',
        call. = FALSE
      )
    }
  )

  message('PEIMAN database version ', version, ' was downloaded and cached.')

  invisible(destfile)
}
