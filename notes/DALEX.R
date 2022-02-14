library(tidyverse)
library(tidymodels)
library(ranger)
library(here)
library(DALEX)
library(DALEXtra)
library(lime)
library(patchwork)
library(rcfss)

# import data and model
scorecard_train <- read_rds(file = here("data", "scorecard-train.Rds"))
scorecard_test <- read_rds(file = here("data", "scorecard-test.Rds"))
model_rf <- read_rds(file = here("data", "model-rf.Rds"))
model_glmnet <- read_rds(file = here("data", "model-glmnet.Rds"))

# extract example observations for local interpretation
uchi <- filter(.data = scorecard, name == "University of Chicago") %>%
  select(-unitid, -name)

# create explainer objects
explainer_rf <- explain_tidymodels(
  model = model_rf,
  data = scorecard_train %>% select(-debt),
  y = scorecard_train$debt,
  label = "random forest"
)

explainer_glmnet <- explain_tidymodels(
  model = model_glmnet,
  data = scorecard_train %>% select(-debt),
  y = scorecard_train$debt,
  label = "penalized regression"
)

####### local methods
# breakdown plot (aka first differences?)
# but with this procedure the order of the features matters
bd_rf <- predict_parts(
  explainer = explainer_rf,
  new_observation = uchi,
  type = "break_down"
)
plot(bd_rf)

# breakdown plot for interactions
bdi_rf <- predict_parts(
  explainer = explainer_rf,
  new_observation = uchi,
  type = "break_down_interactions"
)
plot(bdi_rf)

# shapley values
shap_rf <- predict_parts(
  explainer = explainer_rf,
  new_observation = uchi,
  type = "shap"
)
plot(shap_rf)

# LIME
# prepare the recipe
prepped_rec_rf <- extract_recipe(model_rf)
prepped_rec_glmnet <- extract_recipe(model_glmnet)

# write a function to convert the legislative description to an appropriate matrix object
bake_rf <- function(x) {
  bake(
    prepped_rec_rf,
    new_data = x
  )
}

bake_glmnet <- function(x) {
  bake(
    prepped_rec_glmnet,
    new_data = x,
    composition = "dgCMatrix"
  )
}

# create explainer object
lime_explainer_rf <- lime(
  x = scorecard_train,
  model = extract_fit_parsnip(model_rf),
  preprocess = bake_rf
)
lime_explainer_glmnet <- lime(
  x = scorecard_train,
  model = extract_fit_parsnip(model_glmnet),
  preprocess = bake_glmnet
)

explanation_rf <- explain(
  x = uchi,
  explainer = lime_explainer_rf,
  n_features = 10,
  n_permutations = 1000
)
explanation_glmnet <- explain(
  x = uchi,
  explainer = lime_explainer_glmnet,
  n_features = 10,
  n_permutations = 1000
)

plot_features(explanation_rf)
plot_features(explanation_glmnet)

####### global methods
# imputation-based variable importance
vip_rf <- model_parts(explainer_rf, loss_function = loss_root_mean_square)
vip_glmnet <- model_parts(explainer_glmnet, loss_function = loss_root_mean_square)

plot(vip_rf) +
  plot(vip_glmnet)

# partial dependence plots
pdp_cost <- model_profile(explainer_rf, variables = "cost", N = 100)
plot(pdp_cost, geom = "profiles")

pdp_cost_group <- model_profile(explainer_rf, variables = "cost", groups = "type", N = 100)
plot(pdp_cost_group, geom = "profiles")

pdp_cost_cl <- model_profile(explainer_rf, variables = "cost", k = 3, N = 100)
plot(pdp_cost_cl, geom = "profiles")









