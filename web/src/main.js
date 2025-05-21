import './style.css'

import * as maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';


import * as pmtiles from "pmtiles";

const protocol = new pmtiles.Protocol();
maplibregl.addProtocol("pmtiles", protocol.tile);


const map = new maplibregl.Map({
    container: 'map', // container id
    style: 'data/minimal-style.json', // custom style using openfreemap
    center: [150.925, -33.738], // starting position [lng, lat]
    zoom: 13, // starting zoom
    attributionControl: {
        customAttribution: "Transport for NSW"
    }
});

// add zoom and rotate controls
map.addControl(new maplibregl.NavigationControl({
    showZoom: true,
    showCompass: true
}), 'top-right');

// add fullscreen control (defaults to top-right)
map.addControl(new maplibregl.FullscreenControl());

map.on("load", () => {
    /*
    map.addSource('walkshed_400m_source', {
        type: 'geojson',
        data: 'data/walkshed_400m_new.geojson'
    });
    map.addLayer({
        'id': 'walksheds_400m',
        'type': 'fill',
        'source': 'walkshed_400m_source',
        'paint': {
            'fill-color': 'gray',
            'fill-opacity': 0.7,
        }
    });
    */

    map.addSource('suburbs_source', {
        type: 'geojson',
        data: 'data/suburbs.geojson'
    });
    map.addLayer({
        'id': 'suburbs',
        'type': 'line',
        'source': 'suburbs_source',
        'paint': {
            'line-color': 'black',
            'line-width': 3,
            'line-opacity': 0.7
        }
    });
    
    /*
    map.addSource('suburb_stops_source', {
        type: 'geojson',
        data: 'data/bus_stops.geojson'
    });
    map.addLayer({
        'id': 'suburb_stops',
        'type': 'circle',
        'source': 'suburb_stops_source',
        // 'source-layer': 'suburb_stops',
        'paint': {
            'circle-color': 'blue',
            'circle-radius': 4
        }
    });
    */

    map.addSource('stop_inventory_source', {
        type: 'geojson',
        data: 'data/bus_stop_inventory.geojson'
    });
    map.addLayer({
        'id': 'stop_inventory',
        'type': 'circle',
        'source': 'stop_inventory_source',
        'paint': {
            'circle-color': [
                "match",
                ["get", "num_amenities"],
                0, "#edf8e9",
                1, "#bae4b3",
                2, "#74c476",
                3, "#31a354",
                4, "#006d2c",
                "#000" // default
            ],
            'circle-radius': 6,
            "circle-stroke-width": 1,
            "circle-stroke-color": "#555"
        }
    });

    /* ---- for hover popup ----
    // Create a popup, but don't add it to the map yet.
    const popup = new maplibregl.Popup({
        closeButton: false,
        closeOnClick: false
    });
    
    // Make sure to detect marker change for overlapping markers
    // and use mousemove instead of mouseenter event
    let currentFeatureCoordinates = undefined;
    map.on('mousemove', 'suburb_stops', (e) => {
        
        map.setFilter('walksheds_400m', ['==', ['get', 'stop_id'], e.features[0].properties.stop_id]);

        const featureCoordinates = e.features[0].geometry.coordinates.toString();
        if (currentFeatureCoordinates !== featureCoordinates) {
            currentFeatureCoordinates = featureCoordinates;

            // Change the cursor style as a UI indicator.
            map.getCanvas().style.cursor = 'pointer';

            const coordinates = e.features[0].geometry.coordinates.slice();
            const description = e.features[0].properties.stop_id;

            // Ensure that if the map is zoomed out such that multiple
            // copies of the feature are visible, the popup appears
            // over the copy being pointed to.
            while (Math.abs(e.lngLat.lng - coordinates[0]) > 180) {
                coordinates[0] += e.lngLat.lng > coordinates[0] ? 360 : -360;
            }

            // Populate the popup and set its coordinates
            // based on the feature found.
            popup.setLngLat(coordinates).setHTML(description).addTo(map);
        }
    });

    map.on('mouseleave', 'suburb_stops', () => {
        currentFeatureCoordinates = undefined;
        map.getCanvas().style.cursor = '';
        popup.remove();

        map.setFilter('walksheds_400m', null);
    });
    */
});

function setupFilter() {
    const filterContainer = document.getElementById('filter-container');
    const suburbFilter = document.createElement("select");

    const dropdownOptions = ['Both', 'Glenwood', 'Acacia Gardens'];

    for(const o of dropdownOptions){
        const option = document.createElement('option');
        option.innerText = o;
        option.value = o;
        suburbFilter.appendChild(option);
    }

    filterContainer.appendChild(suburbFilter);

    suburbFilter.onchange = () => {
        filterLayers(suburbFilter.value);
    }

    return;
}

function filterLayers(choice) {
    // filter bus stops and suburbs
    if(choice == 'Both') {
        // reset filter for both layers
        // map.setFilter('suburb_stops', null);
        map.setFilter('stop_inventory', null);
        map.setFilter('suburbs', null);
    }
    else {
        // map.setFilter('suburb_stops', ['==', ['get', 'suburb_name'], choice]);
        map.setFilter('stop_inventory', ['==', ['get', 'suburb'], choice]);
        map.setFilter('suburbs', ['==', ['get', 'name'], choice]);
    }

    return;
}

function createLegend() {
    const legendContainer = document.createElement("div");
    legendContainer.className = "legend";

    const legendTitle = document.createElement("h4");
    legendTitle.innerText = "Number of Stop Amenities"
    legendContainer.appendChild(legendTitle);
    
    const amenity_colors = ["#edf8e9", "#bae4b3", "#74c476", "#31a354", "#006d2c"];

    // create an entry for 0-4 amenities (5 classes)
    amenity_colors.forEach((color, indx) => {
        const div = document.createElement("div");
        const span = document.createElement("span");
        span.style = `background-color: ${color}`;
        div.appendChild(span);

        const label = document.createElement("p");
        label.innerText += indx;
        label.className = "legend-label";
        div.appendChild(label);

        legendContainer.appendChild(div);
    });

    document.getElementById("map").appendChild(legendContainer);

    return;
}


setupFilter();
createLegend();