source("init.R")

library('caret')
library('glmnet')
library('foreach')
library('parallel')
library('doParallel')


# Select features to use in the model
# Firstly the model with all the features was trained and features were ranked
# in order of importance. This ranking is used below:

# If you're to use OHE and other experimental features load this script and
# then add them to `glmvh_feats` variable below.
source("exp_features.R")

viglm <- readRDS("best_features_glm.rds")

n_feat <- 4
glmvh_feats <- c(
  viglm[c(1:n_feat)],
  "gear_circ19",
  "prob_circ3"
)

tr$year <- tr$year - 2018
te$year <- te$year - 2018

# Transform features to matrix for glmnet
y <- as.numeric(tr$target)
Xtr <- as.matrix(tr[, .SD, .SDcols = glmvh_feats])
Xte <- as.matrix(te[, .SD, .SDcols = glmvh_feats])

# Parallel computation
cls <- makeCluster(3)
registerDoParallel(cls)
foreach::getDoParWorkers()

# Models
fit_control <- trainControl(method = "timeslice",
                            initialWindow = 2500,
                            horizon = 200,
                            fixedWindow = FALSE,
                            allowParallel = TRUE,
                            returnResamp = "all",
                            verboseIter = TRUE)

glm_grid <-  expand.grid(.alpha = (1:60) * 0.01, 
                         .lambda = c(0.01:0.1))


set.seed(11)
# lower_wt <- 2000
glmn <- caret::train(x = Xtr,
                     y = y,
                     method = "glmnet", 
                     family = "gaussian",
                     metric = "Rsquared",
                     trControl = fit_control,
                     tuneGrid = glm_grid
                     # weights = c(rep(1, lower_wt), rep(2, (nrow(tr) - lower_wt)))
)


# Show best result
glmn$results[row.names(glmn$bestTune), ]


stopCluster(cls)

# predict -----------------------------------------------
glm_pred <- predict(glmn, newdata = Xte)

# Plot predictions
ggplot(data = data.table(x = Xtr[, 'year'], 
                         fact = y, 
                         fc = predict(glmn, newdata = Xtr))) +
  geom_line(aes(x = x, y = fact), color = "black") +
  geom_line(aes(x = x, y = fc), color = "red") +
  labs(title = 'Forecast is red',
       y = "",
       x = "Time") +
  theme_minimal() +
  theme(plot.title = element_text(size = 20))

# Submit predictions ------------------------------------------------------
fwrite(data.table(year = te$year, target = glm_pred),
       paste0('subm/',
              'alf_',
              round(glmn$results[row.names(glmn$bestTune), 'alpha'], 2),
              '_lmb_',
              round(glmn$results[row.names(glmn$bestTune), 'lambda'], 2),
              '_',
              'rsq_',
              round(glmn$results[row.names(glmn$bestTune), 'Rsquared'], 7), 
              '_glmnet', '.csv'), 
       row.names = FALSE)
