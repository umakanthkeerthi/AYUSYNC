import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // AWS EC2 Backend IP: http://16.171.226.51/api/v1
  // Local Development: http://localhost:8000/api/v1
  static const String baseUrl = 'http://16.171.226.51/api/v1';
  
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

  Future<Map<String, dynamic>> getScheduleData(String caregiverId, {String? date}) async {
    try {
      final url = date != null 
          ? '$baseUrl/caregivers/$caregiverId/schedule?date=$date' 
          : '$baseUrl/caregivers/$caregiverId/schedule';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load schedule data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> executeScheduleAction(String caregiverId, String scheduleId, String action) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/caregivers/$caregiverId/schedule/$scheduleId/action'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'action': action}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to execute schedule action: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getMessages(String caregiverId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/caregivers/$caregiverId/messages'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load messages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage(String caregiverId, String patientId, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/caregivers/$caregiverId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'patient_id': patientId, 'text': text}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> getProfileData(String caregiverId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/caregivers/$caregiverId/profile'));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load profile data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> arrangeTransport(String caregiverId, String patientId, String alertId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/caregivers/$caregiverId/actions/arrange-transport'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'patient_id': patientId, 'alert_id': alertId}),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to arrange transport: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

