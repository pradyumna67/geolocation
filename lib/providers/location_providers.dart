import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocation/models/location_model.dart';

class ProductProvider with ChangeNotifier{
  List<LocationModel> _locationList = [];

  List<LocationModel> get items{
    return [..._locationList];
  }

  Future<void> fetch() async{
    const url = 'https://flutter-8b7ee.firebaseio.com/location.json';
    try{
      final response =await http.get(url);
      final extractData =json.decode(response.body) as Map<String,dynamic>;
      final List<LocationModel> loadedProduct = [];
      extractData.forEach((prodId,prodData){
        loadedProduct.add(LocationModel(id: prodId, latitude: prodData['latitude'], longitude: prodData['longitude']));
      });
      _locationList = loadedProduct;
      notifyListeners();
    }catch(error){
      throw(error);
    }
  }
}