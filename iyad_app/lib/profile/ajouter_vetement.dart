import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'profile.dart'; // Import ProfileScreen

class VetementListScreen extends StatefulWidget {
  const VetementListScreen({super.key});

  @override
  State<VetementListScreen> createState() => _VetementListScreenState();
}

class _VetementListScreenState extends State<VetementListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _categorieController = TextEditingController();
  final TextEditingController _tailleController = TextEditingController();
  final TextEditingController _marqueController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();

  Uint8List? imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  String? get imageBase64 =>
      imageBytes != null ? base64Encode(imageBytes!) : null;

  Future<void> _pickImage() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();

        if (bytes.length > 1024 * 1024) {
          throw Exception(
              'Image size too large. Please select an image under 1MB.');
        }

        setState(() {
          imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addVetement() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        final prix = double.tryParse(_prixController.text);
        if (prix == null) {
          throw Exception("Invalid price");
        }

        await _firestore.collection('vetements').add({
          'titre': _titreController.text,
          'categorie': _categorieController.text,
          'taille': _tailleController.text,
          'marque': _marqueController.text,
          'prix': prix,
          'imagebase64': imageBase64,
        });

        _titreController.clear();
        _categorieController.clear();
        _tailleController.clear();
        _marqueController.clear();
        _prixController.clear();
        setState(() {
          imageBytes = null;
        });

        // Navigate to ProfileScreen after adding the item
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vêtement ajouté avec succès!"),
            backgroundColor: Colors.lightBlue,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding item: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 4,
        title: const Text(
          "Ajouter vetement",
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
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : imageBase64 != null
                            ? Image.memory(
                                imageBytes!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.lightBlue,
                                ),
                              ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _pickImage,
                      child: Text(_isLoading ? "Processing..." : "Image"),
                    ),
                    const SizedBox(height: 30),

                    // Title Field
                    SizedBox(
                      width: 300,
                      height: 45,
                      child: TextFormField(
                        controller: _titreController,
                        decoration: InputDecoration(
                          labelText: "Titre",
                          prefixIcon: const Icon(Icons.title),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.lightBlue, width: 2),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Veuillez entrer le titre" : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category Field
                    SizedBox(
                      width: 300,
                      height: 45,
                      child: TextFormField(
                        controller: _categorieController,
                        decoration: InputDecoration(
                          labelText: "Catégorie",
                          prefixIcon: const Icon(Icons.category),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.lightBlue, width: 2),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Veuillez entrer la catégorie"
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Size Field
                    SizedBox(
                      width: 300,
                      height: 45,
                      child: TextFormField(
                        controller: _tailleController,
                        decoration: InputDecoration(
                          labelText: "Taille",
                          prefixIcon: const Icon(Icons.format_size),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.lightBlue, width: 2),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Veuillez entrer la taille" : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Brand Field
                    SizedBox(
                      width: 300,
                      height: 45,
                      child: TextFormField(
                        controller: _marqueController,
                        decoration: InputDecoration(
                          labelText: "Marque",
                          prefixIcon: const Icon(Icons.branding_watermark),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.lightBlue, width: 2),
                          ),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Veuillez entrer la marque" : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Price Field
                    SizedBox(
                      width: 300,
                      height: 45,
                      child: TextFormField(
                        controller: _prixController,
                        decoration: InputDecoration(
                          labelText: "Prix",
                          prefixIcon: const Icon(Icons.attach_money),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Colors.lightBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.lightBlue, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? "Please enter a price" : null,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Add Clothing Button
                    SizedBox(
                      width: 300,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addVetement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          foregroundColor:
                              Colors.white, // Set text color to white
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Valider",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
