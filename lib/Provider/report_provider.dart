import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:slip_genrater/model/reportmodel.dart';
 // Import your ReportModel here

class ReportProvider with ChangeNotifier {
  List<ReportModel> _reports = [];

  List<ReportModel> get reports => _reports;

  Future<void> fetchReports() async {
    try {
      final Dio dio = Dio();
      Response response = await dio.get('https://tollapi-3.onrender.com/api/get');
      
      if (response.statusCode == 200) {
        List data = response.data as List;
        _reports = data.map((json) => ReportModel.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (e) {
      print("Error fetching reports: $e");
    }
  }
}
