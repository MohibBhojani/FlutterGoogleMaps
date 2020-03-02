import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


import '../helper/location_helper.dart';
import '../models/pin_info.dart';
import '../utils/map_utils.dart';
import '../widgets/map_pin_pill.dart';

const double cameraZoom = 16;
const double cameraTilt = 80;
const double cameraBearing = 30;
const LatLng sourceLocation = LatLng(24.8778814, 67.0193764);
const LatLng destLocation = LatLng(24.8655829, 67.0070275);

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPIKey = GOOGLE_API_KEY;
  BitmapDescriptor sourceIcon;
  BitmapDescriptor destinationIcon;
  double pinPillPosition = -100;
  PinInformation currentlySelectedPin = PinInformation(pinPath: '', avatarPath: '', location: LatLng(0, 0), locationName: '', labelColor: Colors.grey);
  PinInformation sourcePinInfo;
  PinInformation destinationPinInfo;

  @override
  void initState() {
    super.initState();
    setSourceAndDestinationIcons();
  }

  void setMapPins() {
       // source pin
      _markers.add(Marker(
        
      // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId('sourcePin'),
        position: sourceLocation,
        onTap: () {
          setState(() {
            currentlySelectedPin = sourcePinInfo;
            pinPillPosition = 0;
          });
        },
        icon: sourceIcon
      ));

      sourcePinInfo = PinInformation(
        locationName: "Start Location",
        location: sourceLocation,
        pinPath: "assets/driving_pin.png",
        avatarPath: "assets/friend1.jpg",
        labelColor: Colors.blueAccent
      );

      // destination pin
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId('destPin'),
        position: destLocation,
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        icon: destinationIcon
      ));

      destinationPinInfo = PinInformation(
        locationName: "End Location",
        location: destLocation,
        pinPath: "assets/destination_map_marker.png",
        avatarPath: "assets/friend2.jpg",
        labelColor: Colors.purple
      );
    }

  void setSourceAndDestinationIcons() async {
    sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/driving_pin.png');

    destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), 'assets/destination_map_marker.png');
  }

  void onMapCreated(GoogleMapController controller) {
    controller.setMapStyle(MapUtils.mapStyles);
    _controller.complete(controller);

    setMapPins();
    setPolylines();
  }

  @override
  Widget build(BuildContext context) {

    CameraPosition initialLocation = CameraPosition(
      zoom: cameraZoom,
      bearing: cameraBearing,
      tilt: cameraTilt,
      target: sourceLocation
    );

    return Scaffold(
      body: Stack(
          children: <Widget>[
            GoogleMap(
              myLocationEnabled: true,
              compassEnabled: true,
              tiltGesturesEnabled: false,
              markers: _markers,
              polylines: _polylines,
              mapType: MapType.normal,
              initialCameraPosition: initialLocation,
              onMapCreated: onMapCreated,
              onTap: (LatLng location) {
                setState(() {
                  pinPillPosition = -100;
                });
              },
            ),
            MapPinPillComponent(
                pinPillPosition: pinPillPosition,
                currentlySelectedPin: currentlySelectedPin
            )
          ])
    );
  }

  setPolylines() async
  {
    List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(googleAPIKey,
        sourceLocation.latitude, sourceLocation.longitude, 
        destLocation.latitude, destLocation.longitude);
    
    if(result.isNotEmpty){
      result.forEach((PointLatLng point){
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        Polyline polyline = Polyline(
            polylineId: PolylineId("poly"),
            color: Color.fromARGB(255, 40, 122, 198),
            points: polylineCoordinates
        );
        _polylines.add(polyline);
      });
    }
  }
}

