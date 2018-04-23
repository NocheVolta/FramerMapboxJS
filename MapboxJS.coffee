#includes of httprequests with crossproxy
{ HTTPRequest } = require "mapbox-js/HTTPRequest"
exports.HTTPRequest=HTTPRequest
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

# predefined variables to use later on
currentMarker=""
accessToken=""
mapbox=""

#predefined route stroke attributes
lineWidth=1
lineColor="#000"


#default step distance when animating markers along the route
stepDistance=0.01






#function to animate marker from current location to newpoint location with distance step it will be jumping each 0.01 secod
exports.animateOnRoute=(marker, newPoint, step)->
	currentMarker=marker._marker
	coordinates=currentMarker.getLngLat()
	stepDistance=step
	directionRequestUrl="https://api.mapbox.com/directions/v5/mapbox/driving/"+coordinates.lng+","+coordinates.lat+";"+newPoint[0]+","+newPoint[1]+"?geometries=geojson&access_token="+accessToken
		
	HTTPRequest(directionRequestUrl,  animateLocation)


animateLocation=(response)->
	route =response.routes[0].geometry
	iPath = turf.linestring(route.coordinates)
	iPathLength = turf.lineDistance(iPath, 'miles')
	steps=Math.floor(iPathLength/stepDistance)
	i=0
	interval = Utils.interval 0.01, ->
		if i!=steps
			iPoint = turf.along(iPath, stepDistance*i, 'miles')	
			currentMarker.setLngLat(iPoint.geometry.coordinates)
			i++
		else
			#if needed u can embed function that will fire when marker will reach end point
			clearInterval interval


#customMarker based on Framer design layer
class exports.CustomMarker
	constructor: (options={}) ->
		_.assign @, options
		options.target._marker=new mapboxgl.Marker(options.target._element).setLngLat(options.point).addTo(mapbox)
		
		return options.target
	
#layer based marker
class exports.Marker extends Layer
	constructor: (options={}) ->
		_.assign @, super options
		@_marker=new mapboxgl.Marker(@_element).setLngLat(options.point).addTo(mapbox)
		


		

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
		@options.center ?= [-3.703, 40.409]
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

		accessToken=mapboxgl.accessToken = @options.accessToken

		@options.mapbox =  mapbox = new mapboxgl.Map
			container: mapboxWrapper._element
			style: @options.style
			zoom: @options.zoom
			center: @options.center
			pitch: @options.pitch
			bearing: @options.bearing
			interactive: @options.interactive
			hash: @options.hash
			bearing: @options.bearing
			pitch: @options.pitch

	#method to create 3d style map
	build3d:()=>	
			layers = mapbox.getStyle().layers
			labelLayerId = undefined
			i = 0
			while i < layers.length

				if layers[i].type == 'symbol' and layers[i].layout['text-field']
					labelLayerId = layers[i].id 
					break
				i++
			#   color=Utils.randomColor().toHexString()
			
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
			}, labelLayerId);
			return
	# method to animate map to certain point
	flyTo:(point)=>
			@options.mapbox.flyTo({center: point})

	#method to create route between 2 points with certain linewidth and linecolor
	buildRoute: (point1, point2, linewidth, linecolor)=>
		# print @options.accessToken
		lineWidth = linewidth
		lineColor = linecolor
		directionRequestUrl="https://api.mapbox.com/directions/v5/mapbox/driving/"+point1[0]+","+point1[1]+";"+point2[0]+","+point2[1]+"?geometries=geojson&access_token="+@options.accessToken
		
		HTTPRequest(directionRequestUrl,  drawRoute)



drawRoute=(response)->
	route=response.routes[0].geometry
	# if previous route exist - delete route
	if mapbox.getLayer("route")
		mapbox.removeSource("route")
		mapbox.removeLayer("route")
		
	mapbox.addLayer({
		id: 'route',
		type: 'line',
		source: {
			type: 'geojson',
			data: {
			type: 'Feature',
			geometry: route
				}
			},
		paint: {
		'line-width': lineWidth,
		"line-color": lineColor
		}
		})
		

