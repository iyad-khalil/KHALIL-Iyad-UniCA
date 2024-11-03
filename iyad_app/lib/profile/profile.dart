import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ajouter_vetement.dart';
import '../authentification/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _loginController =
      TextEditingController(); // Controller for login
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _newPasswordController =
      TextEditingController(); // Controller for new password
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _newPasswordController.text =
        "********"; // Afficher des caractères masqués pour le mot de passe
  }

  Future<void> _loadUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _loginController.text = user.email ?? ''; // Set login from user's email
        _cityController.text = userDoc['City'] ?? '';
        _addressController.text = userDoc['addresse'] ?? '';
        _birthdayController.text = userDoc['birthday'] ?? '';
        _postalCodeController.text = userDoc['code postal'] ?? '';
      });
    }
  }

  Future<void> _saveChangesAndUpdatePassword() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save user data
      final newData = {
        'City': _cityController.text,
        'addresse': _addressController.text,
        'birthday': _birthdayController.text,
        'code postal': _postalCodeController.text,
      };
      await _firestore.collection('users').doc(user.uid).update(newData);

      // Update password if new password is provided
      if (_newPasswordController.text.isNotEmpty &&
          _newPasswordController.text != "********") {
        try {
          await user.updatePassword(_newPasswordController.text);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password updated successfully!"),
              backgroundColor: Colors.lightBlue,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error updating password: ${e.toString()}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      // Show success message for saving user data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Changes saved successfully!"),
          backgroundColor: Colors.lightBlue,
        ),
      );
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateToAddClothing() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VetementListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 4,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const SizedBox(height: 30),
                  const SizedBox(height: 40),

                  // Login Input (Readonly)
                  _buildTextField(
                      controller: _loginController,
                      label: "Login",
                      icon: Icons.person,
                      readOnly: true), // Readonly login field
                  const SizedBox(height: 20),

                  // Password Input (modifiable)
                  _buildPasswordField(),
                  const SizedBox(height: 20),

                  // Birthday Input
                  _buildTextField(
                      controller: _birthdayController,
                      label: "Anniversaire",
                      icon: Icons.cake),
                  const SizedBox(height: 20),

                  // Address Input
                  _buildTextField(
                      controller: _addressController,
                      label: "Addresse",
                      icon: Icons.home),
                  const SizedBox(height: 20),

                  // Postal Code Input
                  _buildTextField(
                      controller: _postalCodeController,
                      label: "Code postal",
                      icon: Icons.local_post_office,
                      keyboardType: TextInputType.number), // Numeric keyboard
                  const SizedBox(height: 20),

                  // City Input
                  _buildTextField(
                      controller: _cityController,
                      label: "Ville",
                      icon: Icons.location_city),
                  const SizedBox(height: 20),

                  // Valider Button
                  SizedBox(
                    width: 300,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _saveChangesAndUpdatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Valider",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add Clothing Button
                  SizedBox(
                    width: 300,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _navigateToAddClothing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 65, 206, 70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Ajouter un vêtement",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign Out Button
                  SizedBox(
                    width: 300,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _signOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        iconColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Se déconnecter",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      width: 300,
      height: 45,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.lightBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return SizedBox(
      width: 300,
      height: 45,
      child: TextField(
        controller: _newPasswordController,
        obscureText: true, // Keep password offuscated
        decoration: InputDecoration(
          labelText: "Password",
          prefixIcon: const Icon(Icons.lock),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.lightBlue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.lightBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
