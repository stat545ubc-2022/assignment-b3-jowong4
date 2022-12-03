library(shiny)
library(datateachr) # for cancer_sample dataset
library(tidyverse)
library(DT)

plot_variables = colnames(cancer_sample)[3:32] # variable names to plot scatterplot
feature_variables = colnames(cancer_sample)[2:32] #variables names to color scatterplot

boxplot <- function(df, colname) { # boxplot code to avoid code duplication
  boxplot_obj <- 
    ggplot(df, aes_string(x = factor(0), colname)) +
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
        choices = plot_variables,
        selected = "radius_mean"
      ),
      sliderInput("x_range", "x variable range:",
                  min = min(cancer_sample$radius_mean), max = max(cancer_sample$radius_mean),
                  value = c(min(cancer_sample$radius_mean), max(cancer_sample$radius_mean))),
      selectInput( # drop down menu to select y variable
        "y_variable",
        label = "select y variable",
        choices = plot_variables,
        selected = "texture_mean"
      ),
      sliderInput("y_range", "y variable range:",
                  min = min(cancer_sample$texture_mean), max = max(cancer_sample$texture_mean),
                  value = c(min(cancer_sample$texture_mean), max(cancer_sample$texture_mean))),
      selectInput( # drop down menu to colour based on selected variable
        "colour",
        label = "colour",
        choices = feature_variables,
        selected = "diagnosis"
      ),
      br(),
      h3("Table Options:"),
      checkboxGroupInput("columns", "Choose columns", choices = feature_variables,
                         selected = c("radius_mean", "texture_mean", "diagnosis")),
      br()
    ),
    mainPanel(
      plotOutput("scatter_plot"),
      fluidRow( # render box plots side by side
        splitLayout(
          cellWidths = c("50%", "50%"), 
          plotOutput("box_plot_x"),
          plotOutput("box_plot_y"))),
      DT::dataTableOutput("tbl")
    )
  )
)

server <- function(input, output, session) {
  
  observeEvent(input$x_variable,
               {
                 min_val <- floor(min(cancer_sample[, input$x_variable]))
                 max_val <- ceiling(max(cancer_sample[, input$x_variable]))
                 updateSliderInput(session = session, inputId = "x_range",
                                                   min = min_val, max = max_val,
                                                   value = c(min_val, max_val)
                                                   )
                 updateCheckboxGroupInput(session = session, inputId = "columns",
                                          choices = feature_variables, selected = c(
                                            input$x_variable,
                                            input$y_variable,
                                            input$colour
                                          ))
               }
               )
  
  observeEvent(input$y_variable,
               {
                 min_val <- floor(min(cancer_sample[, input$y_variable]))
                 max_val <- ceiling(max(cancer_sample[, input$y_variable]))
                 updateSliderInput(session = session, inputId = "y_range",
                                   min = min_val, max = max_val,
                                   value = c(min_val, max_val))
                 updateCheckboxGroupInput(session = session, inputId = "columns",
                                          choices = feature_variables, selected = c(
                                            input$x_variable,
                                            input$y_variable,
                                            input$colour
                                          ))
               }
  )
  
  observeEvent(input$colour,
               {
                 updateCheckboxGroupInput(session = session, inputId = "columns",
                                          choices = feature_variables, selected = c(
                                            input$x_variable,
                                            input$y_variable,
                                            input$colour
                                          ))
               }
  )  
  
  filtered_cancer_sample <- reactive(
    {
      cancer_sample %>%
        filter(get(input$x_variable) >= input$x_range[1] & get(input$x_variable) <= input$x_range[2]) %>%
        filter(get(input$y_variable) >= input$y_range[1] & get(input$y_variable) <= input$y_range[2])
    }
  )
  
  output$scatter_plot <- renderPlot(
    {
      req(filtered_cancer_sample()$radius_mean, input$x_variable, input$x_range, input$y_variable, input$y_range) # ensure reactive table and variables are finalized before renddering
      ggplot(filtered_cancer_sample(),
             aes_string(x = input$x_variable, y = input$y_variable)) + 
        geom_point(size = 2, aes(color = .data[[input$colour]])) + 
        theme_bw() +
        xlab(str_to_title(str_replace_all(input$x_variable, "_", " "))) + 
        ylab(str_to_title(str_replace_all(input$y_variable, "_", " "))) 
    }
  )
  
  output$box_plot_x <- renderPlot(
    {
      req(filtered_cancer_sample()$radius_mean, input$x_variable, input$x_range)  # ensure reactive table and variables are finalized before renddering
      boxplot(filtered_cancer_sample(), input$x_variable)
    }
  )
  
  output$box_plot_y <- renderPlot(
    {
      req(filtered_cancer_sample()$radius_mean, input$y_variable, input$y_range)  # ensure reactive table and variables are finalized before renddering
      boxplot(filtered_cancer_sample(), input$y_variable)
    }
  )
  
  
  output$tbl <- DT::renderDataTable(server = FALSE,
    {
      req(filtered_cancer_sample()$radius_mean, input$x_variable, input$x_range, input$y_variable, input$y_range)  # ensure reactive table and variables are finalized before renddering
      filtered_cancer_sample() %>%
        select(c("ID", input$columns))
    },
    extensions = "Buttons",
    options = list(dom = "Bfrtip",
                   buttons = c("copy", "csv", "excel", "pdf", "print"))
  )
}

shinyApp(ui = ui, server = server)