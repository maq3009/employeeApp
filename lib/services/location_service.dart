import 'package:employee_attendance/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();
  late LocationData _locData;

  Future<Map<String, double?>?> initializeAndGetLocation (BuildContext context) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        Utils.showSnackBar("Please Enable Location", context);
        return null;
      }
    }
    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if(permissionGranted != PermissionStatus.granted){
        Utils.showSnackBar("Location Permissions are needed for this app to work properly.", context);
        return null;
      }
    }


    //After permission granted:
    _locData = await location.getLocation();
    return {
      'latitude': _locData.latitude,
      'longitude': _locData.longitude,
    };
  }

} 