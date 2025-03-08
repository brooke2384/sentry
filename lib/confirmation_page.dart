import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                width: 450,
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: LinearProgressIndicator(
                    value: 1.0, // 100% progress
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF06413D)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title Text
            const Text(
              "You're All Set",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF06413D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Description Text
            Text(
              "The information you have provided will help us\nserve you better in the case of an emergency.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            // Centered Checkmark icon inside a circular container
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  color: Color(0xFFB4D540), // Lime green
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.teal[900],
                  size: 200,
                ),
              ),
            ),
            const SizedBox(height: 30), // Space before the button

            const Spacer(), // Push the button to the bottom

            // Home Page Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB4D540), // Updated color
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                child: const Text(
                  'HOME PAGE',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF08403C),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
