class UserModel {
  String userId;
  String username;
  String email;

  String dateOfBirth;
  String residence;
  String emergencyContactName;
  String emergencyContactNumber;
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
    required this.emergencyContactName,
    required this.emergencyContactNumber,
    required this.allergyType,
    required this.hasAllergy,
    required this.medicineTaken,
    required this.isTakingMedicine,
  });

  // Convert from Firestore snapshot to UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'],
      username: data['username'],
      email: data['email'],
      dateOfBirth: data['date_of_birth'],
      residence: data['residence'],
      emergencyContactName: data['emergency_contact_name'],
      emergencyContactNumber: data['emergency_contact_number'],
      allergyType: data['allergy_type'],
      hasAllergy: data['has_allergy'] ?? false,
      medicineTaken: data['medicine_taken'],
      isTakingMedicine: data['is_taking_medicine'] ?? false,
    );
  }

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'email': email,
      'date_of_birth': dateOfBirth,
      'residence': residence,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_number': emergencyContactNumber,
      'allergy_type': allergyType,
      'has_allergy': hasAllergy,
      'medicine_taken': medicineTaken,
      'is_taking_medicine': isTakingMedicine,
    };
  }
}
