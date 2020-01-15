import 'dart:async';
//import 'package:expandable_app_bottom_bar/expandable_bottom_bar.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geolocation/providers/location_providers.dart';
import 'package:geolocation/second.dart';
import 'package:geolocation/widgets/app_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:sqflite/sqlite_api.dart';

import 'localdb/location_helper.dart';
import 'localdb/location_model.dart';
import 'models/location_model.dart';
import 'package:geolocation/utils/shared_pref_helper.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool mapToggle = false;
  var currentLocation;
  double lat;
  double lng;
  GoogleMapController mapController;
  Set<Marker> markers = Set();

  //Map<MarkerId, Marker> markersList = <MarkerId, Marker>{};
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Todo> todoList;

  List<Marker> markers1 = <Marker>[];

  static double _minHeight = 80, _maxHeight = 600;
  Offset _offset = Offset(0, _minHeight);
  bool _isOpen = false;

  String searchAddr;

  String _message = '';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _register() {
    _firebaseMessaging.getToken().then((token) => print("token is: "+token));
  }

  static SharedPrefHelper shHelper = SharedPrefHelper();

  _getSharedValue() async{
    shHelper.saveData(10);
    print("Shared value is: ${await shHelper.getData()}");
    List<int> intList =[12,55,54];
    shHelper.saveList(intList);
    shHelper.getList();
  }

  static BuildContext ctx;
  static Position _currentPosition;
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  void getMessage(){
    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          setState(() => _message = message["notification"]["title"]);
        }, onResume: (Map<String, dynamic> message) async {
      print('on resume $message');
      setState(() => _message = message["notification"]["title"]);
    }, onLaunch: (Map<String, dynamic> message) async {
      print('on launch $message');
      setState(() => _message = message["notification"]["title"]);
    });
  }

  @override
  void initState() {
    super.initState();
    getMessage();
    _register();
    Future.delayed(Duration.zero).then((_){
      Provider.of<ProductProvider>(context).fetch();
    });
    Geolocator().getCurrentPosition().then((currLoc){
      setState(() {
        currentLocation = currLoc;
        mapToggle = true;
        _getCurrentLocation();
      });
    });
  }
  double zoomVal=5.0;
  @override
  Widget build(BuildContext context) {

    _getSharedValue();

    if (todoList == null) {
      todoList = List<Todo>();
      updateListView();
    }
    //FocusScope.of(context).requestFocus(new FocusNode());//Hide the keyboard
    //Background Geolocation
//    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
//      print('[motionchange] - $location');
//    });
    bg.BackgroundGeolocation.ready(bg.Config(
      desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
      distanceFilter: 10,
      startOnBoot: true,

    )).then((bg.State state){
      print('[ready] success: ${state}');
    });
    ctx = context;
    return Scaffold(
      appBar: AppBar(
//        leading: IconButton(
//            icon: Icon(FontAwesomeIcons.arrowLeft),
//            onPressed: () {
//              //
//            }),
        title: Text("Visakhapatnam",style: TextStyle(
          color: Colors.white,
        ),),
        actions: <Widget>[
//          IconButton(
//              icon: Icon(FontAwesomeIcons.search),
//              onPressed: () {
//                //
//              }),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[

          Expanded(child:
             _buildGoogleMap(context),flex: 5,
          ),
          //Expanded(child:
          //_bottomBar(context),flex: 1,
          //),


          //_buildGoogleMap(context),
          //_bottomBar(context)
          //_mapLoaded(context,mapToggle,currentLocation.longitude,currentLocation.latitude)
          //_zoomminusfunction(),
          //_zoomplusfunction(),
          //_buildContainer(),


        ],
      ),
    );
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Todo>> todoListFuture = databaseHelper.getTodoList();
      todoListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
          for(int i=0;i<todoList.length;i++){
            print("okkkk"+todoList[i].title);
          }
        });
      });
    });
  }

  void _handleClick() {
    _isOpen = !_isOpen;
    Timer.periodic(Duration(milliseconds: 5), (timer) {
      if (_isOpen) {
        double value = _offset.dy + 10; // we increment the height of the Container by 10 every 5ms
        _offset = Offset(0, value);
        if (_offset.dy > _maxHeight) {
          _offset = Offset(0, _maxHeight); // makes sure it does't go above maxHeight
          timer.cancel();
        }
      } else {
        double value = _offset.dy - 10; // we decrement the height by 10 here
        _offset = Offset(0, value);
        if (_offset.dy < _minHeight) {
          _offset = Offset(0, _minHeight); // makes sure it doesn't go beyond minHeight
          timer.cancel();
        }
      }
      setState(() {});
    });
  }

  Widget _bottomBar(BuildContext context){
    return Scaffold(
      backgroundColor: Color(0xFFF6F6F6),
      appBar: AppBar(backgroundColor: Color(0xFFF6F6F6), elevation: 0),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: FlatButton(
              onPressed: _handleClick,
              splashColor: Colors.transparent,
              textColor: Colors.grey,
              child: Text(_isOpen ? "Back" : ""),
            ),
          ),
          //Align(child: FlutterLogo(size: 300)),
          GestureDetector(
            onPanUpdate: (details) {
              _offset = Offset(0, _offset.dy - details.delta.dy);
              if (_offset.dy < HomePageState._minHeight) {
                _offset = Offset(0, HomePageState._minHeight);
                _isOpen = false;
              } else if (_offset.dy > HomePageState._maxHeight) {
                _offset = Offset(0, HomePageState._maxHeight);
                _isOpen = true;
              }
              setState(() {});
            },
            child: AnimatedContainer(
              duration: Duration.zero,
              curve: Curves.easeOut,
              height: _offset.dy,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 5, blurRadius: 10)]),
              child: Text("Bottom sheet"),
            ),
          ),
