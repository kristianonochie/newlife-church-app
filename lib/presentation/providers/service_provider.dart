import 'dart:convert';
import 'package:flutter/services.dart';
import '../../core/models/service.dart';
import 'package:flutter/material.dart';

class ServiceProvider extends ChangeNotifier {
  List<Service> services = [];
  bool isLoading = true;

  ServiceProvider() {
    loadServices();
  }

  Future<void> loadServices() async {
    try {
      final String data = await rootBundle.loadString('lib/data/fixtures/services.json');
      final List<dynamic> jsonResult = json.decode(data);
      services = jsonResult.map((e) => Service.fromJson(e)).toList();
    } catch (e) {
      services = [];
    }
    isLoading = false;
    notifyListeners();
  }
}
