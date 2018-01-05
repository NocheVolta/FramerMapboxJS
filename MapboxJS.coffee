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
insertCSS("https://api.tiles.mapbox.com/mapbox-gl-js/v0.42.2/mapbox-gl.css")
Utils.insertCSS(mapboxCSS_fix)

# Inspirated on https://github.com/johnmpsherwin/Mapbox-Framer project
class MapboxJS extends Layer
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

		if !@options.accessToken
			print "ERROR: accessToken is required"
			return

		@options.mapboxWrapper = mapboxWrapper = new Layer
			size: @options.size
			name: 'mapboxjs'

		mapboxWrapper.ignoreEvents = false

		mapboxgl.accessToken = @options.accessToken

		@options.mapbox =  mapbox = new mapboxgl.Map
			container: mapboxWrapper._element
			style: @options.style
			zoom: @options.zoom
			center: @options.center
			interactive: @options.interactive

module.exports = MapboxJS
