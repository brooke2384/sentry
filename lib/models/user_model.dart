class UserModel {
  String userId;
  String username;
  String email;

  String dateOfBirth;
  String residence;
  EmergencyContact? emergencyContact;
  String allergyType;
  bool hasAllergy;
  String medicineTaken;
  bool isTakingMedicine;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.dateOfBirth,
    required this.residence,
    this.emergencyContact,
    required this.allergyType,
    required this.hasAllergy,
    required this.medicineTaken,
    required this.isTakingMedicine,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      dateOfBirth: data['date_of_birth'] ?? '',
      residence: data['residence'] ?? '',
      emergencyContact: data['emergency_contact'] != null
          ? EmergencyContact(
              name: data['emergency_contact']['name'] ?? '',
              phone: data['emergency_contact']['phone'] ?? '',
            )
          : null,
      allergyType: data['allergy_type'] ?? '',
      hasAllergy: data['has_allergy'] ?? false,
      medicineTaken: data['medicine_taken'] ?? '',
      isTakingMedicine: data['is_taking_medicine'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'date_of_birth': dateOfBirth,
      'residence': residence,
      'emergency_contact': emergencyContact?.toJson(),
      'allergy_type': allergyType,
      'has_allergy': hasAllergy,
      'medicine_taken': medicineTaken,
      'is_taking_medicine': isTakingMedicine,
    };
  }
}

class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
    };
  }
}
