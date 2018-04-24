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
1. Copy `MapboxJS.coffee` file on modules folder inside your Framer project
2. Add this line on the top 
```coffeescript
{MapboxJS, CustomMarker, Marker, animateOnRoute} = require 'MapboxJS'
```

### How to use
Init the map with your `accessToken`, generate it on [Mapbox website](https://www.mapbox.com/help/define-access-token/), it's free. **Without this, the map won't work.**  
```coffeescript
myMap = new mapboxJS
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
- `.buildRoute: (point1, point2, linewidth, linecolor)` : Draws a line route between two points on map, using response from mapbox direction search API
- `.flyTo(point)` : Animates map to new location

#Markers
There are two classes for Markers, one used to create new Framer layer object as marker at certain point, and other one - customMarker is using existing Framer layer to serve as mapbox marker at certain point

#animation
Use animateOnRoute(markerObject, newPoint, distanceStep) function to animate markerObject to newPoint with distanceStep for animation 

### Interact with Mapbox API
Read [Mapbox GL JS documentation](https://www.mapbox.com/mapbox-gl-js/api/ ) to learn how to use the API.

Some extra elements require to load other Mapbox JS files, for example if you want to add a search box (geocoder), [this example](https://www.mapbox.com/mapbox-gl-js/example/mapbox-gl-geocoder/) could help you.

#### Add a marker layer with animation
```coffeescript

#some location point
point1=["-0.118974", "51.531978"]
point2=["-0.089039","51.526553"]

# Create the map
myMap = new mapboxJS
  accessToken: 'insertHereYourAccessToken'
  style: 'yourCustomStyleURL'
  center: point1

# Create the maker as a Layer and put it to certain point on map
simpleMarker=new Marker
  size:20
  point:point2
  borderRadius:50
  backgroundColor:"#ffcc00"

scaleUp = new Animation simpleMarker,
  size: 30
  options:
    time: 1
    curve: 'ease'
scaleUp.start()
scaleDown = scaleUp.reverse()

scaleUp.onAnimationEnd -> scaleDown.start()
scaleDown.onAnimationEnd -> scaleUp.start()

```


#### Add a custom marker  from framer object
```coffeescript

# if u have an object in designtab or in code, pass target name as target attribute to custom marker
customMarker=new CustomMarker
  target:startPoint
  point:point2
```

#### Build direction route between two points
```coffeescript

#using buildRoute method  pass both points, strokeWidth and strokeColor as attribute
myMap.buildRoute(point1, point2, 9, "#ffcc00")

```

#### animate marker to point
```coffeescript

# use animateOnRoute function, pass marker object there, end point, and distance step - in this case 0.01, tweek this number to make animation smooth depending on size of the route between points
animateOnRoute(customMarker, point1, 0.01)

```

#### animate map to certain point
```coffeescript

# use flyTo method and pass end point 
myMap.flyTo(point2)
```

#### create 3D map
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
<a href='https://framer.cloud/FmFdE' target="_blank">Framer prototype</a>

![mapbox gif 2](/mapbox.gif?raw=true)

### Contact & Credits
You can find us on Twitter [@NocheVolta](https://twitter.com/nochevolta), [@mamezito](https://twitter.com/mamezito)

Inspirated on [this project](https://github.com/johnmpsherwin/Mapbox-Framer) made by [John Sherwin](https://twitter.com/johnmpsherwin).

This project is not realted with Mapbox company.
