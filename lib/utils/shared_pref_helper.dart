import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SharedPrefHelper{

  static SharedPrefHelper _sharedPrefHelper;

  SharedPrefHelper._createInstance();

  factory SharedPrefHelper() {

    if (_sharedPrefHelper == null) {
      _sharedPrefHelper = SharedPrefHelper._createInstance(); // This is executed only once, singleton object
    }
    return _sharedPrefHelper;
  }

   saveData(int value) async {
       SharedPreferences prefs = await SharedPreferences.getInstance();
       //int counter = (prefs.getInt('counter') ?? 0) + 1;
       //print('Pressed $counter times.');
       await prefs.setInt('counter', value);
  }
   getData() async{
       SharedPreferences prefs = await SharedPreferences.getInstance();
       int value =  prefs.getInt('counter') ?? 0;
       print("Vijay  :: $value");
       return value;
  }


   saveList(List<int> integerList) async{
       List<int> myListOfIntegers = integerList;
       List<String> myListOfStrings=  myListOfIntegers.map((i)=>i.toString()).toList();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      //List<String> myList = (prefs.getStringList('mylist') ?? List<String>());
      //List<int> myOriginaList = myList.map((i)=> int.parse(i)).toList();
      //print('Your list  $myOriginaList');
      await prefs.setStringList('mylist', myListOfStrings);
  }
   getList() async{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> myList = (prefs.getStringList('mylist') ?? List<String>());
      List<int> myOriginaList = myList.map((i)=> int.parse(i)).toList();
      return myOriginaList;
  }
}