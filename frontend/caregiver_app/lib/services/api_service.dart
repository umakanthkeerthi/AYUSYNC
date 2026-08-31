import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator to hit localhost, or actual IP if physical device
  // Since we are running web/desktop, localhost is fine.
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  Future<Map<String, dynamic>> getDashboardData(String caregiverId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/caregivers/$caregiverId/dashboard'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load dashboard data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
