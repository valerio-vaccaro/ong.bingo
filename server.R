# server.R
library(ggplot2)
library(grid)
library(stringr)
library(leaflet)
library(dplyr)

load("./rows.RData")
rows <- rows[!duplicated(rows[c("ship","date","lat","lon","speed","direction")]), ]

server <- function(input, output, session) {
   values <- reactiveValues(starting = TRUE)
   session$onFlushed(function() {
      values$starting <- FALSE
   })
   
   output$dateBox <- renderInfoBox({
      infoBox(
              "Activity date",
              paste0("From ",input$time[[1]]," to ",input$time[[2]]),
              icon = icon("time"),
              color = "green")
   })
   
   output$speedBox <- renderInfoBox({
      infoBox(
         "Speed",
         paste0("From ",input$speed[[1]]," to ",input$speed[[2]]),
         icon = icon("road"),
         color = "yellow"
      )
   })
   
   output$pulseBox <- renderInfoBox({
      infoBox(
         "",
         paste0(""),
         icon = icon("heart"),
         color = "red"
      )
   })
   
   output$p1 <- renderPlot({
     filter_speed <- (rows$speed >= input$speed[[1]]) & (rows$speed <= input$speed[2]) 
     filter_time <- (rows$time >= input$time[[1]]) & (rows$time <= input$time[[2]]) 
     data <- rows[filter_speed & filter_time, ]
     ggplot(data, aes(x=speed, fill=name)) +
       geom_histogram()
   })
   
   output$p2 <- renderPlot({
     filter_speed <- (rows$speed >= input$speed[[1]]) & (rows$speed <= input$speed[2]) 
     filter_time <- (rows$time >= input$time[[1]]) & (rows$time <= input$time[[2]]) 
     data <- rows[filter_speed & filter_time, ]
     ggplot(data, aes(x=engine, fill=name)) +
       geom_histogram(stat="count")
   })
   
   output$p5 <- renderLeaflet({
      filter_speed <- (rows$speed >= input$speed[[1]]) & (rows$speed <= input$speed[2]) 
      filter_time <- (rows$time >= input$time[[1]]) & (rows$time <= input$time[[2]]) 
      data <- rows[filter_speed & filter_time, ]
      data$label <- paste(data$name, " - ", data$date, " - speed ", data$speed)
      groups <- as.character(unique(data$name))
      factpal <- colorFactor("Paired", as.factor(data$name))
      
      data_top <- data[data$speed>0.5, ] %>% 
        group_by(ship)  %>%
        top_n(n = 1, date)
      
      map = leaflet(data) %>% addTiles() %>% addProviderTiles(providers$Esri.WorldImagery) 
      for(g in groups){
        d <- data[data$name == g, ]
        map <- map %>% 
          addCircleMarkers(data = d, 
                           lng = ~lon, lat = ~lat, color = ~factpal(name),
                           group = g, 
                           radius = 6, weight = 0, fillOpacity = 0.8, 
                           label = ~label,
                           labelOptions = labelOptions(direction = 'top', offset=c(0,0))
                          )
      }
      map %>% 
        addMarkers(lng=data_top$lon, lat=data_top$lat, popup=data_top$label) %>% 
        addLayersControl(overlayGroups = groups)
   })
   
}