//          Positioned(
//            bottom: 2 * HomePageState._minHeight - _offset.dy - 28, // 56 is the height of FAB so we use here half of it.
//            child: FloatingActionButton(
//              child: Icon(_isOpen ? Icons.keyboard_arrow_down : Icons.add),
//              onPressed: _handleClick,
//            ),
//          ),
        ],
      ),
    );
  }

  Widget _buildGoogleMap(BuildContext context) {

      final productsData = Provider.of<ProductProvider>(context);
      final products = productsData.items;
      for(int i=0;i<products.length;i++){
        print(products[i].latitude+" "+products[i].longitude);
        setState(() {
          markers1.add(Marker(
            markerId: MarkerId(products[i].id),
            infoWindow: InfoWindow(
                title: "Test",
                snippet: "Long Testing"),
                position: LatLng(double.parse(products[i].latitude),
                double.parse(products[i].longitude)),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ));
        });
      }
      print(markers1.toString());
      print(markers.toString());

    return Scaffold(
      //debugShowCheckedModeBanner: false,
      //home: Scaffold(

        body: Stack(children: <Widget>[
        GoogleMap(
        onMapCreated: onMapCreated,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(17.6868, 83.2185), zoom: 12,
          ),
          myLocationEnabled: true,
          //markers: //init()
          markers: Set<Marker>.of(markers1),
                  //{newyork1Marker,newyork2Marker,newyork3Marker,gramercyMarker,bernardinMarker,blueMarker,currentLoc}
         ),

          Align(
            alignment: Alignment.bottomRight,
            child: Padding(padding: EdgeInsets.only(bottom: 85,right: 15),
             child: FloatingActionButton(
                 onPressed: _getCurrentLocation,
               child: Icon(Icons.navigation),
             ),
            ),
          ),

          Positioned(
            top: 5.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              height: 50.0,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0), color: Colors.white),
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'Enter Address',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                    suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: searchandNavigate,
                        iconSize: 30.0)
                ),
                onChanged: (val) {
                  setState(() {
                    searchAddr = val;
                  });
                },
              ),
            ),
          ),
          Positioned(
              child: SlidingUpPanel(
                   minHeight: 80,
                   borderRadius: BorderRadius.only(
                     topLeft: Radius.circular(15),
                     topRight: Radius.circular(15),
                    ),
                   boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 5, blurRadius: 10)],
                collapsed: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        'Add/select a business',
                        textScaleFactor: 1.5,
                      ),
                      RaisedButton(
                        textColor: Colors.white,
                        color: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(3.0)),
                        child: Text(
                          'Add/select a business',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            shHelper.saveData(10);
                            debugPrint("Save button clicked");
                          });
                        },
                      ),
                    ],
                ),
                panel: Center(
                child: Text("This is the sliding Widget"),
                ),
                //body: (

                //),
              ),
             ),
           ],
          ),
