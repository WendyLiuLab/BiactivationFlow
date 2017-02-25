# Data munging specific to my data set

#' @export
rename_fluorophores = function(df) {
  plyr::rename(
    df, c("APC.A"="CD86", "Alexa.Fluor.488.A"="CD206"),
    warn_missing=FALSE)
}

#' @export
decorate_from_filename = function(df) {
  regexp = "Specimen\\.001\\.(\\w+?)-([0-9\\.]+)x([0-9\\.]+).exported.FCS3.csv"
  match = stringr::str_replace_all(df$Filename, "_", ".") %>% stringr::str_match(regexp)
  df$antibody = match[,2]
  df$m1_concentration = as.factor(as.numeric(match[,3]))
  df$m2_concentration = as.factor(as.numeric(match[,4]))
  df[!is.na(df$antibody),]
}

#' @export
decorate_timecourse_from_filename = function(df) {
  regexp = "(Specimen_001_)?(\\d+h)-([0-9_]+)x([0-9_]+)-([a-z]+)(_\\d+)?(.exported.FCS3)?.csv"
  match = stringr::str_match(df$Filename, regexp)
  normalize = function(x) (x %>%
    stringr::str_replace_all("_", ".") %>%
    as.numeric %>%
    as.factor)
  df$timepoint = match[,3] %>% as.factor
  df$m1_concentration = normalize(match[,4])
  df$m2_concentration = normalize(match[,5])
  df$antibody = match[,6]
  df[!is.na(df$antibody),]
}

#' @export
render_density_plots = function(df) {
  df %>% group_by(Experiment) %>%
    do(plot=(ggplot(., aes(x=CD206, y=CD86)) +
               facet_grid(m1_concentration~m2_concentration) +
               stat_density2d(aes(fill=..level..), geom="polygon") +
               scale_fill_gradient(low="navyblue", high="red") +
               scale_x_continuous(trans=biexp_trans(lim=100, decade.size=200)) +
               scale_y_continuous(trans=biexp_trans(lim=100, decade.size=200)) +
               coord_cartesian(xlim=c(-100,3e5), ylim=c(-100,3e5)) +
               ggtitle(.$Experiment) +
               theme_bw()) %T>%
         print)
}

#' @export
render_median_plots = function(df) {
  df %>% group_by(Experiment) %>%
    do(
      cd206_plot=(ggplot(., aes(m1_concentration, CD206, color=antibody, group=antibody)) +
                    facet_grid(m2_concentration~.) +
                    geom_point() +
                    geom_line() +
                    ggtitle(paste0(.$Experiment, ": CD206 vs M1 concentration")) +
                    theme_bw()) %T>%
        print,
      cd86_plot=(ggplot(., aes(m2_concentration, CD86, color=antibody, group=antibody)) +
                   facet_grid(m1_concentration~.) +
                   geom_point() +
                   geom_line() +
                   ggtitle(paste0(.$Experiment, ": CD86 vs M2 concentration")) +
                   theme_bw()) %T>%
        print)
}

#' Normalizes a data frame by the (0,0) isotype control.
#' @export
normalize_by_null_isotype = function(df) {
  blank_isotype = df %>%
    filter(antibody == "iso", m1_concentration == 0, m2_concentration == 0) %>%
    group_by(Experiment) %>%
    summarize(iso_CD206=median(CD206), iso_CD86=median(CD86))

  normalized = inner_join(df, blank_isotype, by="Experiment")
  normalized$CD206 = normalized$CD206 / normalized$iso_CD206
  normalized$CD86 = normalized$CD86 / normalized$iso_CD86
  
  normalized[! names(normalized) %in% c("iso_CD206", "iso_CD86")]
}

#' Normalizes a data frame by the (0,0) experimental control.
#' @export
normalize_by_null_condition = function(df) {
  blank_isotype = df %>%
    filter(antibody == "exp", m1_concentration == 0, m2_concentration == 0) %>%
    group_by(Experiment) %>%
    summarize(iso_CD206=median(CD206), iso_CD86=median(CD86))

  normalized = inner_join(df, blank_isotype, by="Experiment")
  normalized$CD206 = normalized$CD206 / normalized$iso_CD206
  normalized$CD86 = normalized$CD86 / normalized$iso_CD86

  normalized[! names(normalized) %in% c("iso_CD206", "iso_CD86")]
}

#' Normalize a data frame by the (0.3,0) and (0,1) conditions.
#' @export
normalize_by_positive_controls = function(df) {
  cd86 = df %>%
    filter(antibody == "exp", m1_concentration == 0.3, m2_concentration == 0) %>%
    group_by(Experiment) %>%
    summarize(cd86_norm = median(CD86))
  cd206 = df %>%
    filter(antibody == "exp", m1_concentration == 0, m2_concentration == 1) %>%
    group_by(Experiment) %>%
    summarize(cd206_norm = median(CD206))
  norms = inner_join(cd86, cd206, by="Experiment")
  normalized = inner_join(df, norms, by="Experiment")
  normalized$CD86 = normalized$CD86 / normalized$cd86_norm
  normalized$CD206 = normalized$CD206 / normalized$cd206_norm
  normalized[! names(normalized) %in% c("cd86_norm", "cd206_norm")]
}

#' Normalize a data frame by the (0.3,0,24) and (0,1,24) conditions.
#' @export
normalize_by_positive_controls_timepoint = function(df) {
  cd86 = df %>%
    filter(antibody == "exp", m1_concentration == 0.3, m2_concentration == 0, timepoint == "24h") %>%
    group_by(Experiment) %>%
    summarize(cd86_norm = median(CD86))
  cd206 = df %>%
    filter(antibody == "exp", m1_concentration == 0, m2_concentration == 1, timepoint == "24h") %>%
    group_by(Experiment) %>%
    summarize(cd206_norm = median(CD206))
  norms = inner_join(cd86, cd206, by="Experiment")
  normalized = inner_join(df, norms, by="Experiment")
  normalized$CD86 = normalized$CD86 / normalized$cd86_norm
  normalized$CD206 = normalized$CD206 / normalized$cd206_norm
  normalized[! names(normalized) %in% c("cd86_norm", "cd206_norm")]
}

#' Medians
#' @export
make_medians = function(df) {
  df %>%
    group_by(Experiment, antibody, m1_concentration, m2_concentration) %>%
    summarize(CD206 = median(CD206), CD86 = median(CD86))
}

#' Median plots
#' @export
render_summary_median_plots = function(df) {
  (df %>% filter(antibody == "exp") %>%
    ggplot(aes(m2_concentration, CD86, color=Experiment)) +
      facet_grid(m1_concentration~.) +
      geom_point() +
      geom_path(aes(group=Experiment), alpha=0.3) +
      stat_summary(fun.y=mean, geom="line", aes(group="Mean"),
                   alpha=0.5, size=1, color="black") +
      ggtitle("Summary: CD86 vs M2 concentration") +
      theme_bw()) %>%
    print()
  
  (df %>% filter(antibody == "exp") %>%
    ggplot(aes(m1_concentration, CD206, color=Experiment)) +
      facet_grid(m2_concentration~.) +
      geom_point() +
      geom_path(aes(group=Experiment), alpha=0.3) +
      stat_summary(fun.y=mean, geom="line", aes(group="Mean"),
                   alpha=0.5, size=1, color="black") +
      ggtitle("Summary: CD206 vs M1 concentration") +
      theme_bw()) %>%
    print()
  
  NULL
}