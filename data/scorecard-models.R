library(tidyverse)
library(tidymodels)
library(rcfss)
library(here)

# get scorecard dataset
data("scorecard")
scorecard <- scorecard %>%
  # remove ID columns - causing issues when interpreting/explaining
  select(-unitid, -name)

# split into training and testing
set.seed(123)

scorecard_split <- initial_split(data = scorecard, prop = .75, strata = debt)
scorecard_train <- training(scorecard_split) %>%
  write_rds(file = here("data", "scorecard-train.Rds"))
scorecard_test <- testing(scorecard_split) %>%
  write_rds(file = here("data", "scorecard-test.Rds"))

scorecard_folds <- vfold_cv(data = scorecard_train, v = 10)

# basic feature engineering recipe
scorecard_rec <- recipe(debt ~ ., data = scorecard_train) %>%
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
rf_mod <- rand_forest() %>%
  set_engine("ranger") %>%
  set_mode("regression")

# combine recipe with model
rf_wf <- workflow() %>%
  add_recipe(scorecard_rec) %>%
  add_model(rf_mod)

# fit using training set
set.seed(123)
rf_wf <- fit(
  rf_wf,
  data = scorecard_train
)

# save final model to disk
write_rds(x = rf_wf, file = here("data", "model-rf.Rds"))

# fit penalized regression model
## recipe
glmnet_recipe <- scorecard_rec %>%
  step_dummy(all_nominal_predictors()) %>%
  step_zv(all_predictors()) %>%
  step_normalize(all_numeric_predictors())

## model specification
glmnet_spec <- linear_reg(penalty = tune(), mixture = tune()) %>%
  set_mode("regression") %>%
  set_engine("glmnet")

## workflow
glmnet_workflow <- workflow() %>%
  add_recipe(glmnet_recipe) %>%
  add_model(glmnet_spec)

## tuning grid
glmnet_grid <- tidyr::crossing(
  penalty = 10^seq(-6, -1, length.out = 20),
  mixture = c(0.05, 0.2, 0.4, 0.6, 0.8, 1)
)

## hyperparameter tuning
glmnet_tune <- tune_grid(
  glmnet_workflow,
  resamples = scorecard_folds,
  grid = glmnet_grid
)

# select best model
glmnet_best <- select_best(glmnet_tune, metric = "rmse")
glmnet_final <- finalize_workflow(glmnet_workflow, glmnet_best) %>%
  last_fit(scorecard_split) %>%
  extract_workflow() %>%
  write_rds(file = here("data", "model-glmnet.Rds"))






