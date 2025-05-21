# Libraries
library(dplyr)
library(sf)
library(httr2)
library(tidytransit)
library(mapgl)

setwd("/Users/will/Documents/Github/blacktown-bus-mapping")

# ----- Download LGA Boundaries from NSW Spatial Data Portal -----
# Build query URL
url <- httr2::url_parse("https://portal.spatial.nsw.gov.au/server/rest/services")
url$path <- paste(url$path, "NSW_Administrative_Boundaries_Theme_multiCRS/FeatureServer/8/query", sep = "/")
url$query <- list(where = "lganame = 'BLACKTOWN'",
                  outFields = "lganame, councilname, OBJECTID",
                  returnGeometry = "true",
                  f = "geojson")
lga_request <- httr2::url_build(url)


url <- httr2::url_parse("https://portal.spatial.nsw.gov.au/server/rest/services")
url$path <- paste(url$path, "NSW_Administrative_Boundaries_Theme_multiCRS/FeatureServer/2/query", sep = "/")
url$query <- list(where = "suburbname IN ('GLENWOOD', 'ACACIA GARDENS')",
                  outFields = "suburbname, postcode, OBJECTID",
                  returnGeometry = "true",
                  f = "geojson")
suburb_request <- httr2::url_build(url)


# Request Feature Services and read to sf objects
blacktown_lga <- st_read(lga_request)
suburbs <- st_read(suburb_request)

# Rename fields
blacktown_lga <- blacktown_lga |>
  rename(
    name = lganame,
    id = OBJECTID
  ) |>
  select(id, name, councilname)

suburbs <- suburbs |>
  rename(
    name = suburbname,
    id = OBJECTID
    ) |>
  select(id, name, postcode)

# Write SFs to geojson
dir.create(file.path(getwd(), "data"), showWarnings = FALSE) # create data dir if doesn't already exist
st_write(blacktown_lga, "data/blacktown_lga.geojson")
st_write(suburbs, "data/suburbs.geojson")



# Convert from geojson to pmtiles to save on file size
system("tippecanoe -z15 -o data/blacktown_lga.pmtiles --drop-densest-as-needed data/blacktown_lga.geojson")







nsw_stops <- stops_as_sf(transport_nsw_gtfs$stops)

stops_in_blacktown <- st_filter(nsw_stops, blacktown_lga)


nsw_routes <- shapes_as_sf(transport_nsw_gtfs$shapes)

routes_in_blacktown <- st_filter(nsw_routes, blacktown_lga)


# Write blacktown stops and routes to geojson
st_write(stops_in_blacktown, "data/stops.geojson")
st_write(routes_in_blacktown, "data/routes.geojson")

# Delete GTFS .zip file
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
  
