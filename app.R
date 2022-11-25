library(shiny)
library(datateachr) # for cancer_sample dataset
library(tidyverse)

plot_variables = colnames(cancer_sample)[3:32] # variable names to plot scatterplot
feature_variables = colnames(cancer_sample)[2:32] #variables names to color scatterplot

boxplot <- function(colname) { # boxplot code to avoid code duplication
  boxplot_obj <- 
    ggplot(cancer_sample, aes_string(x = factor(0), colname)) +
    geom_boxplot(na.rm = TRUE) + # supress warning message about removing NA entries
    geom_jitter(na.rm = TRUE) + # supress warning message about removing NA entries
    theme_bw() + 
    theme(axis.title.y = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank()) +
    xlab(str_to_title(str_replace(colname, "_", " ")))
  return(boxplot_obj)
}

ui <- fluidPage(
  titlePanel("Diagnostic Breast Cancer Data App"),
  h4("Use this app to explore the quantative features of breast cancer nuclei"),
  sidebarLayout(
    sidebarPanel(
      h3("Graph Options"),
      selectInput( # drop down menu to select x variable
        "x_variable",
        label = "select x variable",
        choices = plot_variables
      ),
      selectInput( # drop down menu to select y variable
        "y_variable",
        label = "select y variable",
        choices = plot_variables
      ),
      selectInput( # drop down menu to colour based on selected variable
        "colour",
        label = "colour",
        choices = feature_variables
      ),
      br(),
      h3("Table Options:"),
      uiOutput("choose_columns"), # output checkbox ui
      br()
    ),
    mainPanel(
      plotOutput("scatter_plot"),
      fluidRow( # render box plots side by side
        splitLayout(
          cellWidths = c("50%", "50%"), 
          plotOutput("box_plot_x"),
          plotOutput("box_plot_y"))),
      tableOutput("tbl")
    )
  )
)

server <- function(input, output) {
  output$scatter_plot <- renderPlot(
    {
      ggplot(cancer_sample,
             aes_string(x = input$x_variable, y = input$y_variable)) + 
        geom_point(size = 2, aes(color = .data[[input$colour]])) + 
        theme_bw() +
        xlab(str_to_title(str_replace(input$x_variable, "_", " "))) + 
        ylab(str_to_title(str_replace(input$y_variable, "_", " "))) 
    }
  )
  
  output$box_plot_x <- renderPlot(
    {
      boxplot(input$x_variable)
    }
  )
  
  output$box_plot_y <- renderPlot(
    {
      boxplot(input$y_variable)
    }
  )
  
  output$choose_columns <- renderUI( # automatic checkbox genereation
    {
      checkboxGroupInput("columns", "Choose columns", choices = feature_variables)
    }
  )
  
  output$tbl <- renderTable(
    {
      cancer_sample %>%
        select(c("ID", input$columns)) # filter based on checkbox selection
    }
  )
}

shinyApp(ui = ui, server = server)