// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_restaurant/common/models/zone_models.dart';
import 'package:http/http.dart' as http;

class ZoneProvider with ChangeNotifier {
  List<SupZone> _supZones = [];

  List<SupZone> get supZones => _supZones;

  List<SupZone> supZoneList = [];
  String selectedCity = '';

  // Other methods...

  double getDeliveryFeeForSelectedCity() {
    for (var supZone in supZoneList) {
      if (supZone.city == selectedCity) {
        return supZone.deliveryFees.toDouble();
      }
    }
    return 0.0; // Or a default value
  }

  Future<void> fetchSupZoneData() async {
    const url = 'https://app.lamadafood.com/api/v1/location/sup_zone/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> supZoneList = jsonData['supZone'];

        _supZones = supZoneList.map((zone) {
          var supZone = SupZone.fromJson(zone);

          return supZone;
        }).toList();

        notifyListeners();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
