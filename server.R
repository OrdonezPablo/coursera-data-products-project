library(readxl)
library(tidyverse)
library(plotly)
library(leaflet)
library(rgdal) #geospatial data abstraction library
library(raster)
library(RColorBrewer)
library(htmltools)


# load PE ts data



# load map and pe data

sfdf <- readOGR(dsn = getwd(), layer = "TM_WORLD_BORDERS-0.3")

country_pe <- read_excel("country pe.xlsx", 
                         sheet = "spot pe (value)", skip = 4)

mymerge <<- merge(sfdf, country_pe, by = "NAME")
bins <- c(seq(10, 30, by = 2))
pal <- colorBin("YlOrRd", domain = mymerge$BEST_PE_RATIO, bins = bins)


# Define server
shinyServer (
    function(input, output) {
    
    output$plotleaflet <- renderLeaflet({
        leaflet(data = mymerge) %>% 
            addTiles() %>% 
            setView( lat = 10, lng = 0, zoom = 1.5) %>% 
            addPolygons(fillColor = ~pal(BEST_PE_RATIO),
                        weight = 2,
                        opacity = 1,
                        #title = "P/E ratio",
                        color = "white",
                        dashArray = "3",
                        fillOpacity = 0.7) %>% 
            addLegend(pal = pal, values = ~BEST_PE_RATIO, opacity = 0.7, title = NULL,
                      position = "bottomright") %>% 
        addMarkers(~LON,
                   ~LAT,
                   label = ~paste(NAME, as.character(round(BEST_PE_RATIO,1)))
        )
                   
        
    })
    
    selectedData <- reactive({
        pe_ts_long <- read_csv("pe_ts_long.csv")
        pe_ts_long %>% 
            filter(index == input$index) %>% 
            mutate(mean = mean(pe))
        
    })
    
    output$plot1 <- renderPlotly({
        ggplot(selectedData(), aes(Date, pe)) +
            geom_line() +
            geom_hline(aes(yintercept=mean))
    })
    
    }
)
