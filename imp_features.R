source("init.R")

library('caret')
library('glmnet')
library('foreach')
library('parallel')
library('doParallel')


# Transform features to matrix for glmnet
y <- as.numeric(tr$target)

cnames <- colnames(tr)
cnames <- cnames[!(cnames %in% c("gamma_ray", "target"))]

Xtr <- as.matrix(tr[, .SD, .SDcols = cnames])
Xte <- as.matrix(te[, .SD, .SDcols = cnames])

# Parallel computation
cls <- makeCluster(3)
registerDoParallel(cls)
foreach::getDoParWorkers()

# Timeseries CV (train on 2.5k - predict 100, then train on 2.6k, predict 100)
fit_control <- trainControl(method = "timeslice",
                            initialWindow = 2500,
                            horizon = 100,
                            fixedWindow = FALSE,
                            allowParallel = TRUE,
                            returnResamp = "all",
                            verboseIter = TRUE)

# GLM parameters grid
glm_grid <-  expand.grid(.alpha = (1:50) * 0.01, 
                         .lambda = c((10:1) * 0.1, 0.08))

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


# Save best features list -------------------------------------------------
viglm <- varImp(glmn)$importance
viglm$Overall <- viglm$Overall[order(viglm$Overall, decreasing = T)]
viglm <- row.names(viglm)
saveRDS(viglm, 'best_features_glm.rds')