//      floatingActionButton: Padding(
//        padding: const EdgeInsets.only(bottom: 70.0),
//        child: FloatingActionButton(
//          child: Icon(Icons.navigation),
//          onPressed: _getCurrentLocation,
//        ),
//      ),

  );

      //Todo ExpandableNotifier
//      bottomNavigationBar: ExpandableNotifier(
//
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: [
//            ExpandableButton(
//              child: AnimatedContainer(
//              duration: Duration.zero,
//              curve: Curves.easeOut,
//              height: 65,
//              alignment: Alignment.center,
//              decoration: BoxDecoration(
//                color: Colors.white,
//                borderRadius: BorderRadius.only(
//                  topLeft: Radius.circular(10),
//                  topRight: Radius.circular(10),
//              ),
//              boxShadow: [BoxShadow(spreadRadius: 1, blurRadius: 10)]),
//              child: Text("Bottom sheet"),
//              ),
//          ),
//
//         ScrollOnExpand(child:
//            Expandable(
//            expanded: _showBottombarExpandable(context),
//             )
//          ),
//            Expandable(
//              expanded: _showBottombarExpandable(context),
//            ),
//          ],
//        ),
//      ),




//    bottomNavigationBar: ExpandableBottomBar(
//           autoHide: true,
//           stopOnDrag: false,
//           //child: SomeImage(),
//           color: Colors.green,
//           barButtons: Container(
//           color: Colors.pink,
//           child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
//              FlatButton(
//                 onPressed: () {
//                 print('onPressed <-');
//               },
//            child: Icon(Icons.arrow_back),
//          );
//          FlatButton(
//            child: Icon(Icons.arrow_forward),
//            onPressed: () {
//               print('onPressed ->');
//             },
//          )
//        ],
//       )
//      )
//     )
  }

  Widget _showBottombarExpandable(BuildContext context) {
    return Container(
        color: Colors.grey[200],
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          RadioListTile(dense: true, title: Text('Test'), groupValue: 'test', onChanged: (value) {}, value: true),
          RadioListTile(dense: true, title: Text('Test'), groupValue: 'test', onChanged: (value) {}, value: true),
        ])
    );
  }

  void onMapCreated(controller) {
    setState(() {
      mapController = controller;
    });
  }

  searchandNavigate() {
    Geolocator().placemarkFromAddress(searchAddr).then((result) {
      mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target:
          LatLng(result[0].position.latitude, result[0].position.longitude),
          zoom: 10.0)));
    });
  }


  Widget _mapLoaded (BuildContext context , bool mapToggle,double lat,double lng){
    return Column(children: <Widget>[
       Stack(children: <Widget>[
         Container(
           child: mapToggle ?
           GoogleMap(
             onMapCreated: (GoogleMapController controller) {
               _controller.complete(controller);
             },
             initialCameraPosition: CameraPosition(
                 target: LatLng(lat, lng)),
             mapType: MapType.normal,
           ):
              Center(
                child: Text('Please wait...',
                style: TextStyle(
                  fontSize: 20,
                ),),
              )
         )
        ],
       )
      ],
    );
  }

  static double l;
  static double j;
  Future<void> _goToTheLake(double l,double j) async {

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
        LatLng(l, j),
        zoom: 14.0)));
  }

  Future<Null> _gotoLocation(double lat,double long) async {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
        LatLng(lat, lng),
        zoom: 10.0)));

  }

  void _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        l=_currentPosition.latitude;
        j=_currentPosition.longitude;
        setState(() {
          //_gotoLocation(l,j);
          _goToTheLake(l,j);
        });
      });
    }).catchError((e) {
      print(e);
    });
  }

   static goTo(String name,String desc) async{
     Data data = new Data();
     data.text=name;
     data.dateTime=desc;
    Navigator.push(
      ctx,
      MaterialPageRoute(builder: (context) => Second(data:data)),
    );
  }

  initMarker(LocationModel locationModel){
    List<Marker> marker = [];
    marker.add(Marker(
        markerId: MarkerId('bernardin'),
        position: LatLng(double.parse(locationModel.latitude), double.parse(locationModel.longitude)),
      infoWindow: InfoWindow(title: 'Le Bernardin',snippet: 'Here is an Info Window Text on a Google Map',onTap: (){
        goTo('Le Bernardin','Here is an Info Window Text on a Google Map');
      }),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      ),
    ));

