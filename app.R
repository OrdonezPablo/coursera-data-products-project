library(shiny)
library(leaflet)
library(readxl)
library(tidyverse)
library(plotly)
library(rgdal) #geospatial data abstraction library
library(raster)
library(RColorBrewer)
library(htmltools)


###Load data
sfdf <- readOGR(dsn = getwd(), layer = "TM_WORLD_BORDERS-0.3")
country_pe <- read_excel("./country pe.xlsx", 
                         sheet = "spot pe (value)", skip = 4)
mymerge <- merge(sfdf, country_pe, by = "NAME")
bins <- c(seq(10, 30, by = 2))
pal <- colorBin("YlOrRd", domain = mymerge$BEST_PE_RATIO, bins = bins)
pe_ts_long <- read_csv("./pe_ts_long.csv")

####define user interface

ui <- fluidPage(
        navbarPage("Equity Market Valuations",
                               tabPanel("Global Overview",
                                        mainPanel(
                                            h1("Global Equity Market Valuations"),
                                            h2("Price to Earnings Ratio"),
                                            leafletOutput('plotleaflet')
                                        )
                               ),
                               tabPanel("Country Detail",
                                        pageWithSidebar(
                                            headerPanel('P/E Forward by Index'),
                                            sidebarPanel(
                                                selectInput('index', 'P/E Index', unique(pe_ts_long$index))
                                            ),
                                            mainPanel(
                                                plotlyOutput('plot1')
                                            )
                                        )
                               ),
                               tabPanel(p(icon("info"), "Reference"),
                                        mainPanel(
                                            h5("This Shiny App is the Coursera Developing Data Products course final project."),
                                            h5("The objective is to explore equity market valuations around the globe."),
                                            h5("We use the price-to-earnings or P/E multiple as the main valuation metric."),
                                            h5("Reference for P/E ratio:"),
                                            a(href= "https://www.investopedia.com/terms/p/price-earningsratio.asp",
                                              "https://www.investopedia.com/terms/p/price-earningsratio.asp",
                                              target = "_blank"),
                                            h5("Github Code:"),
                                            a(href = "https://github.com/OrdonezPablo/coursera-data-products-project",
                                              "https://github.com/OrdonezPablo/coursera-data-products-project",
                                              target = "_blank")
                                        ))
    )

)

### Define server
server <- function(input, output) {
    
    output$plotleaflet <- renderLeaflet({
        leaflet(data = mymerge) %>% 
            addTiles() %>% 
            setView( lat = 10, lng = 0, zoom = 2) %>% 
            addPolygons(fillColor = ~pal(BEST_PE_RATIO),
                        weight = 2,
                        opacity = 1,
                        #title = "P/E ratio",
                        color = "white",
                        dashArray = "3",
                        fillOpacity = 0.7) %>% 
            addLegend(pal = pal, values = ~BEST_PE_RATIO, opacity = 0.7, title = NULL,
                      position = "bottomright") %>% 
            addLabelOnlyMarkers(~LON, ~LAT, label = ~NAME)
    })
    
    selectedData <- reactive({
        
        pe_ts_long %>% 
            filter(index == input$index) %>% 
            mutate(mean = mean(pe))
        
    })
    
    output$plot1 <- renderPlotly({
        ggplot(selectedData(), aes(Date, pe)) +
            geom_line() +
            geom_hline(aes(yintercept=mean)) +
            labs(
                y = "Price to Earnings Ratio",
                x = "Date"
            )
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
