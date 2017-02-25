library(magrittr)

destination = file.path(getwd(), "inst", "extdata")
dir.create(destination, showWarnings=FALSE, recursive=TRUE)

simultaneous = paste0(getwd(), "/data-raw/simultaneous") %>%
  load_experiments(cleanup=rename_fluorophores) %>%
  decorate_from_filename()
feather::write_feather(simultaneous, file.path(destination, "simultaneous.feather"))
readr::write_csv(simultaneous, file.path(destination, "simultaneous.csv"))
rm(simultaneous)

m1_m2 = paste0(getwd(), "/data-raw/m1-m2") %>%
  load_experiments(cleanup=rename_fluorophores) %>%
  decorate_from_filename()
feather::write_feather(m1_m2, file.path(destination, "m1_m2.feather"))
readr::write_csv(m1_m2, file.path(destination, "m1_m2.csv"))
rm(m1_m2)

m1_sus_m2 = paste0(getwd(), "/data-raw/m1-sus-m2") %>%
  load_experiments(cleanup=rename_fluorophores) %>%
  decorate_from_filename()
feather::write_feather(m1_sus_m2, file.path(destination, "m1_sus_m2.feather"))
readr::write_csv(m1_sus_m2, file.path(destination, "m1_sus_m2.csv"))
rm(m1_sus_m2)

m2_m1 = paste0(getwd(), "/data-raw/m2-m1") %>%
  load_experiments(cleanup=rename_fluorophores) %>%
  decorate_from_filename()
feather::write_feather(m2_m1, file.path(destination, "m2_m1.feather"))
readr::write_csv(m2_m1, file.path(destination, "m2_m1.csv"))
rm(m2_m1)

m2_sus_m1 = paste0(getwd(), "/data-raw/m2-sus-m1") %>%
  load_experiments(cleanup=rename_fluorophores) %>%
  decorate_from_filename()
feather::write_feather(m2_sus_m1, file.path(destination, "m2_sus_m1.feather"))
readr::write_csv(m2_sus_m1, file.path(destination, "m2_sus_m1.csv"))
rm(m2_sus_m1)

simul_timecourse = paste0(getwd(), "/data-raw/simultaneous-timecourse") %>%
  load_experiments(cleanup=rename_fluorophores) %>%
  decorate_timecourse_from_filename()
feather::write_feather(simul_timecourse, file.path(destination, "simul_timecourse.feather"))
readr::write_csv(simul_timecourse, file.path(destination, "simul_timecourse.csv"))
rm(simul_timecourse)
