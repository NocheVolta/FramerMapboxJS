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

insertScript("https://api.tiles.mapbox.com/mapbox-gl-js/v0.42.2/mapbox-gl.js")
insertScript("https://api.tiles.mapbox.com/mapbox.js/plugins/turf/v2.0.0/turf.min.js")


insertCSS("https://api.tiles.mapbox.com/mapbox-gl-js/v0.42.2/mapbox-gl.css")
Utils.insertCSS(mapboxCSS_fix)

# Inspirated on https://github.com/johnmpsherwin/Mapbox-Framer project




currentMarker=""
stepDistance=0.01
accessToken=""
lineWidth=1
lineColor="#000"
mapbox=""



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

			clearInterval interval

class exports.CustomMarker
	constructor: (options={}) ->
		_.assign @, options
		options.target._marker=new mapboxgl.Marker(options.target._element).setLngLat(options.point).addTo(mapbox)
		
		return options.target
	
		# animateMarker(options.target)	
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
		@options.bearing ?= 0
		@options.hash ?= true
		@options.pitch ?= 0

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
			interactive: @options.interactive
			hash: @options.hash
			bearing: @options.bearing
			pitch: @options.pitch
	flyTo:(point)=>
			@options.mapbox.flyTo({center: point})
	buildRoute: (point1, point2, lW, lC)=>
		# print @options.accessToken
		lineWidth=lW
		lineColor=lC
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
		

