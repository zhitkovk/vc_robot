source("init.R")


# target plot -------------------------------------------------------------


tp <-
  ggplot(data = tr, aes(x = year, y = target, color = gamma_ray)) +
  geom_line() +
  theme_bw()

# tp


# train scatter features + target -----------------------------------------


scatter_plotter <- function(x, y, data) {
  p <- ggplot(data = data, aes_string(x = x, y = y, color = "gamma_ray")) +
    geom_point(alpha = 0.5, shape = 1) +
    labs(title = paste0(x, ' & ', y),
         x = "",
         y = "") +
    theme_minimal() +
    theme(legend.position = "top",
          legend.justification = "left",
          legend.title = element_blank())
  
  return(p)
}

feats <- colnames(tr)[!(colnames(tr) %in% c("target", "gamma_ray"))]

# Plots actually
sc_list <- lapply(feats, scatter_plotter, "target", tr)

# # All together on one plot
# big_grid <- Reduce(`+`, sc_list)
# big_grid <- big_grid + plot_layout(ncol = 6)
# ggsave("img/all_scatters.png", big_grid, width = 20, height = 40)


for (i in 1:length(sc_list)) {
  ggsave(paste0("img/scats/", sc_list[[i]]$labels$title, ".png"), 
         sc_list[[i]],
         width = 10, 
         height = 8)
  cat('Saving plot', i, '\n')
}



# Feature scatter ---------------------------------------------------------
subs <- colnames(tr)[!(colnames(tr) %in% c("target"))]

trte <- rbind(tr[, .SD, .SDcols = subs], 
              te[, .SD, .SDcols = subs])

feats <- colnames(tr)[!(colnames(tr) %in% c("target", "gamma_ray", "year"))]

pair_feats <- t(combn(feats, 2))

cors <- cor(trte[, .SD, .SDcols = feats])


rnc <- row.names(cors)
cors <- data.table(cors)
cors$vars <- rnc

corsm <- melt.data.table(cors, id.vars = "vars")
corsm[, k := paste0(variable, vars)]

pair_feats <- data.table(pair_feats)
pair_feats[, k := paste0(V1, V2)]

pair_feats <- merge(pair_feats, corsm, by = 'k')
pair_feats <- pair_feats[, list(k, V1, V2, value)]

pair_feats <- pair_feats[abs(value) > 0.8]

feat_corr <- lapply(1:nrow(pair_feats), function(x) scatter_plotter(pair_feats$V1[x],
                                                                    pair_feats$V2[x], 
                                                                    data = trte))


for (j in 1:length(feat_corr)) {
  ggsave(paste0("img/feat_cors/", pair_feats$k[j], ".png"), 
         feat_corr[[j]],
         width = 10, 
         height = 8)
  if (j %% 10 == 0) {
    cat('Saving plot', j, '\n')
  }
}


# Feature values distribution across train and test -----------------------


trte <- rbind(tr[, .SD, .SDcols = feats], 
              te[, .SD, .SDcols = feats])
trte[, samp := c(rep("train", nrow(tr)), 
                 rep("test", nrow(te)))]

hist_plotter <- function(x, data, fill) {
  p <- ggplot(data = data, aes_string(x = x, fill = fill)) +
    geom_histogram(alpha = 0.6, position = position_nudge()) +
    labs(title = x,
         y = "",
         x = "") +
    theme_minimal() +
    theme(legend.position = "top",
          legend.justification = "left",
          legend.title = element_blank())
}

feat_hists <- lapply(colnames(trte)[colnames(trte) %in% feats], hist_plotter, data = trte, fill = "samp")


for (j in 1:length(feat_hists)) {
  ggsave(paste0("img/trte_hists/", feats[j], ".png"), 
                                                feat_hists[[j]],
                                                width = 10, 
                                                height = 8)
  cat('Saving plot', j, '\n')
}


# test gamma ray levels HISTS ---------------------------------------------


test_feat_gammaray <- lapply(colnames(te)[colnames(te) %in% feats], hist_plotter, te, "gamma_ray")      


for (j in 1:length(test_feat_gammaray)) {
  ggsave(paste0("img/te_gamma_hists/", colnames(te)[colnames(te) != "target"][j], ".png"), 
         test_feat_gammaray[[j]],
         width = 10, 
         height = 8)
  cat('Saving plot', j, '\n')
}


# feature timeline --------------------------------------------------------


# subs <- colnames(tr)[!(colnames(tr) %in% c("year"))]
trte <- rbind(tr, te)

trte[, samp := c(rep("train", nrow(tr)), 
                 rep("test", nrow(te)))]

setnames(trte, "year", "year_")

library(patchwork)
time_plotter <- function(y, x, data) {
  p <- ggplot(data = data, aes_string(x = x, y = y, color = "samp")) +
    geom_rect(xmin = 4080, xmax = 4120, ymin = -Inf, ymax = Inf,
              color = NA,
              fill = "#ebe6eb", alpha = 0.1) +
    geom_line() +
    labs(title = y,
         x = "",
         y = "") + 
    scale_color_manual(values = c("#ca0068","#7142ff")) +
    theme_minimal() +
    theme(legend.position = "top",
          legend.justification = "left",
          legend.title = element_blank())
    
  
  p2 <- ggplot(data = data, aes_string(x = x, y = "target")) + 
    geom_rect(xmin = 4080, xmax = 4120, ymin = -Inf, ymax = Inf,
              color = NA,
              fill = "#ebe6eb", alpha = 0.1) +
    geom_vline(xintercept = 4100) +
    geom_line() +
    labs(x = "",
         y = "",
         title = "target") +
    theme_minimal()
  
  
  
  return(p2 + p + plot_layout(ncol = 1, heights = c(1.5, 1.5)))
}

time_feats <- colnames(trte)[!(colnames(trte) %in% c("year_", "gamma_ray", "samp", "target"))]
feattime <- rep(list(list()), length(time_feats))

for (i in 1:length(feattime)) {
  feattime[[i]] <- time_plotter(y = time_feats[[i]], x = "year_", data = trte)
}

feattime[[1]]

for (j in 1:length(feattime)) {
  ggsave(paste0("img/feat_timeline/", time_feats[j], ".png"), 
         feattime[[j]],
         width = 15, 
         height = 4)
  cat('Saving plot', j, '\n')
}
