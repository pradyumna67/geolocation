import 'package:flutter/foundation.dart';

class LocationModel extends ChangeNotifier{
  final String id;
  final String latitude;
  final String longitude;

  LocationModel({
    @required this.id,
    @required this.latitude,
    @required  this.longitude,
  });
}