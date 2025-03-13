import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'package:sentry/screens/admin_home_screen.dart';
import 'package:sentry/screens/admin_login_screen.dart';
import 'package:sentry/screens/welcome_screen.dart';
import 'package:sentry/screens/admin_chat_screen.dart';
import 'package:sentry/screens/chat_screen.dart';
import 'package:sentry/screens/history_screen.dart';
import 'package:sentry/screens/info_screen.dart';
import 'package:sentry/screens/allergies_screen.dart';
import 'package:sentry/screens/login_screen.dart';
import 'package:sentry/screens/medicines_screen.dart';
import 'package:sentry/screens/blood_type_screen.dart';
import 'package:sentry/screens/insurance_screen.dart';
import 'package:sentry/screens/confirmation_screen.dart';
import 'package:sentry/screens/home_screen.dart';
import 'package:sentry/screens/location_screen.dart';
import 'package:sentry/screens/agent_dispatch_screen.dart';
import 'package:sentry/screens/on_the_way_screen.dart';
import 'package:sentry/screens/arrival_screen.dart';
import 'package:sentry/screens/thank_you_screen.dart';
import 'package:sentry/screens/personal_account_info_screen.dart';
import 'package:sentry/screens/notifications_screen.dart';
import 'package:sentry/screens/privacy_screen.dart';
import 'package:sentry/screens/medical_profile_screen.dart';
import 'package:sentry/screens/emergency_contacts_screen.dart';
import 'package:sentry/screens/height_weight_screen.dart';
import 'package:sentry/screens/residential_address_screen.dart';
import 'package:sentry/screens/office_address_screen.dart';
import 'package:sentry/screens/splash_screen.dart';
import 'package:sentry/screens/sign_up.dart';
import 'package:sentry/screens/verify_identity_screen.dart';
import 'package:sentry/screens/otp_verification_screen.dart';
import 'package:sentry/screens/success_screen.dart';
import 'package:sentry/screens/sentry_success.dart';
import 'package:sentry/screens/sentry_history.dart';
import 'package:sentry/screens/sentry_settings.dart';
import 'package:sentry/screens/Sentry_Profile_profile.dart';
import 'package:sentry/screens/Sentry_identity.dart';
import 'package:sentry/screens/admin_signup_screen.dart';
import 'package:sentry/screens/profile_page.dart';
import 'package:sentry/screens/settings_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SentryApp());
}

class SentryApp extends StatelessWidget {
  const SentryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sentry',
      debugShowCheckedModeBanner: false,
      theme: SentryTheme.lightTheme(),
      darkTheme: SentryTheme.darkTheme(),
      themeMode: ThemeMode.system,
      initialRoute: '/splash_screen',
      routes: {
        '/splash_screen': (context) => const SplashScreen(),
        '/welcome_screen': (context) => const WelcomeScreen(),
        '/sign_up': (context) => SignUpPage(),
        '/login': (context) => const LoginScreen(),
        '/otp_verification': (context) => const OTPVerificationScreen(phoneNumber: ''),
        '/verify_identity': (context) => const VerifyIdentityScreen(),
        '/success_screen': (context) => const SuccessScreen(),
        '/sentry_success': (context) => const SentrySuccess(),
        '/info': (context) => const InfoPage(),
        '/allergies': (context) => const AllergyPage(),
        '/medicine': (context) => const MedicinesPage(),
        '/blood_type': (context) => const BloodTypePage(),
        '/insurance': (context) => const InsurancePage(),
        '/confirmation': (context) => const ConfirmationPage(),
        '/home': (context) => const HomeScreen(),
        '/admin_home': (context) => const AdminHomeScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
        '/admin_signup': (context) => const AdminSignupScreen(),
        '/location': (context) => LocationScreen(
              userLocation: null,
            ),
        '/agent_dispatched': (context) => const AgentDispatchedPage(),
        '/on_the_way': (context) => const OnTheWayScreen(),
        '/arrival': (context) => const ArrivalScreen(),
        '/thank_you': (context) => const ThankYouScreen(),
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
        '/sentry_history': (context) => const SentryHistory(),
        '/sentry_settings': (context) => const SentrySettings(),
        '/sentry_profile': (context) => const SentryProfile(),
        '/sentry_identity': (context) => const SentryIdentityScreen(),
        '/profile_page': (context) => const ProfilePage(),
        '/settings_page': (context) => const SettingsPage(),
      },
    );
  }
}
