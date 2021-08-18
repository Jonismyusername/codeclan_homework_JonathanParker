library(tidyverse)
library(shiny)
library(CodeClanData)
library(shinythemes)

all_teams <- unique(olympics_overall_medals$team)

ui <- fluidPage(
    
    theme = shinytheme("cosmo"),
    
    titlePanel(tags$b("Olympic Medal Comparison")),
    
    tags$hr(),
    
    tabsetPanel(
        tabPanel(
            tags$b("Country"),
            tags$br(),
            fluidRow(
                column(3,
                       radioButtons(
                           "season",
                           tags$em("Which season?"),
                           choices = c("Summer", "Winter")
                       )   
                ),
                column(3,
                       radioButtons(
                           "medal",
                           tags$em("Which medal type?"),
                           choices = c("Gold", "Silver", "Bronze")
                       )
                )
            )
            
        ),
        tabPanel(
            tags$b("Olympian"),
            tags$br(),
            
        )
    ),
    
    tags$hr(),
    
    plotOutput("medal_plot")
    
)


server <- function(input, output){
    
    output$medal_plot <- renderPlot({
        
        olympics_overall_medals %>%
            filter(team %in% c("United States",
                               "Soviet Union",
                               "Germany",
                               "Italy",
                               "Great Britain")) %>%
            filter(medal == input$medal) %>%
            filter(season == input$season) %>%
            ggplot() +
            aes(x = team, y = count, fill = medal
                #         case_when(
                #     medal == "Gold" ~ "gold",
                #     medal == "Silver" ~ "silver",
                #     medal == "Bronze" ~ "bronze"
                # )
            ) +
            geom_col() +
            scale_fill_manual(
                values = c(
                    "Gold" = "#FFD700",
                    "Silver" = "#C0C0C0",
                    "Bronze" = "#CD7F32"
                )
            )
    })
    
}

shinyApp(ui = ui, server = server)

