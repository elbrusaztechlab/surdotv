class ContactMessageModel {
  const ContactMessageModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
    required this.message,
  });

  final String name;
  final String email;
  final String phone;
  final String city;
  final String message;

  Map<String, String> toFormBody() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
      'message': message,
    };
  }
}
