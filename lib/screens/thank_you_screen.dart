import 'package:flutter/material.dart';
import 'package:sentry/theme/sentry_theme.dart';
import 'profile_page.dart';

class ThankYouScreen extends StatefulWidget {
  const ThankYouScreen({super.key});

  @override
  _ThankYouScreenState createState() => _ThankYouScreenState();
}

class _ThankYouScreenState extends State<ThankYouScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedEmojiIndex;
  int? _animatingEmojiIndex;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? SentryTheme.darkBackground : SentryTheme.lightBackground,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDarkMode ? SentryTheme.darkSurface : SentryTheme.primaryUltraviolet,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.person,
                color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
              ),
              title: Text(
                'PROFILE',
                style: TextStyle(
                  color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
              ),
              title: Text(
                'LOGOUT',
                style: TextStyle(
                  color: isDarkMode ? SentryTheme.darkTextPrimary : SentryTheme.primaryUltraviolet,
                ),
              ),
              onTap: () async {
                setState(() => _isLoading = true);
                try {
                  Navigator.pushReplacementNamed(context, '/login');
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error logging out: $e')),
                  );
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 50,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilePage()),
                  );
                },
                child: Text(
                  'User',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                backgroundImage: AssetImage('assets/icons/user.png'),
                radius: 20,
              ),
              const SizedBox(width: 10),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDarkMode ? SentryTheme.darkSurface : SentryTheme.primaryUltraviolet,
              isDarkMode ? SentryTheme.darkBackground : const Color(0xFFCEDA2E),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/sentry.png',
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Log the error for debugging
                            print('Error loading logo: $error');
                            // Return a placeholder or fallback widget
                            return Container(
                              height: 30,
                              width: 30,
                              color: SentryTheme.accentCyan,
                              child: const Center(
                                child: Text(
                                  'S',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Sentry',
                          style: TextStyle(
                            color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Thank\n',
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: 'You',
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildRatingSection(isDarkMode),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildRatingSection(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate our Service',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? SentryTheme.darkTextPrimary : Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(5, (index) {
            IconData iconData;
            switch (index) {
              case 0:
                iconData = Icons.sentiment_very_dissatisfied;
                break;
              case 1:
                iconData = Icons.sentiment_dissatisfied;
                break;
              case 2:
                iconData = Icons.sentiment_neutral;
                break;
              case 3:
                iconData = Icons.sentiment_satisfied;
                break;
              case 4:
                iconData = Icons.sentiment_very_satisfied;
                break;
              default:
                iconData = Icons.sentiment_neutral;
            }

            return TweenAnimationBuilder(
              tween: Tween<double>(
                begin: 1.0,
                end: _animatingEmojiIndex == index ? 1.2 : 1.0,
              ),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: IconButton(
                    icon: Icon(
                      iconData,
                      color: _selectedEmojiIndex == index
                          ? (isDarkMode ? SentryTheme.accentCyan : Colors.white)
                          : (isDarkMode ? SentryTheme.darkTextSecondary : Colors.white70),
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedEmojiIndex = index;
                        _animatingEmojiIndex = index;
                      });
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (mounted) {
                          setState(() {
                            _animatingEmojiIndex = null;
                          });
                        }
                      });
                    },
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

