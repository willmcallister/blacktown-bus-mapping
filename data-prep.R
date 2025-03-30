# Libraries
library(dplyr)
library(sf)
library(httr2)
library(tidytransit)
library(mapgl)

setwd("/Users/will/Desktop/blacktown-bus-mapping")

# Build query URL
url <- parse_url("https://portal.spatial.nsw.gov.au/server/rest/services")
url$path <- paste(url$path, "NSW_Administrative_Boundaries_Theme_multiCRS/FeatureServer/8/query", sep = "/")
url$query <- list(where = "lganame = 'BLACKTOWN'",
                  outFields = "lganame, councilname, OBJECTID",
                  returnGeometry = "true",
                  f = "geojson")
request <- build_url(url)

# Request Feature Service and read to a sf object
blacktown_lga <- st_read(request)

# Write blacktown lga to geojson
dir.create(file.path(getwd(), "data"), showWarnings = FALSE) # create data dir if doesn't already exist
st_write(blacktown_lga, "data/blacktown_lga.geojson")

# Convert from geojson to pmtiles to save on file size
system("tippecanoe -z15 -o data/blacktown_lga.pmtiles --drop-densest-as-needed data/blacktown_lga.geojson")

# Delete geojson
file.remove("data/blacktown_lga.geojson")

#gtfs_url <- 'https://opendata.transport.nsw.gov.au/data/dataset/d1f68d4f-b778-44df-9823-cf2fa922e47f/resource/e70b3c19-ed72-48b0-bc66-7054ad04d946/download/prod_fixed_gtfs_2.0.json'

gtfs_url <- 'https://api.transport.nsw.gov.au/v1/publictransport/timetables/complete/gtfs'
  
# Create a request passing in apikey in header (using httr2)
transport_nsw_request <- request(gtfs_url) |> 
  req_method("GET") |>
  req_headers(accept = "application/gzip",
    Authorization = 'apikey YOUR_API_KEY_HERE')

# create data dir if doesn't already exist
dir.create(file.path(getwd(), "data/transport_nsw_gtfs"), showWarnings = FALSE)

# Perform request
req_perform(
  transport_nsw_request,
  path = "data/transport_nsw_gtfs/gtfs.zip")


transport_nsw_gtfs <- read_gtfs("data/transport_nsw_gtfs/gtfs.zip")

nsw_stops <- stops_as_sf(transport_nsw_gtfs$stops)

stops_in_blacktown <- st_filter(nsw_stops, blacktown_lga)


nsw_routes <- shapes_as_sf(transport_nsw_gtfs$shapes)

routes_in_blacktown <- st_filter(nsw_routes, blacktown_lga)


# Write blacktown stops and routes to geojson
st_write(stops_in_blacktown, "data/stops.geojson")
st_write(routes_in_blacktown, "data/routes.geojson")

file.remove("data/transport_nsw_gtfs/gtfs.zip")
unlink("data/transport_nsw_gtfs", recursive = T)


# !--- MAP FOR VISUALIZING DATA/TESTING ---!
maplibre(
  #center = c(150.87447, -33.74384),
  #zoom = 10
  bounds = blacktown_lga
) |>
  add_fullscreen_control() |>
  add_navigation_control(position = "top-left") |>
  add_source(
    id = 'blacktown-lga',
    data = blacktown_lga
  ) |>
  add_line_layer(
    id = 'blacktown-fill',
    source = 'blacktown-lga',
    line_width = 2,
    line_color = "black",
    line_opacity = 0.5,
    line_dasharray = c(4, 2),
    visibility = "visible"
  ) |>
  add_line_layer(
    id = 'blacktown-routes',
    source = routes_in_blacktown,
    line_width = 3,
    line_color = 'orange',
    line_opacity = 0.7
  ) |>
  add_circle_layer(
    id = 'blacktown-stops',
    source = stops_in_blacktown,
    circle_radius = 4,
    circle_color = 'blue'
  ) 
  
