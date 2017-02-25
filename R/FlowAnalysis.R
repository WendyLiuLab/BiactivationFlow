#' Flow cytometry data analysis package
#' 
#' @docType package
#' @name FlowAnalysis
#' @import ggplot2
#' @import dplyr
NULL

#' Put all the data in the global environment.
#' @export
accio_data = function() {
  target = system.file("extdata", "simultaneous.feather", package="FlowAnalysis")
  if(target == "") {
    target = file.path(getwd(), "inst", "extdata", "simultaneous.feather")
  }
  targets = list.files(path=dirname(target), pattern=".*feather", full.names=TRUE)
  for(target in targets) {
    df_name = gsub("(.*)\\.feather", "\\1", basename(target))
    assign(df_name, feather::read_feather(target), envir=.GlobalEnv)
  }
}

#' Load experiments from a path.
#' If you have some/path/experiment1, some/path/experiment2, and so on,
#' pass `some/path` as root.
#' 
#' @param root Path containing folders, one per experiment.
#' @param cleanup A function to call on each input file's data frame before
#'  joining them together that returns a cleaned up data frame.
#' @return A data frame with the combined data from each CSV file in each
#'  experiment, with Experiment and Filename columns.
#' @export
load_experiments = function(root, cleanup=identity) {
  experiments = list.dirs(path=root, recursive=FALSE)
  lapply(experiments, load_an_experiment, cleanup=cleanup) %>% rbind_all
}

#' Load all CSV files in a path.
#' @export
load_an_experiment = function(path, cleanup=identity) {
  files = list.files(path=path, pattern="*.csv", full.names=TRUE)
  if (length(files) == 0) return(data.frame())
  do_read = function(filename) {
    a_file = read.csv(filename)
    a_file$Filename = basename(filename)
    cleanup(a_file)
  }
  an_experiment = lapply(files, do_read) %>% rbind_all
  an_experiment$Experiment = basename(path)
  an_experiment
}

#' Biexponential scale function
#' https://groups.google.com/forum/#!msg/ggplot2/7ddCyXGlKiM/Vn881OG13-AJ
#' @export
biexp_trans <- function(lim = 100, decade.size = lim){
  trans <- function(x){
    ifelse(x <= lim,
           x,
           lim + decade.size * (suppressWarnings(log(x, 10)) -
                                  log(lim, 10)))
  }
  inv <- function(x) {
    ifelse(x <= lim,
           x,
           10^(((x-lim)/decade.size) + log(lim,10)))
  }
  breaks <- function(x) {
    if (all(x <= lim)) {
      scales::pretty_breaks()(x)
    } else if (all(x > lim)) {
      scales::log_breaks(10)(x)
    } else {
      unique(c(scales::pretty_breaks()(c(x[1],lim)),
               scales::log_breaks(10)(c(lim, x[2]))))
    }
  }
  scales::trans_new(paste0("biexp-",format(lim)), trans, inv, breaks)
}

.onLoad = function(libname, pkgname) {
  accio_data()
}