class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      name: map['name'] as String? ?? 'Guest',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
    );
  }
}
