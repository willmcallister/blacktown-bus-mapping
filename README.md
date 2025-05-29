# Blacktown Bus Mapping

[Interactive Map](https://willmcallister.github.io/blacktown-bus-mapping)

This repository was created for GEOS3520 Urban Citizenship and Sustainability at the University of Sydney. It serves as a resource for the practical project wherein as a group, we analyzed public transportation in two suburbs within the Blacktown Local Government Area (LGA). We were allocated Glenwood and Acacia Gardens.

The majority of the work within this repo is within the suburb_routing jupyter notebook (suburb_routing.ipynb). Using OSMNX and NetworkX, I created a walking network from OSM data and used that to create 400m walking buffers from bus stops in near the two suburbs. This is visualized through a Maplibre interactive map, as well as data on a bus stop inventory our group conducted - assessing amenities at each stop (shelter, seat, timetable, advertising). Vite and npm were used to build and deploy the website to github pages. Transport data comes from Transport for NSW.

