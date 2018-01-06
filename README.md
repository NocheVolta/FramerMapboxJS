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
mapboxJS = require "MapboxJS"
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
* `interactive` _Boolean_ : If  false , no mouse, touch, or keyboard listeners will be attached to the map, so it will not respond to interaction. (default **true**)

\* _Mapbox GL uses longitude, latitude coordinate order (as opposed to latitude, longitude) to match GeoJSON._

## Methods

- `.wrapper` : Returns the layer that contains the map
- `.mapbox` : Returns the Mapbox instance, useful to interact with the API

### Interact with Mapbox API
Read [Mapbox GL JS documentation](https://www.mapbox.com/mapbox-gl-js/api/ ) to learn how to use the API.

Some extra elements require to load other Mapbox JS files, for example if you want to add a search box (geocoder), [this example](https://www.mapbox.com/mapbox-gl-js/example/mapbox-gl-geocoder/) could help you.

#### Add a custom marker and animate it
```coffeescript
# Create the map
myMap = new mapboxJS
    accessToken: 'insertHereYourAccessToken'
    style: 'yourCustomStyleURL'

# Create the maker as a Layer
customMarker = new Layer
    size: 24
    borderRadius: 100
    backgroundColor: 'rgba(29, 200, 200, .60)'

# Insert the marker on the map
marker = new mapboxgl.Marker(customMarker._element) 
  .setLngLat([-3.703, 40.409])
  .addTo(myMap.mapbox)

# CustomMarker animation
scaleUp = new Animation customMarker,
  size: 48
  options:
    time: 1
    curve: 'ease'
scaleDown = scaleUp.reverse()
scaleUp.start()
scaleUp.onAnimationEnd -> scaleDown.start()
scaleDown.onAnimationEnd -> scaleUp.start()
```
### Contact & Credits
You can find me on Twitter [@NocheVolta](https://twitter.com/nochevolta)

Inspirated on [this project](https://github.com/johnmpsherwin/Mapbox-Framer) made by [John Sherwin](https://twitter.com/johnmpsherwin).

This project is not realted with Mapbox company.
