import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:employee_attendance/models/user_model.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch employees from the Supabase employees table
  Future<List<UserModel>> getEmployees() async {
    try {
      // Perform the query to fetch employees
      final List<dynamic> response = await _supabase
          .from('employees')
          .select('id, name, email, department, employee_id');

      // Map the response to a list of UserModel
      return response.map((item) => UserModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      // Handle errors and throw an exception
      throw Exception('Failed to fetch employees: $e');
    }
  }
}
