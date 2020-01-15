
import 'package:flutter/material.dart';
import 'package:geolocation/providers/location_providers.dart';
import 'package:provider/provider.dart';
import 'package:geolocation/screens/geo_address.dart';
import 'homepage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      builder: (ctx) => ProductProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter GoogleMaps Demo',
        theme: ThemeData(
          primaryColor: Colors.blueAccent,
        ),
        home: HomePage(),
      ),
    );
  }
}







//import 'dart:async';
//
//import 'package:flutter/material.dart';
//import 'package:geolocator/geolocator.dart';
//import 'package:google_maps_flutter/google_maps_flutter.dart';
//
//void main() => runApp(MyApp());
//
//class MyApp extends StatefulWidget {
//  @override
//  _MyAppState createState() => _MyAppState();
//}
//
//class _MyAppState extends State<MyApp> {
//  Completer<GoogleMapController> _controller = Completer();
//  final Map<String, Marker> _markers = {};
//  double lat;
//  double lng;
//
//  static const LatLng _center = const LatLng(45.521563, -122.677433);
//
//  void _onMapCreated(GoogleMapController controller) {
//
//    _controller.complete(controller);
//  }
//
//  void _getLocation() async {
//    var currentLocation = await Geolocator()
//        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
//
//    setState(() {
//      _markers.clear();
//      final marker = Marker(
//        markerId: MarkerId("curr_loc"),
//        position: LatLng(currentLocation.latitude, currentLocation.longitude),
//        infoWindow: InfoWindow(title: 'Your Location'),
//        icon: BitmapDescriptor.defaultMarkerWithHue(
//          BitmapDescriptor.hueViolet,
//        ),
//      );
//      lat = currentLocation.latitude;
//      lng = currentLocation.longitude;
//      _markers["Current Location"] = marker;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return MaterialApp(
//      home: Scaffold(
//        appBar: AppBar(
//          title: Text('Maps Sample App'),
//          backgroundColor: Colors.green[700],
//        ),
//        body: GoogleMap(
//          onMapCreated: _onMapCreated,
//          initialCameraPosition: CameraPosition(
//            target: _center,
//            zoom: 11.0,
//          ),
//          myLocationEnabled: true,
//          markers: _markers.values.toSet(),
//        ),
//        floatingActionButton: FloatingActionButton(
//          onPressed: _getLocation,
//          tooltip: 'Get Location',
//          child: Icon(Icons.navigation),
//        ),
//      ),
//    );
//  }
//
//  Marker gramercyMarker = Marker(
//    markerId: MarkerId("gramercy"),
//    position: LatLng(40.738380, -73.988426),
//    infoWindow: InfoWindow(title: 'Gramercy Tavern'),
//    icon: BitmapDescriptor.defaultMarkerWithHue(
//      BitmapDescriptor.hueViolet,
//    ),
//  );
//
//  Marker bernardinMarker = Marker(
//    markerId: MarkerId('bernardin'),
//    position: LatLng(40.761421, -73.981667),
//    infoWindow: InfoWindow(title: 'Le Bernardin'),
//    icon: BitmapDescriptor.defaultMarkerWithHue(
//      BitmapDescriptor.hueViolet,
//    ),
//  );
//  Marker blueMarker = Marker(
//    markerId: MarkerId('bluehill'),
//    position: LatLng(40.732128, -73.999619),
//    infoWindow: InfoWindow(title: 'Blue Hill'),
//    icon: BitmapDescriptor.defaultMarkerWithHue(
//      BitmapDescriptor.hueViolet,
//    ),
//  );
//
////New York Marker
//
//  Marker newyork1Marker = Marker(
//    markerId: MarkerId('newyork1'),
//    position: LatLng(40.742451, -74.005959),
//    infoWindow: InfoWindow(title: 'Los Tacos'),
//    icon: BitmapDescriptor.defaultMarkerWithHue(
//      BitmapDescriptor.hueViolet,
//    ),
//  );
//  Marker newyork2Marker = Marker(
//    markerId: MarkerId('newyork2'),
//    position: LatLng(40.729640, -73.983510),
//    infoWindow: InfoWindow(title: 'Tree Bistro'),
//    icon: BitmapDescriptor.defaultMarkerWithHue(
//      BitmapDescriptor.hueViolet,
//    ),
//  );
//  Marker newyork3Marker = Marker(
//    markerId: MarkerId('newyork3'),
//    position: LatLng(40.719109, -74.000183),
//    infoWindow: InfoWindow(title: 'Le Coucou'),
//    icon: BitmapDescriptor.defaultMarkerWithHue(
//      BitmapDescriptor.hueViolet,
//    ),
//  );
//
//}