class User {
  final String name;
  final String phone;
  final String email;
  final String branchId;
  final String userType;

  User({
    required this.name,
    required this.phone,
    required this.email,
    required this.branchId,
    required this.userType,
  });

  // Factory method to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] ?? 'N/A', // Default to 'N/A' if value is null
      phone: json['phone'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
      branchId: json['branchId'] ?? 'N/A',
      userType: json['userType'] ?? 'N/A',
    );
  }
}
