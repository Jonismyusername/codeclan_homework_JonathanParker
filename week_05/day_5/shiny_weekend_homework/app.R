library(tidyverse)
library(shiny)
library(CodeClanData)
library(leaflet)
library(shinythemes)
library(scales)

source("helper.R")

# ui ----------------------------------------------------------------------


ui <- fluidPage(
    
    theme = shinytheme("superhero"),
    
    titlePanel("whiskyr"),
        
    tabsetPanel(
        # This visualisation on the first tab is a simple data table showing
        # the distillery name, region, owner etc. It can be filtered by "Region"
        # using the radio buttons. This was included to give the user an 
        # overview of distilleries in Scotland.
        tabPanel("Distillery Information",
                 tags$br(),
                 radioButtons("region_button",
                              label = tags$h3("Region"),
                              choices = unique(whisky$Region),
                              inline = TRUE),
                 tags$hr(),
                 tags$br(),
                 dataTableOutput("whisky_table")
        ),
        
        # This visualisation shows the geographic location in Scotland of each
        # of the five whisky regions, with markers in each for the distilleries.
        
        # This was included to emphasise to the user that geographic location is 
        # an important factor in the flavour of any whisky, hence being split 
        # into the five regions.
        tabPanel("Regions",
                 tags$br(),
                 tags$hr(),
                 tags$br(),
                 selectInput("region_input",
                             label = tags$h3("Region"),
                             choices = unique(whisky$Region)
                 ),
                 tags$br(),
                 leafletOutput("whisky_map")
        ),
        
        # This visualisation uses a radar chart to show the different flavour
        # profiles for each whisky. A radar chart was chosen as there are 12
        # different flavours to display. It can be filtered by "Distillery" 
        # using the drop-down. 
        
        # This was included to show both the differences and similarities
        # between each whisky in the data set.
        tabPanel("Flavour Profile",
                 tags$br(),
                 tags$hr(),
                 tags$br(),
                 selectInput("distillery_input",
                             label = tags$h3("Distillery"),
                             choices = unique(whisky$Distillery)
                                         ),
                 tags$br(),
                 plotOutput("whisky_radar", 
                            width = "100%", 
                            height = "800px"
                            )
        ),
        
        # With this visualisaiton the user can tweak the 12 flavour profiles 
        # using sliders to find a corresponding whisky, shown via data table.
        
        # Using this tab the user can find their perfect whisky based on the 
        # flavours they like most.
        tabPanel("Find your perfect whisky",
                 tags$br(),
                 tags$hr(),
                 tags$br(),                 
                 fluidRow(
                     column(3,
                            sliderInput("body_input",
                                        label = tags$h4("Body"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                    ),
                    column(3,
                           sliderInput("sweetness_input",
                                       label = tags$h4("Sweetness"),
                                       min = 0, max = 4, value = c(0,4)
                           )
                    ),
                    column(3,
                           sliderInput("smoky_input",
                                       label = tags$h4("Smoky"),
                                       min = 0, max = 4, value = c(0,4)
                            )
                    ),
                    column(3,
                           sliderInput("medicinal_input",
                                       label = tags$h4("Medicinal"),
                                       min = 0, max = 4, value = c(0,4)
                           )
                    )
                 ),
                 tags$br(),
                 fluidRow(
                     column(3,
                            sliderInput("tobacco_input",
                                        label = tags$h4("Tobacco"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                     ),
                     column(3,
                            sliderInput("honey_input",
                                        label = tags$h4("Honey"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                     ),
                     column(3,
                            sliderInput("spicy_input",
                                        label = tags$h4("Spicy"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                     ),
                     column(3,
                            sliderInput("winey_input",
                                        label = tags$h4("Winey"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                     )
                 ),
                 tags$br(),
                 fluidRow(
                     column(3,
                            sliderInput("nutty_input",
                                        label = tags$h4("Nutty"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                     ),
                     column(3,
                            sliderInput("malty_input",
                                        label = tags$h4("Malty"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                     ),
                     column(3,
                            sliderInput("fruity_input",
                                        label = tags$h4("Fruity"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                     ),
                     column(3,
                            sliderInput("floral_input",
                                        label = tags$h4("Floral"),
                                        min = 0, max = 4, value = c(0,4)
                            )
                     )
                 ),
                 tags$br(),
                 tags$hr(),
                 tags$br(),
                 dataTableOutput("flavour_table")
        
        )
    )
)


# server ------------------------------------------------------------------

    

server <- function(input, output) {
  
    output$whisky_table <- renderDataTable({
        whisky %>% 
            filter(Region == input$region_button) %>% 
            # filter(Distillery == input$distillery_input) %>% 
            select(Distillery, Region, Owner, YearFound, Postcode, Capacity)
    })
    
    output$whisky_radar <- renderPlot({
        whisky_flavours_minmax %>% 
        filter(Distillery %in% c(input$distillery_input, "0", "4")) %>% 
        select(Body:Floral) %>% 
        radarchart(lty = 1,
                   cglty = 1,
                   cglwd = 2,
                   cglcol = "grey",
                   pcol = alpha("navy blue", 0.7),
                   pfcol = alpha("#ffbf00", 0.6),
                   plwd = 4, 
                   vlcex = 2.5,
                   )
    })
    
    output$whisky_map <- renderLeaflet({
        whisky %>% 
            filter(Region == input$region_input) %>% 
            leaflet() %>% 
            addTiles() %>% 
            addCircleMarkers(lat = ~Longitude, 
                             lng = ~Latitude, 
                             popup = ~Distillery)
    })
    
    output$flavour_table <- renderDataTable({
        whisky_flavours %>% 
           # filter(Body > input$body_input[1] & Body < input$body_input[2])
            filter(Body >= input$body_input[1] & 
                       Body <= input$body_input[2]) %>% 
            filter(Sweetness >= input$sweetness_input[1] & 
                       Sweetness <= input$sweetness_input[2]) %>% 
            filter(Smoky >= input$smoky_input[1] &
                       Smoky <= input$smoky_input[2]) %>% 
            filter(Medicinal >= input$medicinal_input[1] &
                       Medicinal <= input$medicinal_input[2]) %>% 
            filter(Tobacco >= input$tobacco_input[1] &
                       Tobacco <= input$tobacco_input[2]) %>% 
            filter(Honey >= input$honey_input[1] &
                       Honey <= input$honey_input[2]) %>% 
            filter(Spicy >= input$spicy_input[1] &
                       Spicy <= input$spicy_input[2]) %>% 
            filter(Winey >= input$winey_input[1] &
                       Winey <= input$winey_input[2]) %>% 
            filter(Nutty >= input$nutty_input[1] &
                       Nutty <= input$nutty_input[2]) %>% 
            filter(Malty >= input$malty_input[1] &
                       Malty <= input$malty_input[2]) %>% 
            filter(Fruity >= input$fruity_input[1] &
                       Fruity <= input$fruity_input[2]) %>% 
            filter(Floral >= input$floral_input[1] &
                       Floral <= input$floral_input[2])
    })
}


# app ---------------------------------------------------------------------

shinyApp(ui, server)