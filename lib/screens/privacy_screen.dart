import 'package:flutter/material.dart';
import 'package:sentry/theme/sentry_theme.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDarkMode ? SentryTheme.darkSurface : SentryTheme.lightSurface,
        elevation: 0,
        title: Text(
          'Privacy Settings',
          style: TextStyle(
            color: isDarkMode
                ? SentryTheme.darkTextPrimary
                : SentryTheme.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode
                ? SentryTheme.darkTextPrimary
                : SentryTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Sentry',
              style: TextStyle(
                color: isDarkMode
                    ? SentryTheme.darkTextPrimary
                    : SentryTheme.primaryUltraviolet,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Introduction',
              'Sentry is committed to protecting your personal data and ensuring your privacy is safeguarded. '
                  'This Privacy Policy explains how we collect, use, and share your information when you use our application.',
            ),
            _buildSection(
              context,
              'Information We Collect',
              '1. Personal Information: We collect information such as your name, email address, and profile picture when you create an account.\n\n'
                  '2. Usage Data: We may collect data about how you use Sentry, including your interactions with the app, feature usage, and session length.\n\n'
                  '3. Location Data: We collect location data to provide relevant features, such as location-based notifications.',
            ),
            _buildSection(
              context,
              'How We Use Your Information',
              '1. To Improve Our Services: We use your data to improve the functionality and user experience of Sentry.\n\n'
                  '2. To Provide Support: Your information is used to assist you with any queries or issues you may have while using the app.\n\n'
                  '3. To Communicate With You: We may use your contact details to send important updates, changes to our policies, or notifications regarding app features.',
            ),
            _buildSection(
              context,
              'How We Protect Your Information',
              'We take your privacy seriously and use various security measures to protect your data, including encryption and secure storage solutions. '
                  'Access to your personal information is limited to authorized personnel who need it to perform their duties.',
            ),
            _buildSection(
              context,
              'Your Privacy Rights',
              'You have the right to access, modify, or delete your personal data stored in Sentry. If you would like to exercise these rights, please contact us via the app or our support team.',
            ),
            _buildSection(
              context,
              'Changes to This Privacy Policy',
              'We may update this Privacy Policy from time to time. When we do, we will notify you through the app or via email. Please review the changes carefully.',
            ),
            _buildSection(
              context,
              'Contact Us',
              'If you have any questions about this Privacy Policy or how we handle your data, please feel free to contact our support team.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDarkMode
                ? SentryTheme.darkTextPrimary
                : SentryTheme.primaryUltraviolet,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode
                ? SentryTheme.darkTextSecondary
                : SentryTheme.lightTextSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
