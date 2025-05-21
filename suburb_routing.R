# Loading Packages
library(osmextract)
library(mapgl)
library(dplyr)
library(sf)

australia_pbf_url <- oe_match('australia')

oe_download(file_url = australia_pbf_url$url, download_directory = "./data")

# Clip pbf to blacktown bounding box
# system("osmconvert data/geofabrik_australia-latest.osm.pbf -b=150.868721,-33.766445,150.974464,-33.692731 -o=data/routing/blacktown_area.osm.pbf")
system("osmconvert data/geofabrik_australia-latest.osm.pbf -b=150.868721,-33.766445,150.974464,-33.692731 --complete-ways -o=blacktown_router/blacktown_area.osm.pbf")


# Visualize pbf
blacktown_area_pbf <- osmextract::oe_read('data/routing/blacktown_area.osm.pbf')

maplibre(bounds = blacktown_area_pbf) |>
  add_line_layer(
    id = "blacktown-streets",
    source = blacktown_area_pbf
  )


# allocate RAM memory to Java **before** loading the {r5r} library
options(java.parameters = "-Xmx4G")

library(r5r)

# build transport network
data_path <- system.file("extdata/poa", package = "r5r")

data_path
r5r_core <- setup_r5(data_path)


r5r_dir <- 'blacktown-router'
r5r_core <- r5r::setup_r5(data_path = r5r_dir, verbose = TRUE)

r5r_core

# load origin/destination points
points <- read.csv(file.path(data_path, "poa_points_of_interest.csv"))

points

ttm <- isochrone(
  r5r_core,
  origins = origins,
  mode = "walk",
  cutoffs = c(5,10,15)
)
head(ttm)

data_path




origins <- read.csv('data/suburb_stops.csv') |>
  dplyr::rename(id = stop_id) |>
  select(id, lat, lon)

r5r_core <- r5r::setup_r5(data_path = "data/routing", verbose = TRUE)

r5r_core

walk_poly <- r5r::isochrone(
  r5r_core,
  origins = origins,
  mode = "walk",
  cutoffs = c(5,10,15),
  sample_size = 1,
  verbose = TRUE
)

