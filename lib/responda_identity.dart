import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:response/responda_success.dart';
import 'package:response/success_screen.dart';

class RespondaIdentityScreen extends StatefulWidget {
  const RespondaIdentityScreen({super.key});

  @override
  _RespondaIdentityScreenState createState() => _RespondaIdentityScreenState();
}

class _RespondaIdentityScreenState extends State<RespondaIdentityScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Method to pick image from camera
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Method to show bottom sheet to pick or take a photo
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to upload the image using API
  Future<void> _uploadImageToAPI() async {
    if (_imageFile == null) return;

    try {
      var uri = Uri.parse('https://responda.frobyte.ke/api/v1/user'); // Replace with your API URL

      var request = http.MultipartRequest('POST', uri);
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        _showSuccessModal();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Success Modal with green check and a button to proceed
  void _showSuccessModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFFBCCE2A), // Green color to match theme
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Successful!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06413D), // Dark green text
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBCCE2A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the modal
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const RespondaSuccess()),
                  );
                },
                child: const Text(
                  'PROCEED',
                  style: TextStyle(
                    color: Color(0xFF06413D), // Dark green text
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to skip the profile picture step
  Future<void> _skipStep() async {
    // Directly navigate to the success screen without uploading an image
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RespondaSuccess()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                    child: Image.asset(
                      'assets/images/logos/Responda_Dark.png', // Replace with your logo
                      height: 30,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Responda',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF06413D),
                      fontFamily: 'hk-grotesk',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Verify your Identity',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF06413D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose whether to take a photo or upload an existing file.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF06413D),
                ),
              ),
              const SizedBox(height: 42),
              GestureDetector(
                onTap: () {
                  _showImageSourceActionSheet(context);
                },
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: _imageFile != null
                      ? ClipOval(
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                      width: 150,
                      height: 150,
                    ),
                  )
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 50,
                        color: Colors.teal,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'USE CAMERA',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Tap on the circle above to take a photo or choose a file.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 120),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_imageFile == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select or take an image first.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
                    await _uploadImageToAPI(); // Upload image using API
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD0DB27),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 120, // Large horizontal padding
                    vertical: 12, // Enough vertical padding for comfortable size
                  ),
                ),
                icon: const Icon(
                  Icons.cloud_upload,
                  color: Color(0xFF06413D),
                  size: 24, // Maintain a good icon size
                ),
                label: _isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Color(0xFF06413D),
                    strokeWidth: 2.0,
                  ),
                )
                    : const Text(
                  'UPLOAD',
                  style: TextStyle(
                    color: Color(0xFF06413D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: _skipStep,
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    color: Color(0xFF06413D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
