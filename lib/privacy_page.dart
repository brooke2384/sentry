import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF06413D), // Matching the dark green color
        title: const Text(
          'Privacy Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Privacy Policy for Responds',
                style: TextStyle(
                  color: Color(0xFF06413D), // Dark green color
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Introduction',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Responds is committed to protecting your personal data and ensuring your privacy is safeguarded. '
                    'This Privacy Policy explains how we collect, use, and share your information when you use our application.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              const Text(
                'Information We Collect',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. **Personal Information**: We collect information such as your name, email address, and profile picture when you create an account.'
                    '\n\n2. **Usage Data**: We may collect data about how you use Responds, including your interactions with the app, feature usage, and session length.'
                    '\n\n3. **Location Data**: We collect location data to provide relevant features, such as location-based notifications.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              const Text(
                'How We Use Your Information',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. **To Improve Our Services**: We use your data to improve the functionality and user experience of Responds.'
                    '\n\n2. **To Provide Support**: Your information is used to assist you with any queries or issues you may have while using the app.'
                    '\n\n3. **To Communicate With You**: We may use your contact details to send important updates, changes to our policies, or notifications regarding app features.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              const Text(
                'How We Protect Your Information',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We take your privacy seriously and use various security measures to protect your data, including encryption and secure storage solutions. '
                    'Access to your personal information is limited to authorized personnel who need it to perform their duties.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              const Text(
                'Sharing Your Information',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We do not sell or share your personal information with third parties, except in the following cases:'
                    '\n\n1. **With Your Consent**: We will share your information if you provide explicit consent.'
                    '\n\n2. **For Legal Reasons**: We may share your data to comply with legal obligations or to protect our rights.'
                    '\n\n3. **Service Providers**: We may share your data with trusted third-party providers to help us improve the app or manage your information.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              const Text(
                'Your Privacy Rights',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have the right to access, modify, or delete your personal data stored in Responds. If you would like to exercise these rights, please contact us via the app or our support team.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              const Text(
                'Changes to This Privacy Policy',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'We may update this Privacy Policy from time to time. When we do, we will notify you through the app or via email. Please review the changes carefully.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              const Text(
                'Contact Us',
                style: TextStyle(
                  color: Color(0xFF06413D),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you have any questions about this Privacy Policy or how we handle your data, please feel free to contact our support team.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
