rm(list=ls())
setwd('D:/Project_R/Kamis Data/TSP Jarak')

#ambil libraries
library(rvest)
library(dplyr)
library(tidyr)
library(tidytext)
library(ggplot2)
library(googleway)
library(ggmap)

#key
key = 'AIzaSyBN5lDKQnqlt6cBt0JpOXhP4fV6LSDUync'

#alamat
init_data = read_excel('Raw Tempat.xlsx')
init_data = init_data %>% mutate(id = c(1:length(alamat)),
                                 alamat = paste(alamat,
                                                'Kuala Lumpur, Malaysia',
                                                sep=','))
alamat = init_data$alamat

#cari long lat
for(i in 1:max(init_data$id)){
  hasil = google_geocode(alamat[i],key = key)
  lat = hasil$results$geometry$location$lat
  long = hasil$results$geometry$location$lng
  init_data$lat[i] = lat[1]
  init_data$long[i] = long[1]
}

init_data$latlon = paste(init_data$lat,init_data$long,sep='+')

#hitung jarak dengan gmapsdistance
library(gmapsdistance)
set.api.key("AIzaSyBRGZiPPLb_PD3ohlfqN_VGnethK30Qpxs")
jarak = gmapsdistance(origin = init_data$latlon,
                      destination = init_data$latlon,
                      combinations = 'all',
                      mode='driving')

jarak = jarak$Distance
jarak = jarak[,-1]
write.csv(jarak,'hasil jarak google maps.csv')

#jika ada modifikasi di matrix jaraknya
#kalau mau ada yang berkali2, maka di sini lah tempatnya ya...
jarak = read.csv('hasil jarak google maps.csv')


#bikin matrix jarak
distances = as.matrix(jarak) / 1000
colnames(distances) = init_data$id
rownames(distances) = init_data$id
distances <- as.dist(distances)

library(TSP)
tsp <- as.ATSP(distances)
tour = solve_TSP(tsp)
tour_order = as.integer(tour)
tour_order[length(tour_order)+1]=tour_order[1]
tour_length = tour_length(tour)
addresses = init_data[tour_order,]
write.csv(addresses,'final.csv')

#hasil modif finalnya
addresses = read.csv('final.csv')

library(leaflet)
leaflet() %>% addTiles() %>% 
  addCircles(lat=addresses$lat,
             lng = addresses$long,
             radius=50,
             label = addresses$label) %>%
  addPolylines(lat = addresses$lat, 
               lng = addresses$long)


#alternate labels
library(leaflet)
leaflet() %>% addTiles() %>% 
  addCircles(lat=addresses$lat,
             lng = addresses$long,
             radius=50,
             label = addresses$label,
             labelOptions = labelOptions(noHide = T)) %>%
  addPolylines(lat = addresses$lat, 
               lng = addresses$long)
