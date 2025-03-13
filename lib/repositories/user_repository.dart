import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserRepository {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // Create or Add User to Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _userCollection.doc(user.userId).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Fetch User by ID from Firestore
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _userCollection.doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  // Update User Information
  Future<void> updateUser(UserModel user) async {
    try {
      await _userCollection.doc(user.userId).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete User from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await _userCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get User Information
  Future<UserModel> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        throw Exception('User ID not found');
      }

      DocumentSnapshot userDoc = await _userCollection.doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>);
      } else {
        // Return empty user model if no data exists
        return UserModel(
          userId: userId,
          username: '',
          email: '',
          dateOfBirth: '',
          residence: '',
          allergyType: '',
          hasAllergy: false,
          medicineTaken: '',
          isTakingMedicine: false,
        );
      }
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  // Update User Information
  Future<void> updateUserInfo(UserModel userModel) async {
    try {
      await _userCollection
          .doc(userModel.userId)
          .set(userModel.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update user info: $e');
    }
  }
}
