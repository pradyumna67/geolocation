import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqlite_api.dart';
import 'homepage.dart';
import 'localdb/location_helper.dart';
import 'localdb/location_model.dart';
import 'package:intl/intl.dart';
import 'package:geolocation/utils/shared_pref_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter GoogleMaps Demo',
      theme: ThemeData(
        primaryColor: Color(0xff6200ee),
      ),
      home: Second(),
    );
  }
}



class Second extends StatefulWidget {
  final Data data;
  final Todo todo;
  Second({Key key, this.data,this.todo}) : super(key: key);

  @override
  State<StatefulWidget> createState() {

    return SecondState(this.todo);
  }

}

class SecondState extends State<Second> {
  Position _currentPosition;
  String _currentAddress ;

  static DatabaseHelper helper = DatabaseHelper();

  Todo todo =new Todo('','', '');

  TextEditingController nameController = TextEditingController();

  TextEditingController locationController = TextEditingController();

  TextEditingController titleController = TextEditingController();

  TextEditingController descriptionController = TextEditingController();

  TextEditingController addressController = TextEditingController();

  SecondState(this.todo);

  final Future<Database> dbFuture = helper.initializeDatabase();

  static SharedPrefHelper shHelper = SharedPrefHelper();


  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    //if(_getCurrentLocation() != null){
       addressController = TextEditingController(text: _currentAddress);
       print(addressController.text);
    //}

       //titleController.text = todo.title;
       //descriptionController.text = todo.description;
       //addressController.text = todo.latitude;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
        title: Text("Business Details"),
      ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());//Hide the keyboard
          },


          child: Padding(
            padding: EdgeInsets.only(top: 15.0, left: 20.0, right: 20.0),
            child: ListView(
              children: <Widget>[

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    //controller: TextEditingController()..text = '${widget.data.text}',
                    controller: titleController,
                    decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                        )
                    ),
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    //controller: TextEditingController()..text = '${widget.data.dateTime}',
                    controller: descriptionController,
                    decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0)
                        )
                    ),
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateDescription();
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    //controller: b ? TextEditingController().text = '${_currentPosition.latitude}' : null ,
                  controller: addressController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(

                      labelText: 'Address',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                        ),
                        suffixIcon: IconButton(
                            icon: Icon(Icons.location_on),
                            onPressed:
                              _getCurrentLocation,
                            iconSize: 30.0)
                    ),
                  ),
                ),

//                Padding(
//                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
//                  child: TextField(
//                    controller: descriptionController,
//
//                    decoration: InputDecoration(
//                      labelText: 'Country',
//                        border: OutlineInputBorder(
//                            borderRadius: BorderRadius.circular(5.0)
//                        )
//                    ),
//                  ),
//                ),
//
//                Padding(
//                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
//                  child: TextField(
//                    controller: descriptionController,
//
//                    decoration: InputDecoration(
//                      labelText: 'Description',
//                        border: OutlineInputBorder(
//                            borderRadius: BorderRadius.circular(5.0)
//                        )
//                    ),
//                  ),
//                ),



//                Padding(
//                  padding: EdgeInsets.all(15),
//                  child: Center(
//                    child: Text("Simple Text",style: TextStyle(fontSize: 40.0)),
//                  ),
//                ),




//                Padding(
//                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
//                  child: Row(
//                    children: <Widget>[
//                      Expanded(
//                        child: RaisedButton(
//                          color: Colors.green,
//                          textColor: Theme.of(context).primaryColorLight,
//                          child: Text(
//                            'Save',
//                            textScaleFactor: 1.5,
//                          ),
//                          onPressed: () {
//
//                          },
//                        ),
//                      ),
//
//                      Container(width: 10.0),
//
//                      Expanded(
//                        child: RaisedButton(
//                          color: Colors.red,
//                          textColor: Theme.of(context).primaryColorLight,
//                          child: Text(
//                            'Delete',
//                            textScaleFactor: 1.5,
//                          ),
//                          onPressed: () {
//
//                          },
//                        ),
//                      ),
//
//                    ],
//                  ),
//                ),


                Padding(
                  padding: EdgeInsets.all(15),
                  child: Center(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                      child: Text(
                        'Update',
                        textScaleFactor: 1.5,
                      ),
                      onPressed: () {
                        setState(() {
                          shHelper.saveData(10);
                          debugPrint("Save button clicked");
                          _save();
                        });
                      },
                    ),
                  ),
                ),


              ],
            ),
          ),

        )
    );
  }

  void _save() async {
    //todo.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    Todo todo = Todo(titleController.text,'',descriptionController.text);
    if(titleController.text.length != 0 && descriptionController.text.length != 0 && addressController.text.length != 0){
      await helper.insertTodo(todo);
      print(titleController.text+" "+descriptionController.text);
      moveToLastScreen();
    }else{// Case 2: Insert Operation
      _showAlertMessage('Status', 'Please enter the fields');
    }

    //if (result != 0) {  // Success
      //_showAlertDialog('Status', 'Todo Saved Successfully');
    //} else {  // Failure
      //_showAlertDialog('Status', 'Problem Saving Todo');
    //}

  }

  void updateTitle(){
    todo.title = titleController.text;
  }

  void updateDescription() {
    todo.description = descriptionController.text;
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void _showAlertMessage(String title, String message) {


    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }


  _getCurrentLocation() {
    //FocusScope.of(context).requestFocus(new FocusNode());//Hide the keyboard
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
        "${place.locality},${place.administrativeArea},${place.subLocality}, ${place.postalCode}, ${place.country}";
        //print(' ${place.locality}, ${place.adminArea},${place.subLocality}, ${place.subAdminArea},${place.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
      });
    } catch (e) {
      print(e);
    }
  }
}