//      Widget _zoomminusfunction() {
//
//    return Align(
//      alignment: Alignment.topLeft,
//      child: IconButton(
//          icon: Icon(FontAwesomeIcons.searchMinus,color:Color(0xff6200ee)),
//          onPressed: () {
//            zoomVal--;
//            _minus( zoomVal);
//          }),
//    );
//  }
//  Widget _zoomplusfunction() {
//
//    return Align(
//      alignment: Alignment.topRight,
//      child: IconButton(
//          icon: Icon(FontAwesomeIcons.searchPlus,color:Color(0xff6200ee)),
//          onPressed: () {
//            zoomVal++;
//            _plus(zoomVal);
//          }),
//    );
//  }
//
//  Future<void> _minus(double zoomVal) async {
//    final GoogleMapController controller = await _controller.future;
//    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(40.712776, -74.005974), zoom: zoomVal)));
//  }
//  Future<void> _plus(double zoomVal) async {
//    final GoogleMapController controller = await _controller.future;
//    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(40.712776, -74.005974), zoom: zoomVal)));
//  }


//  Widget _buildContainer() {
//    return Align(
//      alignment: Alignment.bottomLeft,
//      child: Container(
//        margin: EdgeInsets.symmetric(vertical: 20.0),
//        height: 150.0,
//        child: ListView(
//          scrollDirection: Axis.horizontal,
//          children: <Widget>[
//            SizedBox(width: 10.0),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: _boxes(
//                  "https://lh5.googleusercontent.com/p/AF1QipO3VPL9m-b355xWeg4MXmOQTauFAEkavSluTtJU=w225-h160-k-no",
//                  40.738380, -73.988426,"Gramercy Tavern"),
//            ),
//            SizedBox(width: 10.0),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: _boxes(
//                  "https://lh5.googleusercontent.com/p/AF1QipMKRN-1zTYMUVPrH-CcKzfTo6Nai7wdL7D8PMkt=w340-h160-k-no",
//                  40.761421, -73.981667,"Le Bernardin"),
//            ),
//            SizedBox(width: 10.0),
//            Padding(
//              padding: const EdgeInsets.all(8.0),
//              child: _boxes(
//                  "https://images.unsplash.com/photo-1504940892017-d23b9053d5d4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60",
//                  40.732128, -73.999619,"Blue Hill"),
//            ),
//          ],
//        ),
//      ),
//    );
//  }

//  Widget _boxes(String _image, double lat,double long,String restaurantName) {
//    return  GestureDetector(
//      onTap: () {
//        _gotoLocation(lat,long);
//      },
//      child:Container(
//        child: new FittedBox(
//          child: Material(
//              color: Colors.white,
//              elevation: 14.0,
//              borderRadius: BorderRadius.circular(24.0),
//              shadowColor: Color(0x802196F3),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Container(
//                    width: 180,
//                    height: 200,
//                    child: ClipRRect(
//                      borderRadius: new BorderRadius.circular(24.0),
//                      child: Image(
//                        fit: BoxFit.fill,
//                        image: NetworkImage(_image),
//                      ),
//                    ),),
//                  Container(
//                    child: Padding(
//                      padding: const EdgeInsets.all(8.0),
//                      child: myDetailsContainer1(restaurantName),
//                    ),
//                  ),
//
//                ],)
//          ),
//        ),
//      ),
//    );
//  }

