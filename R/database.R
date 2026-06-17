#' Download and cache PEIMAN2 external data files
#'
#' @description
#' Downloads external PEIMAN2 data files from the online PEIMAN2 database
#' repository and stores them in the user's local PEIMAN2 cache directory.
#' This can include the main PEIMAN database, the UniProt PTM list, or both.
#'
#' @param version Character string specifying which version to download. The
#'   default is \code{'latest'}, which downloads the newest available version
#'   for the selected file type listed in the online configuration file. A
#'   specific version such as \code{'2026-05-01'} can also be supplied.
#'
#' @param refresh Logical. If \code{FALSE}, a file is not downloaded again if it
#'   already exists in the local cache. If \code{TRUE}, the file is downloaded
#'   again and replaces the cached file.
#'
#' @param type Character string specifying which file type to download. Use
#'   \code{'database'} for the main PEIMAN database, \code{'ptmlist'} for the
#'   UniProt PTM list, or \code{'all'} to download both. The default is
#'   \code{'all'}.
#'
#' @return Invisibly returns the path or paths to the cached file(s).
#'
#' @details
#' Cached files are stored in the PEIMAN2 user cache directory:
#'
#' \code{tools::R_user_dir('PEIMAN2', which = 'cache')}
#'
#' This function requires internet access. It is not called automatically when
#' the package is loaded.
#'
#' The online configuration file contains at least the following
#' columns: \code{type}, \code{version}, \code{file}, and \code{url}.
#'
#' @export
update_peiman_database <- function(version = 'latest', refresh = FALSE, type = 'all') {

  type <- match.arg(type, choices = c('database', 'ptmlist', 'all'))

  cache_dir <- tools::R_user_dir('PEIMAN2', which = 'cache')
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)

  database_log_url <- 'https://raw.githubusercontent.com/pnickchi/PEIMAN2-database/main/databases/config.json'

  database_log <- tryCatch(
    {
      jsonlite::fromJSON(database_log_url)
    },
    error = function(e) {
      stop(
        'Could not read the PEIMAN2 database config json file. ',
        'Please check your internet connection or try again later.',
        call. = FALSE
      )
    }
  )

  required_cols <- c('type', 'version', 'file', 'url')
  missing_cols <- setdiff(required_cols, colnames(database_log))

  if (length(missing_cols) > 0) {
    stop(
      'The PEIMAN2 database config file is missing the following required column(s): ',
      paste(missing_cols, collapse = ', '),
      call. = FALSE
    )
  }

  selected_types <- if (type == 'all') {
    c('database', 'ptmlist')
  } else {
    type
  }

  cached_files <- character(0)

  for (current_type in selected_types) {

    current_log <- database_log[database_log$type == current_type, ]

    if (nrow(current_log) == 0) {
      stop(
        'No entries of type "', current_type, '" were found in the online database log.',
        call. = FALSE
      )
    }

    current_version <- version

    if (current_version == 'latest') {
      current_version <- sort(current_log$version)[length(current_log$version)]
    }

    selected <- current_log[current_log$version == current_version, ]

    if (nrow(selected) == 0) {
      stop(
        'Version "', current_version, '" for type "', current_type,
        '" was not found in the online database log.',
        call. = FALSE
      )
    }

    destfile <- file.path(cache_dir, selected$file[1])

    if (file.exists(destfile) && !refresh) {
      message(
        'PEIMAN2 ', current_type, ' version ', current_version,
        ' is already cached.'
      )
      cached_files <- c(cached_files, destfile)
      next
    }

    tryCatch(
      {
        utils::download.file(
          url = selected$url[1],
          destfile = destfile,
          mode = 'wb',
          quiet = TRUE
        )
      },
      error = function(e) {
        stop(
          'Could not download PEIMAN2 ', current_type,
          ' version "', current_version, '". ',
          'Please check your internet connection or verify that the file exists in the repository.',
          call. = FALSE
        )
      }
    )

    message(
      'PEIMAN2 ', current_type, ' version ', current_version,
      ' was downloaded and cached.'
    )

    cached_files <- c(cached_files, destfile)
  }

  invisible(cached_files)
}


#' Load a UniProt PTM list
#'
#' Loads the UniProt PTM list used internally by PEIMAN2. By default, this
#' function loads the PTM list bundled with the package. It can also load the
#' latest cached PTM list or a specific cached PTM list version.
#'
#' @param version Character string specifying which PTM list version to load.
#'   The default is \code{'bundled'}, which uses the PTM list included with the
#'   package. Use \code{'latest'} for the newest cached PTM list, or a specific
#'   version such as \code{'2026-06-15'}.
#'
#' @return A data frame containing the UniProt PTM list.
#'
#' @details
#' Cached PTM list files are expected to be stored in the PEIMAN2 user cache
#' directory, given by:
#'
#' \code{tools::R_user_dir('PEIMAN2', which = 'cache')}
#'
#' Cached PTM list files should follow the naming format:
#'
#' \code{uniprot_ptm_list_YYYY-MM-DD.rds}
#'
#' This function is intended mainly for internal package use.
#'
#' @keywords internal
load_ptmlist <- function(version = 'bundled') {

  if (version == 'bundled') {
    return(ptmlist)
  }

  cache_dir <- tools::R_user_dir('PEIMAN2', which = 'cache')

  if (version == 'latest') {

    files <- list.files(
      cache_dir,
      pattern = '^uniprot_ptm_list_\\d{4}-\\d{2}-\\d{2}\\.rds$',
      full.names = TRUE
    )

    if (length(files) == 0) {
      stop(
        'No cached UniProt PTM list found. ',
        'Run update_peiman_database() first, or use version = "bundled".',
        call. = FALSE
      )
    }

    latest_file <- sort(files)[length(files)]
    return(readRDS(latest_file))
  }

  file <- file.path(
    cache_dir,
    paste0('uniprot_ptm_list_', version, '.rds')
  )

  if (!file.exists(file)) {
    stop(
      'UniProt PTM list version "', version, '" is not cached. ',
      'Run update_peiman_database(version = "', version, '") first.',
      call. = FALSE
    )
  }

  readRDS(file)
}
