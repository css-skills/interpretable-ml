## Overview

Machine learning algorithms are widely used in data science applications and have significant potential to improve predictions and understanding of social scientific processes. However machine learning models generally do not explain their predictions -- they simply seek to minimize some loss function and provide for a given observation the probability of an event occurring. In many applications researchers need to be able to explain why the model made one prediction over another. This emphasis on **interpretability** and **explanation** is directly relevant to many social scientific questions, and can provide necessary context for decision makers who need to use machine learning models but lack a strong technical background. In this workshop we introduce several techniques for interpreting black box models using model-agnostic techniques.

## Objectives

- Define interpretation and explanation, and their importance to machine learning
- Identify model-agnostic methods for creating interpretations/explanations
- Implement techniques for creating global model-agnostic explanations in R
- Implement techniques for creating local model-agnostic explanations in R

## Audience

This workshop is designed for individuals with introductory-to-intermediate knowledge of machine learning algorithms, as well as experience training machine learning models using R. Prior experience with [`tidymodels`](https://www.tidymodels.org/) is helpful, but not required.

## Location

Room 295 in [1155 E 60th St](https://goo.gl/maps/7n7wDsd9mjnfRBtR8).

## Prework

- Register for this workshop. Due to the current public health crisis, all participants must register in advance using [this form.](https://forms.gle/wgEVhripKHjzNEzDA)
- Please sign up for a free [RStudio Cloud account](https://rstudio.cloud).
- Once you have created your RStudio Cloud account, [join the workshop organization.](https://rstudio.cloud/spaces/177434/join?access_code=cGV7c0V8%2Bpr0kFC5NkOX%2FgxNNhIm3PchWX1CjdBf)

## Links

- [Slides](https://css-skills.github.io/interpretable-ml/slides/)
- [Source materials for the workshop on GitHub](https://github.com/css-skills/intro-to-r-for-python-user)

## Additional Resources

- [*Explanatory Model Analysis* by Przemyslaw Biecek and Tomasz Burzykowski](https://ema.drwhy.ai/) - a book written by the co-authors of [`DALEX`](https://dalex.drwhy.ai/) which outlines the intuition and methodology of many of the interpretation/explanation methods we discuss in the workshop. Also includes code examples in R and Python.
- [*Interpretable Machine Learning* by Christoph Molnar](https://christophm.github.io/interpretable-ml-book/) - another textbook on interpretability and explanation in machine learning. Written by the author of [`iml`](https://christophm.github.io/iml/), an alternative package for interpreting and explaining models in R using model-agnostic methods.
- [Maksymiuk, S., Gosiewska, A., & Biecek, P. (2020). Landscape of R packages for eXplainable Artificial Intelligence. *arXiv preprint* arXiv:2009.13248.](https://arxiv.org/abs/2009.13248) - an exhaustive survey of all known R packages which implement eXplainable Artificial Intelligence (XAI).
- [Explaining models and predictions, in *Tidy Modeling with R* by Max Kuhn and Julia Silge](https://www.tmwr.org/explain.html) - a book chapter demonstrating how to integrate model explanations into the `tidymodels` workflow.
