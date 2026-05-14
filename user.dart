class User {
  final String id;
  final String name;
  final String email;
  final String? role; // Optional role for admin/user differentiation

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role, // Role is optional
  });

  /// Factory method to create a `User` object from a database map
  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      name: data['name'] ?? 'Unnamed User', // Default fallback value
      email: data['email'] ?? 'noemail@example.com', // Default fallback value
      role: data['role'], // Handle optional role field
    );
  }

  /// Converts the `User` object into a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      if (role != null) 'role': role, // Include role only if it's not null
    };
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role)';
  }
}
