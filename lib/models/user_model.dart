class UserModel {
  final String id;
  final String email;
  final String name;
  final String employeeId;
  final int? department;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.employeeId,
    required this.department
    });

  factory UserModel.fromJson(Map<String, dynamic> data) {
    return UserModel(
      id: data["id"],
      email: data["email"],
      name: data["name"],
      employeeId: data['employee_id'],
      department: data["department"]
    );
  }
}