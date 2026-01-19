import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../core/models/guide.dart';

class GuideProvider extends ChangeNotifier {
  List<Guide> guides = [];
  bool isLoading = true;

  GuideProvider() {
    loadGuides();
  }

  Future<void> loadGuides() async {
    try {
      final String data = await rootBundle.loadString('lib/data/fixtures/guides.json');
      final List<dynamic> jsonResult = json.decode(data);
      guides = jsonResult.map((e) => Guide.fromJson(e)).toList();
    } catch (e) {
      guides = [];
    }
    isLoading = false;
    notifyListeners();
  }
}
