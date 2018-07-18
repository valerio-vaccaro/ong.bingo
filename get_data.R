library(rvest)
setwd("~/r-studio-workspace/ong.bingo")

time <- Sys.time()
ships <- c("imo:7325887","imo:8505721","imo:7600574","mmsi:244870698","imo:5222354","imo:6825842","imo:7302225", "imo:5148716","mmsi:235105994","mmsi:244090482","mmsi:244630187")

try(load(file="rows.RData"))

for(ship in ships){
   try({
      url <- read_html(paste0("https://www.marinetraffic.com/it/ais/details/ships/", ship))
      
      name <- url %>%
         html_nodes(".no-margin") %>%
         html_text()
      
      data <- url %>%
         html_nodes(":nth-child(6) strong , #tabs-last-pos :nth-child(4) .details_data_link, .group-ib:nth-child(1) strong") %>%
         html_text()
      
      date <- trimws(strsplit(data[1], "\\(")[[1]][2])
      lat <- trimws(strsplit(data[4], "/")[[1]][1])
      lon <- trimws(strsplit(data[4], "/")[[1]][2])
      engine <- trimws(data[6])
      speed <- trimws(strsplit(data[7], "/")[[1]][1])
      direction <- trimws(strsplit(data[7], "/")[[1]][2])
      
      row <- data.frame(time=time, ship=ship, name=name[[1]], date=date, lat=lat, lon=lon, engine=engine, speed=speed, direction=direction)
      if (exists("rows")) rows <- rbind(rows, row)
      else rows <-row
   })
}

rows$speed <- as.numeric(gsub("kn", "", rows$speed))
rows$lat <- as.numeric(gsub("°", "", rows$lat))
rows$lon <- as.numeric(gsub("°", "", rows$lon))
rows$date <- as.POSIXct(rows$date)

save(rows, file="rows.RData")