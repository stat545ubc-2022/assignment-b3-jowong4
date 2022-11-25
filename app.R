library(shiny)
library(datateachr) # for cancer_sample dataset
library(tidyverse)

variables = colnames(cancer_sample)[3:32]
colour_variables = colnames(cancer_sample)[2:32]
can_samp_col <- colnames(cancer_sample)

ui <- fluidPage(
  titlePanel("Diagnostic Breast Cancer Data App"),
  h4("Use this app to explore the quantative features of breast cancer nuclei"),
  sidebarLayout(
    sidebarPanel(
      h3("Graph Options"),
      selectInput(
        "x_variable",
        label = "select x variable",
        choices = variables
      ),
      selectInput(
        "y_variable",
        label = "select y variable",
        choices = variables
      ),
      selectInput(
        "colour",
        label = "colour",
        choices = colour_variables
      ),
      br(),
      h3("Table Options:"),
      uiOutput("choose_columns"),
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
    ggplot(cancer_sample, aes_string(x = factor(0), input$x_variable)) +
      geom_boxplot(na.rm = TRUE) + # supress warning message about removing NA entries
      geom_jitter(na.rm = TRUE) + # supress warning message about removing NA entries
      theme_bw() + 
      theme(axis.title.y = element_blank(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank()) +
        xlab(str_to_title(str_replace(input$x_variable, "_", " ")))
    }
  )
  
  output$box_plot_y <- renderPlot(
    {
    ggplot(cancer_sample, aes_string(x = factor(0), input$y_variable)) +
        geom_boxplot(na.rm = TRUE) + # supress warning message about removing NA entries
        geom_jitter(na.rm = TRUE) + # supress warning message about removing NA entries
        theme_bw() + 
        theme(axis.title.y = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank()) +
        xlab(str_to_title(str_replace(input$y_variable, "_", " ")))
    }
  )
  
  output$choose_columns <- renderUI( #automatic checkbox genereation
    {
      checkboxGroupInput("columns", "Choose columns", choices = can_samp_col, selected = can_samp_col)
    }
  )
  
  output$tbl <- renderTable(
    {
      filtered_cancer_sample <- cancer_sample[, input$columns, drop = FALSE]
      filtered_cancer_sample
    }
  )
}

shinyApp(ui = ui, server = server)