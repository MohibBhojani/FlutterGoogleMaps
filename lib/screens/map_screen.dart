import 'dart:async';
// import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
// import 'package:http/http.dart' as http;

import '../helper/location_helper.dart';
import '../models/pin_info.dart';
import '../utils/map_utils.dart';
import '../widgets/map_pin_pill.dart';

const double cameraZoom = 16;
const double cameraTilt = 0;
const double cameraBearing = 30;
const LatLng sourceLocation = LatLng(24.85085, 67.01778);
const LatLng destLocation = LatLng(24.8657238, 67.0142184);
// final url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${sourceLocation.latitude},${sourceLocation.longitude}&destination=${destLocation.latitude},${destLocation.longitude}&key=$GOOGLE_API_KEY';
// final response =  http.get(url);

// const LatLng destLocation = LatLng(0, 0);

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
// for my drawn routes on the map

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints;
  String googleAPIKey = GOOGLE_API_KEY;
  //set google maps polyline points
  GoogleMapPolyline googleMapPolyline =
      new GoogleMapPolyline(apiKey: GOOGLE_API_KEY);
// for my custom marker pins
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;

  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);
  String duration;
  String direction;
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;

  @override
  void initState() {
    super.initState();

    // create an instance of Location
    location = new Location();
    polylinePoints = PolylinePoints();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    location.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
      updatePinOnMap();
    });
    // set custom marker pins
    setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
  }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/destination_map_marker.png');
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({
      "latitude": destLocation.latitude,
      "longitude": destLocation.longitude
    });
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: cameraZoom,
        tilt: cameraTilt,
        bearing: cameraBearing,
        target: sourceLocation);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: cameraZoom,
          tilt: cameraTilt,
          bearing: cameraBearing);
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Map'),
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
                myLocationEnabled: true,
                compassEnabled: true,
                tiltGesturesEnabled: true,
                markers: _markers,
                polylines: _polylines,
                mapType: MapType.normal,
                initialCameraPosition: initialCameraPosition,
                onTap: (LatLng loc) {
                  pinPillPosition = -100;
                },
                onMapCreated: (GoogleMapController controller) {
                  controller.setMapStyle(MapUtils.mapStyles);
                  _controller.complete(controller);
                  // my map has completed being created;
                  // i'm ready to show the pins on the map
                  showPinsOnMap();
                }),
            MapPinPillComponent(
                pinPillPosition: pinPillPosition,
                currentlySelectedPin: currentlySelectedPin,
                duration: duration,
                direction: direction)
          ],
        ));
  }

  void getDirectionAndDuration(
      double sourLat, double sourLng, double destLat, double destLng) async {
    final result = await LocationHelper.getDirections(
      sourLat,
      sourLng,
      destLat,
      destLng,
    );
    duration = result['routes'][0]['legs'][0]['duration']['text'];
    direction = result['routes'][0]['legs'][0]['steps'][0]['maneuver'];
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
        LatLng(destinationLocation.latitude, destinationLocation.longitude);

    print('Directions: $duration');
    sourcePinInfo = PinInformation(
      locationName: "Your Location",
      location: sourceLocation,
      pinPath: "assets/driving_pin.png",
      avatarPath: "assets/friend1.jpg",
      labelColor: Colors.blueAccent,
    );

    destinationPinInfo = PinInformation(
      locationName: "End Location",
      location: destLocation,
      pinPath: "assets/destination_map_marker.png",
      avatarPath: "assets/friend2.jpg",
      labelColor: Colors.purple,
    );

    // add the initial source location pin
    _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon));
    // destination pin
    _markers.add(Marker(
        markerId: MarkerId('destPin'), 
        position: destPosition,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        icon: destinationIcon));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
    // setPolylines();
    setGooglePolyLines();
  }

  void setGooglePolyLines() async {
    List<LatLng> result = await googleMapPolyline.getCoordinatesWithLocation(
        origin: LatLng(
          currentLocation.latitude,
          currentLocation.longitude,
        ),
        destination: LatLng(
          destinationLocation.latitude,
          destinationLocation.longitude,
        ),
        mode: RouteMode.driving);

    if (result.isNotEmpty) {
      result.forEach((LatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      setState(() {
        _polylines.add(Polyline(
            width: 5, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates));
      });
    }
  }

  void setPolylines() async {
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPIKey,
        currentLocation.latitude,
        currentLocation.longitude,
        destinationLocation.latitude,
        destinationLocation.longitude);

    if (result.isNotEmpty) {
      result.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(Polyline(
            width: 5, // set the width of the polylines
            polylineId: PolylineId("poly"),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates));
      });
    }
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: cameraZoom,
      tilt: cameraTilt,
      bearing: cameraBearing,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      sourcePinInfo.location = pinPosition;

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          onTap: () {
            setState(() {
              currentlySelectedPin = sourcePinInfo;
              pinPillPosition = 0;
              getDirectionAndDuration(
                currentLocation.latitude,
                currentLocation.longitude,
                destLocation.latitude,
                destLocation.longitude,
              );
            });
          },
          position: pinPosition, // updated position
          icon: sourceIcon));
    });
  }
}
