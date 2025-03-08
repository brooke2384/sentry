import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:response/repositories/user_repository.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'allergies_page.dart';
import 'models/user_model.dart'; // Import the AllergyPage

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final _formKey = GlobalKey<FormState>();
  String dob = '';
  String resident = '';
  String emergencyContactName = '';
  String emergencyContactNumber = '';
  final TextEditingController dobController = TextEditingController();

  final UserRepository userRepository =
      UserRepository(); // Initialize UserRepository

  // List of worldwide countries
  final List<String> countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Belgium',
    'Belize',
    'Benin',
    'Bhutan',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Botswana',
    'Brazil',
    'Brunei',
    'Bulgaria',
    'Burkina Faso',
    'Burundi',
    'Cabo Verde',
    'Cambodia',
    'Cameroon',
    'Canada',
    'Central African Republic',
    'Chad',
    'Chile',
    'China',
    'Colombia',
    'Comoros',
    'Congo',
    'Costa Rica',
    'Croatia',
    'Cuba',
    'Cyprus',
    'Czech Republic',
    'Denmark',
    'Djibouti',
    'Dominica',
    'Dominican Republic',
    'Ecuador',
    'Egypt',
    'El Salvador',
    'Equatorial Guinea',
    'Eritrea',
    'Estonia',
    'Eswatini',
    'Ethiopia',
    'Fiji',
    'Finland',
    'France',
    'Gabon',
    'Gambia',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Grenada',
    'Guatemala',
    'Guinea',
    'Guinea-Bissau',
    'Guyana',
    'Haiti',
    'Honduras',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Ivory Coast',
    'Jamaica',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kiribati',
    'Kuwait',
    'Kyrgyzstan',
    'Laos',
    'Latvia',
    'Lebanon',
    'Lesotho',
    'Liberia',
    'Libya',
    'Lithuania',
    'Luxembourg',
    'Madagascar',
    'Malawi',
    'Malaysia',
    'Maldives',
    'Mali',
    'Malta',
    'Mauritania',
    'Mauritius',
    'Mexico',
    'Micronesia',
    'Moldova',
    'Monaco',
    'Mongolia',
    'Montenegro',
    'Morocco',
    'Mozambique',
    'Myanmar',
    'Namibia',
    'Nauru',
    'Nepal',
    'Netherlands',
    'New Zealand',
    'Nicaragua',
    'Niger',
    'Nigeria',
    'North Korea',
    'Norway',
    'Oman',
    'Pakistan',
    'Palau',
    'Panama',
    'Papua New Guinea',
    'Paraguay',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Rwanda',
    'Saint Kitts and Nevis',
    'Saint Lucia',
    'Saint Vincent and the Grenadines',
    'Samoa',
    'San Marino',
    'Sao Tome and Principe',
    'Saudi Arabia',
    'Senegal',
    'Serbia',
    'Seychelles',
    'Sierra Leone',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'Solomon Islands',
    'Somalia',
    'South Africa',
    'South Korea',
    'South Sudan',
    'Spain',
    'Sri Lanka',
    'Sudan',
    'Suriname',
    'Sweden',
    'Switzerland',
    'Syria',
    'Taiwan',
    'Tajikistan',
    'Tanzania',
    'Thailand',
    'Timor-Leste',
    'Togo',
    'Tonga',
    'Trinidad and Tobago',
    'Tunisia',
    'Turkey',
    'Turkmenistan',
    'Tuvalu',
    'Uganda',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Uzbekistan',
    'Vanuatu',
    'Vatican City',
    'Venezuela',
    'Vietnam',
    'Yemen',
    'Zambia',
    'Zimbabwe'
  ];

  // Function to show success modal
  Future<void> _showSuccessDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle,
                  color: Color(0xFFBCCE2A),
                  size: 60), // Bigger lime green check icon
              SizedBox(height: 20),
              Text(
                'Success!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            'Your data has been added successfully.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment:
              MainAxisAlignment.center, // Center the confirm button
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor:
                    const Color(0xFFBCCE2A), // Lime green for success
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => AllergyPage()));
              },
              child: const Text(
                'Continue',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

// Function to show failure modal
  Future<void> _showFailureDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.error,
                  color: Colors.red, size: 60), // Bigger red 'X' icon
              SizedBox(height: 20),
              Text(
                'Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: const Text(
            'Value has not been added. Please try again.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment:
              MainAxisAlignment.center, // Center the confirm button
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Red for error
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Close the modal
              },
              child: const Text(
                'Try Again',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Function to save user data to Firebase Firestore
  Future<void> _saveUserDataToFirestore() async {
    final user = UserModel(
      userId: 'generated-id', // Replace with real logic for user ID
      username: emergencyContactName, // Use actual fields from form
      dateOfBirth: dob,
      residence: resident,
      emergencyContactName: emergencyContactName,
      emergencyContactNumber: emergencyContactNumber,
      allergyType: '', // Add allergy logic later
      hasAllergy: false, // Default false
      medicineTaken: '',
      isTakingMedicine: false,
      email: '', // Default false
    );

    try {
      await userRepository.createUser(user); // Save the user to Firestore
      await _showSuccessDialog(); // Show success modal
    } catch (e) {
      await _showFailureDialog(); // Show failure modal
    }
  }

  // Function to open date picker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // Add null check
      setState(() {
        dob = DateFormat('dd/MM/yyyy').format(pickedDate);
        dobController.text = dob;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          children: [
            Expanded(
              child: SizedBox(
                width: 450,
                height: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: LinearProgressIndicator(
                    value: 0.1667,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF06413D)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 29),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/allergies');
              },
              child: const Text(
                "Skip",
                style: TextStyle(
                    color: Color(0xFF06413D), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Information About Yourself',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF06413D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'FULL NAME*',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05403C)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'FULL NAME',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            emergencyContactName = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Date of Birth Field with Date Picker
                      const Text(
                        'DATE OF BIRTH*',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05403C)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          controller: dobController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            hintText: 'Select Date of Birth',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          onTap: () => _selectDate(context), // Show date picker
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your date of birth';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'COUNTRY OF RESIDENCE*',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05403C)),
                      ),
                      DropdownButtonFormField<String>(
                        value: resident.isNotEmpty ? resident : null,
                        items: countries.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            resident = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your country of residence';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'EMERGENCY CONTACT NAME*',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05403C)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Emergency Contact Name',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            emergencyContactName = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter emergency contact name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'EMERGENCY CONTACT NUMBER*',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF05403C)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Enter Emergency Contact Number',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 16.0),
                          ),
                          onChanged: (value) {
                            emergencyContactNumber = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter emergency contact number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: double.infinity, // Make the button take the full width
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _saveUserDataToFirestore(); // Save to Firestore
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFBCCE2A), // Background color
                      padding: const EdgeInsets.symmetric(
                          vertical: 15), // Reduced padding
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(8), // Slight border radius
                      ),
                    ),
                    child: const Text(
                      'NEXT',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
