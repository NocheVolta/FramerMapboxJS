mapboxGetDirectionsBaseURL = "https://api.mapbox.com/directions/v5/mapbox/driving/"

# INCLUDE JS and CSS
insertScript = (url) ->
  lib = Utils.domLoadDataSync url
  script = document.createElement "script"
  script.type = "text/javascript"
  script.innerHTML = lib

  head = document.getElementsByTagName("head")[0]
  head.appendChild script

  script

insertCSS = (url) ->
  lib = Utils.domLoadDataSync url
  style = document.createElement "style"
  style.type = "text/css"
  style.innerHTML = lib

  head = document.getElementsByTagName("head")[0]
  head.appendChild style

  style

mapboxCSS_fix = """
.mapboxgl-canvas-container.mapboxgl-interactive,
.mapboxgl-ctrl-nav-compass {
  cursor: inherit;
}
.mapboxgl-canvas-container.mapboxgl-interactive:active,
.mapboxgl-ctrl-nav-compass:active {
  cursor: inherit;
}
"""

insertScript("https://api.tiles.mapbox.com/mapbox-gl-js/v0.44.1/mapbox-gl.js")
insertCSS("https://api.tiles.mapbox.com/mapbox-gl-js/v0.44.1/mapbox-gl.css")
insertScript("https://api.tiles.mapbox.com/mapbox.js/plugins/turf/v2.0.0/turf.min.js")
Utils.insertCSS(mapboxCSS_fix)

# Inspirated on https://github.com/johnmpsherwin/Mapbox-Framer project

# Global variable
accessToken = null

class exports.MapboxJS extends Layer
  @define "wrapper",
    importable: false
    exportable: false
    get: -> @options.mapboxWrapper
  @define "mapbox",
    importable: false
    exportable: false
    get: -> @options.mapbox

  constructor: (@options = {}) ->
    @options.accessToken ?= null
    @options.style ?= 'mapbox://styles/mapbox/streets-v9'
    @options.center ?= [-3.70346, 40.41676]
    @options.zoom ?= 13.9
    @options.size ?= Screen.size
    @options.interactive ?= true
    @options.pitch ?= 0
    @options.bearing ?= 0
    @options.x ?= 0
    @options.y ?= 0
    @options.hash ?= true

    if !@options.accessToken
      print "ERROR: accessToken is required"
      return

    @options.mapboxWrapper = mapboxWrapper = new Layer
      size: @options.size
      name: 'mapboxjs'

    mapboxWrapper.ignoreEvents = false

    accessToken = mapboxgl.accessToken = @options.accessToken

    @options.mapbox =  mapbox = new mapboxgl.Map
      container: mapboxWrapper._element
      style: @options.style
      zoom: @options.zoom
      center: @options.center
      pitch: @options.pitch
      bearing: @options.bearing
      interactive: @options.interactive
      hash: @options.hash

  #method to create 3d style map
  build3d: () ->
    layers = mapbox.getStyle().layers
    labelLayerId = undefined
    i = 0
    while i < layers.length

      if layers[i].type == 'symbol' and layers[i].layout['text-field']
        labelLayerId = layers[i].id
        break
      i++

    mapbox.addLayer({
      'id': '3d-buildings',
      'source': 'composite',
      'source-layer': 'building',
      'filter': ['==', 'extrude', 'true'],
      'type': 'fill-extrusion',
      'minzoom': 15,
      'paint': {
        'fill-extrusion-color': "#aaa",
        'fill-extrusion-height': ['interpolate', ['linear'], ['zoom'], 15, 0, 15.05, ['get', 'height']],
        'fill-extrusion-base': ['interpolate', ['linear'], ['zoom'], 15, 0, 15.05, ['get', 'min_height']],
        'fill-extrusion-opacity': .8
    }
    }, labelLayerId)
    return
  # method to animate map to certain point
  flyTo: (point) =>
    @options.mapbox.flyTo({ center: point })

# Create marker based on a frame in the Design tab
class exports.CustomMarker
  constructor: (options = {}) ->
    _.assign @, options
    options.element._marker = new mapboxgl.Marker(options.element._element).setLngLat(options.lngLat).addTo(options.map)

# Create basic marker
class exports.Marker extends Layer
  constructor: (options = {}) ->
    _.assign @, super options
    @_marker = new mapboxgl.Marker(@_element).setLngLat(options.lngLat).addTo(options.map)

# Paint a route
class exports.PaintRoute
  constructor: (options = {}) ->
    _.assign @, options
    directionRequestUrl = mapboxGetDirectionsBaseURL + options.start[0] + "," + options.start[1] + ";" + options.end[0] + "," + options.end[1] + "?geometries=geojson&access_token=" + accessToken

    if !options.layout then options.layout = {}
    if !options.paint then options.paint = {}

    fetch(directionRequestUrl).then((response) ->
      response.json()
    ).then((json) ->
      route = json.routes[0].geometry
      options.map.addLayer({
        id: options.id,
        type: 'line',
        source: {
          type: 'geojson',
          data: { type: 'Feature', geometry: route }
        },
        layout: options.layout
        paint: options.paint
      })
    )

# Animate marker through a route
exports.animateMarker = (marker, endPoint, stepDistance = 0.1) ->
  currentMarker = marker._marker
  coordinates = currentMarker.getLngLat()
  directionRequestUrl = mapboxGetDirectionsBaseURL + coordinates.lng + "," + coordinates.lat + ";" + endPoint[0] + "," + endPoint[1] + "?geometries=geojson&access_token=" + accessToken

  fetch(directionRequestUrl).then((response) ->
      response.json()
    ).then((json) ->
      route = json.routes[0].geometry
      polyline = turf.linestring(route.coordinates)
      polylineLength = turf.lineDistance(polyline, 'kilometers')
      steps = Math.floor(polylineLength / stepDistance)
      i = 0
      moveMarker = () ->
        if i <= steps
          iPoint = turf.along(polyline, stepDistance * i, 'kilometers')
          currentMarker.setLngLat(iPoint.geometry.coordinates)
          i++
          requestAnimationFrame moveMarker
      moveMarker()
    )