//  Widget myDetailsContainer1(String restaurantName) {
//    return Column(
//      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//      children: <Widget>[
//        Padding(
//          padding: const EdgeInsets.only(left: 8.0),
//          child: Container(
//              child: Text(restaurantName,
//                style: TextStyle(
//                    color: Color(0xff6200ee),
//                    fontSize: 24.0,
//                    fontWeight: FontWeight.bold),
//              )),
//        ),
//        SizedBox(height:5.0),
//        Container(
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//              children: <Widget>[
//                Container(
//                    child: Text(
//                      "4.1",
//                      style: TextStyle(
//                        color: Colors.black54,
//                        fontSize: 18.0,
//                      ),
//                    )),
//                Container(
//                  child: Icon(
//                    FontAwesomeIcons.solidStar,
//                    color: Colors.amber,
//                    size: 15.0,
//                  ),
//                ),
//                Container(
//                  child: Icon(
//                    FontAwesomeIcons.solidStar,
//                    color: Colors.amber,
//                    size: 15.0,
//                  ),
//                ),
//                Container(
//                  child: Icon(
//                    FontAwesomeIcons.solidStar,
//                    color: Colors.amber,
//                    size: 15.0,
//                  ),
//                ),
//                Container(
//                  child: Icon(
//                    FontAwesomeIcons.solidStar,
//                    color: Colors.amber,
//                    size: 15.0,
//                  ),
//                ),
//                Container(
//                  child: Icon(
//                    FontAwesomeIcons.solidStarHalf,
//                    color: Colors.amber,
//                    size: 15.0,
//                  ),
//                ),
//                Container(
//                    child: Text(
//                      "(946)",
//                      style: TextStyle(
//                        color: Colors.black54,
//                        fontSize: 18.0,
//                      ),
//                    )),
//              ],
//            )),
//        SizedBox(height:5.0),
//        Container(
//            child: Text(
//              "American \u00B7 \u0024\u0024 \u00B7 1.6 mi",
//              style: TextStyle(
//                color: Colors.black54,
//                fontSize: 18.0,
//              ),
//            )),
//        SizedBox(height:5.0),
//        Container(
//            child: Text(
//              "Closed \u00B7 Opens 17:00 Thu",
//              style: TextStyle(
//                  color: Colors.black54,
//                  fontSize: 18.0,
//                  fontWeight: FontWeight.bold),
//            )),
//      ],
//    );
//  }

  }

  Marker currentLoc = Marker(
      markerId: MarkerId('myLocation'),
      position: _currentPosition == null
          ? LatLng(0, 0)
          : LatLng(_currentPosition.latitude, _currentPosition.longitude),
//      icon: BitmapDescriptor.fromAsset(
//          'assets/logo.png'));
      icon: BitmapDescriptor.defaultMarker);

  Marker bernardinMarker = Marker(
      markerId: MarkerId('bernardin'),
      position: LatLng(17.6838, 83.2187),
      infoWindow: InfoWindow(title: 'Le Bernardin',snippet: 'Here is an Info Window Text on a Google Map',onTap: (){
        goTo('Le Bernardin','Here is an Info Window Text on a Google Map');
      }),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      ),
  );

  Marker gramercyMarker = Marker(
    markerId: MarkerId('gramercy'),
    position: LatLng(17.6868, 83.2185),
    infoWindow: InfoWindow(title: 'Gramercy Tavern',snippet: 'Here is an Info Window Text on a Google Map',onTap: (){
      goTo('Gramercy Tavern','Here is an Info Window Text on a Google Map');
    }),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    ),
  );

  Marker blueMarker = Marker(
    markerId: MarkerId('bluehill'),
    position: LatLng(17.688, -83.2186),
    infoWindow: InfoWindow(title: 'Blue Hill',snippet: 'Here is an Info Window Text on a Google Map',onTap: (){
      goTo('Blue Hill','Here is an Info Window Text on a Google Map');
    }),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    ),
  );

//New York Marker

  Marker newyork1Marker = Marker(
    markerId: MarkerId('newyork1'),
    position: LatLng(17.686885, 83.21),
    infoWindow: InfoWindow(title: 'Los Tacos',snippet: 'Here is an Info Window Text on a Google Map',onTap: (){
      goTo('Los Tacos','Here is an Info Window Text on a Google Map');
    }),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    ),
  );
  Marker newyork2Marker = Marker(
    markerId: MarkerId('newyork2'),
    position: LatLng(17.688, 83.285),
    infoWindow: InfoWindow(title: 'Tree Bistro',snippet: 'Here is an Info Window Text on a Google Map',onTap: (){
      goTo('Tree Bistro','Here is an Info Window Text on a Google Map');
    }),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    ),
  );
  Marker newyork3Marker = Marker(
    markerId: MarkerId('newyork3'),
    position: LatLng(17.688, 83.25),
    infoWindow: InfoWindow(title: 'Le Coucou',snippet: 'Here is an Info Window Text on a Google Map',onTap: (){
      goTo('Le Coucou','Here is an Info Window Text on a Google Map');
    }),
    icon: BitmapDescriptor.defaultMarkerWithHue(
      BitmapDescriptor.hueAzure,
    ),
  );


}

class Data {
  String text;
  String dateTime;
  Data({this.text , this.dateTime});
}
