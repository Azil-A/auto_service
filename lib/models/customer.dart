class Customer {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String? password;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }
} 