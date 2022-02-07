library(tidyverse)
library(tidymodels)
library(rcfss)
library(here)

# get scorecard dataset
data("scorecard")
scorecard

# split into training and testing
set.seed(123)

scorecard_split <- initial_split(data = scorecard, prop = .75, strata = debt)
scorecard_train <- training(scorecard_split)
scorecard_test <- testing(scorecard_split)

# create cross-validation folds
scorecard_folds <- vfold_cv(data = scorecard_train, v = 10)

# basic feature engineering recipe
scorecard_rec <- recipe(debt ~ ., data = scorecard_train) %>%
  # exclude ID variables
  update_role(unitid, name, new_role = "id variable") %>%
  # catch all category for missing state values
  step_novel(state) %>%
  # use median imputation for numeric predictors
  step_impute_median(all_numeric_predictors()) %>%
  # use modal imputation for nominal predictors
  step_impute_mode(all_nominal_predictors()) %>%
  # remove rows with missing values for
  # outcomes - glmnet won't work if any of this column is NA
  # skip = true is necessary to skip this step when preprocessing
  # the assessment set for fit_resamples()
  step_naomit(all_outcomes(), skip = TRUE)

# generate random forest model
rf_mod <- rand_forest(mtry = tune(), min_n = tune(), trees = 1000) %>%
  set_engine("ranger") %>%
  set_mode("regression")

# combine recipe with model
rf_wf <- workflow() %>%
  add_recipe(scorecard_rec) %>%
  add_model(rf_mod)

# tune hyperparameters
set.seed(123)
rf_wf_tune <- tune_grid(
  rf_wf,
  resamples = scorecard_folds,
  grid = 10,
  control = control_grid(verbose = TRUE, save_pred = TRUE)
)

# select the best model based on RMSE
lowest_rmse <- select_best(x = rf_wf_tune, metric = "rmse")

# take the best hyperparameters and finalize model
rf_final <- finalize_workflow(rf_wf, lowest_rmse) %>%
  fit(data = scorecard_train)

# save final model to disk
write_rds(x = rf_final, file = here("data", "rf-final.Rds"))





