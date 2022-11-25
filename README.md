# Breast Cancer Quantitative Features Exploration App

<!-- badges: start -->

![GitHub release (latest by
date)](https://img.shields.io/github/v/release/stat545ubc-2022/assignment-b3-jowong4)
<!-- badges: end -->

For STAT545B assignment B-3, I have chosen option B and implemented my own shiny app. This shiny App contains breast cancer quantitative features found in the `cancer_sample` dataset in the package `datateachr`. The goal of this shiny App is to provide an interactive resource to explore the relations between different quantitative features by allowing users to select the interested features and visualize. Users can also look at the entire dataset and filter columns based on the results from their exploration.



As part of assignment B-3, I have implemented the following features.

1. Users can select the x and y variables to explore the relationship between the two variables. Boxplots of both variables are provided below the scatter plot to examine the variables individually.
2. Users can colour the scatterplot based on a third variable.
3. Users can select the columns of the table to view using a checkbox system.

The shiny app is currently deployed on [shinyapps.io](https://jowong.shinyapps.io/assignment-b3-jowong4/).


## How to run the shiny app locally?

I have listed 2 ways to run the code in this repository. Please ensure that you have R, RStudio, and the packages used in this codebase installed before running

### Dependencies
 * R
 * shiny
 * datateachr
 * tidyverse

You can install the [`datateachr`](https://github.com/UBC-MDS/datateachr) package by typing the following into your **R terminal**:

    install.packages("devtools")
    devtools::install_github("UBC-MDS/datateachr")


Cloning the repo:

1.  Press the green "Code"" button and then click the copy button

2.  Open Rstudio and create a new project by going to "File" and then click "New Project"

3.  Press Version Control then Git. Then paste the link into the url box.

4.  Run `runApp()`

Using shiny utility:

1. run `shiny::runGitHub("stat545ubc-2022/assignment-b3-jowong4")`
