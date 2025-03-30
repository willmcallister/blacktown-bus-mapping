import './style.css'

import * as maplibregl from 'maplibre-gl';
import 'maplibre-gl/dist/maplibre-gl.css';

import * as pmtiles from "pmtiles";

const protocol = new pmtiles.Protocol();
maplibregl.addProtocol("pmtiles", protocol.tile);


const map = new maplibregl.Map({
    container: 'map', // container id
    style: '/data/minimal-style.json', // custom style using openfreeman
    center: [150.87118, -33.74658], // starting position [lng, lat]
    zoom: 10, // starting zoom
    attributionControl: {
        customAttribution: "Transport for NSW"
    }
});

// add zoom and rotate controls
map.addControl(new maplibregl.NavigationControl({
    showZoom: true,
    showCompass: true
}), 'top-left');

// add fullscreen control (defaults to top-right)
map.addControl(new maplibregl.FullscreenControl());

map.on("load", () => {
    map.addSource('routes_vt', {
        type: 'vector',
        url: 'pmtiles://data/routes.pmtiles'
    });
    map.addLayer({
        'id': 'routes',
        'type': 'line',
        'source': 'routes_vt',
        'source-layer': 'routes',
        'paint': {
            'line-color': 'orange',
            'line-width': 2
        }
    });

    map.addSource('blacktown_lga_vt', {
        type: 'vector',
        url: 'pmtiles://data/blacktown_lga.pmtiles'
    });
    map.addLayer({
        'id': 'blacktown-lga-outline',
        'type': 'line',
        'source': 'blacktown_lga_vt',
        'source-layer': 'blacktown_lga',
        'paint': {
            'line-color': 'black',
            'line-width': 4
        }
    });
    
    map.addSource('stops_vt', {
        type: 'vector',
        url: 'pmtiles://data/stops.pmtiles'
    });
    map.addLayer({
        'id': 'stops',
        'type': 'circle',
        'source': 'stops_vt',
        'source-layer': 'stops',
        'paint': {
            'circle-color': 'blue',
            'circle-radius': 6
        }
    });
});
