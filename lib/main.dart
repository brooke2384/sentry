import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sentry/responda_home.dart';
import 'package:sentry/responda_login.dart';
import 'package:sentry/welcome_screen.dart';
import 'admin_chat.dart';
import 'chat_screen.dart';
import 'history_screen.dart';
import 'info_page.dart';
import 'allergies_page.dart';
import 'login_page.dart';
import 'medicines_page.dart';
import 'blood_type_page.dart';
import 'insurance_page.dart';
import 'confirmation_page.dart';
import 'home_screen.dart';
import 'location_screen.dart';
import 'agent_dispatch_screen.dart';
import 'on_the_way_screen.dart';
import 'arrival_screen.dart';
import 'thank_you_screen.dart';
import 'personal_account_info_page.dart';
import 'notifications_page.dart';
import 'privacy_page.dart';
import 'medical_profile_page.dart';
import 'emergency_contacts_page.dart';
import 'height_weight_page.dart';
import 'residential_address_page.dart';
import 'office_address_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'hk-grotesk', // Set the custom font globally
      ),
      initialRoute: '/welcome_screen', // Start with the welcome screen
      routes: {
        '/welcome_screen': (context) => const WelcomeScreen(),
        '/info': (context) => const InfoPage(),
        '/allergies': (context) => const AllergyPage(),
        '/medicine': (context) => const MedicinesPage(),
        '/blood_type': (context) => const BloodTypePage(),
        '/insurance': (context) => const InsurancePage(),
        '/confirmation': (context) => const ConfirmationPage(),
        '/home': (context) => const HomeScreen(),
        '/admin_home': (context) => const RespondaHomeScreen(),

        '/location': (context) => LocationScreen(userLocation: null,),
        '/agent_dispatched': (context) => const AgentDispatchedPage(),
        '/on_the_way': (context) =>  OnTheWayScreen(),
        '/arrival': (context) =>  ArrivalScreen(),
        '/thank_you': (context) =>  ThankYouScreen(),
        '/chat': (context) => const ChatScreen(),
        '/admin_chat': (context) => const AdminChatScreen(),

        '/personal_account_info': (context) => const PersonalAccountInfoPage(),
        '/notifications': (context) => const NotificationsPage(),
        '/privacy': (context) => const PrivacyPage(),
        '/medical_profile': (context) => const MedicalProfilePage(),
        '/emergency_contacts': (context) => const EmergencyContactsPage(),
        '/height_weight': (context) => const HeightWeightPage(),
        '/residential_address': (context) => const ResidentialAddressPage(),
        '/office_address': (context) => const OfficeAddressPage(),
        '/history': (context) => const HistoryScreen(),
        '/login': (context) => const LoginPage(),
        '/responda_login': (context) => const RespondaLogin(),
      },
    );
  }
}