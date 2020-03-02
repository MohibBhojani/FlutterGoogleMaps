import 'dart:convert';
import 'package:http/http.dart' as http;

const GOOGLE_API_KEY = 'AIzaSyCWVsOvsOyi3sMGxQ--xH_yDLgjiwUuM84';

class LocationHelper {
  static Future<Map> getDirections(double sourceLat, double sourceLng,
      double destLat, double destLng) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$sourceLat,$sourceLng&destination=$destLat,$destLng&key=$GOOGLE_API_KEY';
    final response = await http.get(url);
    Map values = json.decode(response.body);
    // return json.decode(response.body)['routes'][0]['legs'][0]['duration']['text'];
    return values;
    // if (result == null) {
    //   return result = '';
    // } else {
    //   return result;
    // }
  }
}
