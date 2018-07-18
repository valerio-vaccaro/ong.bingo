## ui.R ##
library(shinydashboard)
library(leaflet)

load("./rows.RData")

ui <- dashboardPage(
   dashboardHeader(
      title = "ong.bingo"
   ),
   
   ## Sidebar content
   dashboardSidebar(
      sidebarMenu(
         menuItem(
            "Status",
            tabName = "dashboard",
            icon = icon("dashboard")
         )
      ),
      sliderInput(
         "time",
         "Select start and stop time",
         min = min(rows$time),
         max = max(rows$time),
         value = c(max(rows$time) -  as.difftime(3, unit="days"),  max(rows$time))
      ),
      sliderInput(
         "speed",
         "Select min and max speed",
         min = min(rows$speed),
         max = max(rows$speed),
         value = c(min(rows$speed),max(rows$speed))
      )
   ),
   dashboardBody(tabItems(
      # dashboard content
      tabItem(
         tabName = "dashboard",
         fluidRow(
            infoBoxOutput("dateBox"),
            infoBoxOutput("speedBox"),
            infoBoxOutput("pulseBox")
         ),
         fluidRow(
            box(
               title = "Map of the activity",
               status = "primary",
               solidHeader = TRUE,
               width = 12,
               leafletOutput("p5", height = 600)
            )
         ),
         fluidRow(
            box(
               title = "Activity",
               status = "primary",
               solidHeader = TRUE,
               plotOutput("p2", height = 300)
            ),
            box(
               title = "Speed",
               status = "primary",
               solidHeader = TRUE,
               plotOutput("p1", height = 300)
            )
         )
         
      )
   ))
)
