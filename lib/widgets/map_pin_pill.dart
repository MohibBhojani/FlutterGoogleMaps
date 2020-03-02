import 'package:flutter/material.dart';

import '../models/pin_info.dart';

class MapPinPillComponent extends StatefulWidget {
  final double pinPillPosition;
  final PinInformation currentlySelectedPin;
  final String duration;
  final String direction;

  MapPinPillComponent(
      {this.pinPillPosition,
      this.currentlySelectedPin,
      this.duration,
      this.direction});

  @override
  State<StatefulWidget> createState() => MapPinPillComponentState();
}

class MapPinPillComponentState extends State<MapPinPillComponent> {
  // var result;
  // void getCurrentDirection() async{
  //        String result= await LocationHelper.getDirections(
  //         widget.currentlySelectedPin.location.latitude,
  //         widget.currentlySelectedPin.location.longitude,
  //         widget.currentlySelectedPin.location.latitude,
  //         widget.currentlySelectedPin.location.longitude,
  //       );
  //       result = result;
  //       }

  @override
  Widget build(BuildContext context) {
    // getCurrentDirection();
    // print (result);
    return AnimatedPositioned(
      bottom: widget.pinPillPosition,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(20),
          height: 70,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(50)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 20,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                margin: EdgeInsets.only(left: 10),
                child: ClipOval(
                    child: Image.asset(widget.currentlySelectedPin.avatarPath,
                        fit: BoxFit.cover)),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(widget.currentlySelectedPin.locationName,
                          style: TextStyle(
                              color: widget.currentlySelectedPin.labelColor,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                          'Lat: ${widget.currentlySelectedPin.location.latitude.toStringAsFixed(5)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text(
                          'Lng: ${widget.currentlySelectedPin.location.longitude.toStringAsFixed(5)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Text('Dir: ${widget.direction}',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Column(children: <Widget>[
                      Icon(
                        Icons.timer,
                        semanticLabel: 'Duration',
                      ),
                      SizedBox(height: 2),
                      // if(widget.duration != null)
                      Text(
                        '${widget.duration}',
                        style: TextStyle(fontSize: 10),
                      ),
                    ]),
                  ),
                  Image.asset(widget.currentlySelectedPin.pinPath,
                      width: 50, height: 50),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
