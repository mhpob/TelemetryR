#' Prepare VEMCO transmitter CSV files for analysis
#'
#' \code{vemsort} finds and combines all VEMCO CSV files in a directory
#'
#' This function assumes that all necessary CSV files are within the specified
#' directory or subdirectories within. All files must have the default headings
#' offloaded by VEMCO products. These are, in order:
#' Date and Time (UTC), Receiver, Transmitter, Transmitter Name,
#' Transmitter Serial, Sensor Value, Sensor Unit, Station Name,
#' Latitude, Longitude.
#'
#' @param directory String. Location of CSV data, defaults to current wd.
#' @param clust A cluster object created by \code{\link[parallel]{makeCluster}}.
#'    If cluster is supplied, this will use \code{\link[parallel]{parLapply}} to
#'    import the files. Defaults to NULL with no parallel evaluation.
#' @param prog_bar Logical. Do you want a progress bar displayed? Will increase
#'    evaluation time. Initiates \code{\link[pbapply]{pblapply}}.
#' @param creation_date Character date in a standard unambiguous format
#'    (e.g., YYYY-MM-DD). Will select only files created after this date.
#' @return Output is a data frame containing all detections from
#'    the directory's CSV files. Adds two columns: one containing local time of
#'    the detections (as defined by \code{Sys.timzone}) and one containing the
#'    detection's CSV file of origin.
#' @seealso \code{\link[parallel]{makeCluster}}, \code{\link[parallel]{parLapply}},
#'    \code{\link[pbapply]{pblapply}}
#' @export
#' @examples
#' vemsort('C:/Users/mypcname/Documents/Vemco/Vue/ReceiverLogs')
#'
#' # Select files created after Jan 1, 2015
#' vemsort('C:/Users/mypcname/Documents/Vemco/Vue/ReceiverLogs',
#'          creation_date = '2015-01-01')
#'
#' # Use parallel computation and a progress bar
#' cl <- parallel::makeCluster(parallel::detectCores() - 1)
#' vemsort('C:/Users/mypcname/Documents/Vemco/Vue/ReceiverLogs',
#'          clust = cl, prog_bar = T)
#' parallel::stopCluster(cl)

vemsort <- function(directory = getwd(), clust = NULL, prog_bar = F,
                    creation_date = NULL) {
  cat('Reading files...\n')

  # List all files within the provided directory
  files <- list.files(path = directory, pattern = '*.csv', full.names = T,
                      recursive = T)

  # Select files created after a given date, if provided
  if(!is.null(creation_date)){
    files <- files[file.info(files)$ctime > creation_date]
  }

  # Read in files and name list elements for later indexing
  if(prog_bar == T){
    if (!requireNamespace("pbapply", quietly = TRUE)) {
      stop("Please install the \"pbapply\" package to use progress bars.",
           call. = FALSE)
    }

    detect.list <- pbapply::pblapply(cl = clust,
                                     X = files,
                                     FUN = data.table::fread,
                                     sep = ",",
                                     stringsAsFactors = F)
  } else {
    if(is.null(clust)){
      detect.list <- lapply(X = files,
                            FUN = data.table::fread,
                            sep = ",",
                            stringsAsFactors = F)
    } else {
      detect.list <- parallel::parLapply(cl = clust,
                                         X = files,
                                         fun = data.table::fread,
                                         sep = ",",
                                         stringsAsFactors = F)
    }
  }

  names(detect.list) <- grep('*.csv',
                             unlist(strsplit(files, '/')),
                             value = T)


  cat('Binding files...\n')

  # Make list into data frame
  detects <- data.table::rbindlist(detect.list, fill = T, idcol = 'file')
  names(detects) <- c('file', 'date.utc', 'receiver', 'transmitter',
                      'trans.name', 'trans.serial', 'sensor.value',
                      'sensor.unit', 'station', 'lat', 'long')


  cat('Final data manipulation...\n')

  # Convert UTC to computer's local time zone
  detects$date.utc <- lubridate::ymd_hms(detects$date.utc)
  detects$date.local <- lubridate::with_tz(detects$date.utc,
                                           tz = Sys.timezone())

  # Move columns around
  detects <- detects[, c('date.utc', 'date.local', 'receiver', 'transmitter',
                         'trans.name', 'trans.serial', 'sensor.value',
                         'sensor.unit', 'station', 'lat', 'long', 'file')]

  # Select unique detections
  detects <- unique(detects, by = c('date.utc', 'transmitter', 'station'))

  as.data.frame(detects)
}
