# working directory should be the FlowAnalysis package root
# precondition: FlowAnalysis loaded with devtools::load_all(".")
library(ggplot2)
library(dplyr)
library(reshape2)

# We want graphs showing:
# * CD86 vs M1 concentration with a series for each M2 dose
# * CD206 vs M2 concentration with a series for each M1 dose
# * CD86 vs M2 concentration with a series for each M1 dose
# * CD206 vs M1 concentration with a series for each M2 dose

sem = function(x) { sd(x) / sqrt(length(x)) }

save_graph = function(graph, stub, graph_name) {
  filename = paste0("client-code/", stub, "-", graph_name, ".pdf")
  ggsave(filename, graph, height=6, width=8, units="in")
}

protocols = c(
  m1_m2="M1-M2 transactivation (washout)",
  m1_sus_m2="M1-M2 transactivation (no washout)",
  m2_m1="M2-M1 transactivation (washout)",
  m2_sus_m1="M2-M1 transactivation (no washout)",
  simultaneous="Simultaneous M1+M2 activation"
)

for(stub in names(protocols)) {
  protocol_df = eval(parse(text=stub))
  normalized_df = normalize_by_positive_controls(protocol_df)
  normalized_df_medians = make_medians(normalized_df)
  df_summarized = normalized_df_medians %>%
    filter(antibody == "exp") %>%
    group_by(m1_concentration, m2_concentration) %>%
    summarize(CD86_mean=mean(CD86), CD206_mean=mean(CD206),
              CD86_sd=sd(CD86), CD206_sd=sd(CD206),
              CD86_sem=sem(CD86), CD206_sem=sem(CD206),
              n=n())
  write.csv(df_summarized, paste0("client-code/", stub, "-summary.csv"), row.names=FALSE)
  
  df_summarized = df_summarized %>%
    mutate(CD86_min=CD86_mean-CD86_sem, CD86_max=CD86_mean+CD86_sem,
           CD206_min=CD206_mean-CD206_sem, CD206_max=CD206_mean+CD206_sem)
  
  # * CD86 vs M1 concentration with a series for each M2 dose
  g = ggplot(df_summarized, aes(m1_concentration, CD86_mean,
                                color=m2_concentration,
                                group=m2_concentration)) +
    geom_point(size=3) +
    geom_line() +
    geom_errorbar(aes(ymin=CD86_min, ymax=CD86_max), width=0.2) +
    theme_bw() +
    scale_color_discrete("M2 concentration\n[ng/ml]") +
    labs(x="M1 concentration\n[ng/ml]", y="CD86 response (fold vs. M1)",
         title=paste(protocols[stub], "CD86 response vs M1 dose, by M2 dose, ± SEM", sep="\n"))
  print(g)
  save_graph(g, stub, "cd86_vs_m1_by_m2")
  
  # * CD206 vs M2 concentration with a series for each M1 dose
  g = ggplot(df_summarized, aes(m2_concentration, CD206_mean,
                                color=m1_concentration,
                                group=m1_concentration)) +
    geom_point(size=3) +
    geom_line() +
    geom_errorbar(aes(ymin=CD206_min, ymax=CD206_max), width=0.2) +
    theme_bw() +
    scale_color_discrete("M1 concentration\n[ng/ml]") +
    labs(x="M2 concentration\n[ng/ml]", y="CD206 response (fold vs. M2)",
         title=paste(protocols[stub], "CD206 response vs M2 dose, by M1 dose, ± SEM", sep="\n"))
  print(g)
  save_graph(g, stub, "cd206_vs_m2_by_m1")
  
  # * CD86 vs M2 concentration with a series for each M1 dose
  g = ggplot(df_summarized, aes(m2_concentration, CD86_mean,
                                color=m1_concentration,
                                group=m1_concentration)) +
    geom_point(size=3) +
    geom_line() +
    geom_errorbar(aes(ymin=CD86_min, ymax=CD86_max), width=0.2) +
    theme_bw() +
    scale_color_discrete("M1 concentration\n[ng/ml]") +
    labs(x="M2 concentration\n[ng/ml]", y="CD86 response (fold vs. isotype)",
         title=paste(protocols[stub], "CD86 response vs M2 dose, by M1 dose, ± SEM", sep="\n"))
  print(g)
  save_graph(g, stub, "cd86_vs_m2_by_m1")
  
  # * CD206 vs M1 concentration with a series for each M2 dose
  g = ggplot(df_summarized, aes(m1_concentration, CD206_mean,
                                color=m2_concentration,
                                group=m2_concentration)) +
    geom_point(size=3) +
    geom_line() +
    geom_errorbar(aes(ymin=CD206_min, ymax=CD206_max), width=0.2) +
    theme_bw() +
    scale_color_discrete("M2 concentration\n[ng/ml]") +
    labs(x="M1 concentration\n[ng/ml]", y="CD206 response (fold vs. isotype)",
         title=paste(protocols[stub], "CD206 response vs M1 dose, by M2 dose, ± SEM", sep="\n"))
  print(g)
  save_graph(g, stub, "cd206_vs_m1_by_m2")
}