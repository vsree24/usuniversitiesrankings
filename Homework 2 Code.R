```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)

options(repos = getOption("repos")["CRAN"])

library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)


university= read.csv("https://raw.githubusercontent.com/vsree24/usuniversitiesrankings/refs/heads/main/Universities.csv")

university <- university %>%
  rename(
    `Graduation Rate` = Graduation.rate,
    `# Application Accepted` = X..appl..accepted,
    `Public/Private` = `Public..1...Private..2.`
  ) %>%
  mutate(across(c(`in.state.tuition`, `Graduation Rate`, `# Application Accepted`), ~ suppressWarnings(as.numeric(as.character(.x))), .names = "{.col}")) %>%
  mutate(across(everything(), ~ifelse(is.na(.x), 0, .x)))



ui <- fluidPage(
  titlePanel("US University Rankings Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("state", "Select State:", choices = unique(university$State)),
      selectInput("y_var", "Y-axis Variable:", choices = c("Graduation Rate", "# Application Accepted"), selected = "Graduation Rate")
    ),
    mainPanel(
      plotlyOutput("scatterplot"),
      plotlyOutput("histogram")
    )
  )
)

server <- function(input, output) {
  output$scatterplot <- renderPlotly({
    filtered_data <- university %>% filter(State == input$state)
    y_axis_var <- sym(input$y_var)
    p <- ggplot(filtered_data, aes(x = `in.state.tuition`, y = !!y_axis_var, color = factor(`Public/Private`, labels = c("Public", "Private")), text = College.Name)) + 
      geom_point() +
      labs(title = paste("In-State Tuition vs.", input$y_var, "(", input$state, ")"),
           x = "In-State Tuition", y = input$y_var, color = "School Type") +
      scale_color_manual(values = c("Public" = "blue", "Private" = "red")) + 
      theme_bw()
    ggplotly(p, tooltip = "text")
  })
  
  output$histogram <- renderPlotly({
    filtered_data <- university %>% filter(State == input$state)
    p <- ggplot(filtered_data, aes(x = `in.state.tuition`)) +
      geom_histogram(bins = 30, fill = "skyblue", color = "black") +
      labs(title = "In-State Tuition Distribution", x = "In-State Tuition", y = "Frequency") +
      theme_bw()
    ggplotly(p)
  })
}

shinyApp(ui, server)
```


