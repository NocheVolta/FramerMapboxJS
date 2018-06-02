# Mapbox Framer Module
[![license](https://img.shields.io/github/license/bpxl-labs/RemoteLayer.svg)](https://opensource.org/licenses/MIT)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)
![Maintenance](https://img.shields.io/maintenance/yes/2018.svg)

Simplest way to integrate Mapbox maps on your prototypes; you can define size, zoom, center point and even it lets you to use the full API. Obviously you need an active internet connection to load the maps.

![mapbox gif](/mapboxjs.gif?raw=true)

### Installation
<a href='https://open.framermodules.com/Mapbox%20JS'>
  <img alt='Install with Framer Modules'
  src='https://www.framermodules.com/assets/badge@2x.png' width='160' height='40' />
</a>

#### Manual
1. Copy the `MapboxJS.coffee` file to the ‘modules’ folder inside your Framer project
2. Add this line on the top 
```coffeescript
{MapboxJS, CustomMarker, Marker, animateMarker} = require 'MapboxJS'
```

### How to use
Init the map with your `accessToken`, generate it on [Mapbox website](https://www.mapbox.com/help/define-access-token/), it's free. **Without this, the map won't work.**  
```coffeescript
myMap = new MapboxJS
  accessToken: 'insertHereYourAccessToken'
```
### Customization
* `style` _String_ : The map's style url. (default **mapbox://styles/mapbox/streets-v9**)
* `center` _Array_ : The inital geographical centerpoint of the map. (default **[-3.703, 40.409]**, is Madrid) \*
* `zoom` _Integer_ : The initial zoom level of the map. (default **13.9**)
* `size` _Integer or Object_ : Size of the map, set width and height using **{ width:640, height: 480 }** or use a single number to create a square. (default **Screen.size**)
* `pitch` _Integer_ : The initial pitch (tilt) of the map, measured in degrees away from the plane of the screen (0-60).
* `bearing` _Integer_ : The initial bearing (rotation) of the map, measured in degrees counter-clockwise from north.
* `x` : Initial X position (default 0)
* `y` : Initial Y position (default 0)
* `interactive` _Boolean_ : If  false , no mouse, touch, or keyboard listeners will be attached to the map, so it will not respond to interaction. (default **true**)

\* _Mapbox GL uses longitude, latitude coordinate order (as opposed to latitude, longitude) to match GeoJSON._

## Methods

- `.wrapper` : Returns the layer that contains the map
- `.mapbox` : Returns the Mapbox instance, useful to interact with the API
- `.flyTo(point)` : Animates map to new location

### Interact with Mapbox API
Read [Mapbox GL JS documentation](https://www.mapbox.com/mapbox-gl-js/api/ ) to learn how to use the API.

Some extra elements require to load other Mapbox JS files, for example if you want to add a search box (geocoder), [this example](https://www.mapbox.com/mapbox-gl-js/example/mapbox-gl-geocoder/) could help you.

### Add a marker with animation
```coffeescript
# Latitude and Longitude points
centerPoint = [-3.70346, 40.41676]
startPoint = [-3.70773, 40.42135]
endPoint = [-3.702478, 40.41705]

# Create the map
myMap = new mapboxJS
  accessToken: 'insertHereYourAccessToken'
  style: 'yourCustomStyleURL'
  center: centerPoint

# Create a maker using the Layer's attributes and put it into the map
simpleMarker = new Marker
  map: myMap.mapbox
  lngLat: endPoint
  size: 20
  borderRadius: 40
  backgroundColor: "#FF0000"

scaleUp = new Animation simpleMarker,
  size: 30
  options: time: 1, curve: Bezier.ease
scaleUp.start()
scaleDown = scaleUp.reverse()

scaleUp.onAnimationEnd -> scaleDown.start()
scaleDown.onAnimationEnd -> scaleUp.start()

```

### Add a marker from the Desige tab
```coffeescript
customMarker = new CustomMarker
  map: myMap.mapbox
  lngLat: startPoint
  element: targetName # Target must be a frame
```

### Paint route between two points
```coffeescript
route = new PaintRoute
  id: 'route-1' # Must be a unique name
  map: myMap.mapbox
  start: startPoint
  end: endPoint
  layout: { 'line-cap': 'round' }
  paint: { 'line-width': 2, 'line-color': '#FF0000', "line-dasharray": [1, 2, 0]}
```
Read more about now to use the [`layout` and `paint` properties](https://www.mapbox.com/mapbox-gl-js/style-spec#layers-line).

### Animate marker through a route
```coffeescript
animateMarker(customMarker, endPoint, 0.01)
```

### Animate map to certain point
```coffeescript
myMap.flyTo(endPoint)
```

### Create 3D map
```coffeescript

# use build3D method on mapobject load, mind that  bearing, hash and pitch should be set at mapbox initialization
myMap = new MapboxJS
  accessToken: mapboxToken	
  style: styles.light
  zoom: 12
  center: originPoint
  pitch: 45,
  bearing: -17.6,
  hash: true
myMap.mapbox.on 'load', ->
  myMap.build3d()
```

### Sample project
[Framer prototype](https://framer.cloud/FmFdE)

![mapbox gif 2](/mapbox.gif?raw=true)

### Contact & Credits
You can find us on Twitter [@NocheVolta](https://twitter.com/nochevolta), [@mamezito](https://twitter.com/mamezito)

Inspirated on [this project](https://github.com/johnmpsherwin/Mapbox-Framer) made by [John Sherwin](https://twitter.com/johnmpsherwin).

This project is not realted to the Mapbox company.
