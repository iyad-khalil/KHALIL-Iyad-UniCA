import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iyad/acheter/detailsvetements.dart';

class AcheterScreen extends StatefulWidget {
  @override
  State<AcheterScreen> createState() => _AcheterScreenState();
}

class _AcheterScreenState extends State<AcheterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _vetements = [];

  @override
  void initState() {
    super.initState();
    _fetchVetements();
  }

  Future<void> _fetchVetements() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('vetements').get();
      setState(() {
        _vetements = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['docId'] = doc.id; // Add Firestore document ID
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error fetching vetements: $e');
      // Show error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching items: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 4,
        title: const Text(
          'Vêtements à Acheter',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _vetements.isEmpty
          ? const Center(child: Text("Aucun vêtement disponible"))
          : ListView.builder(
              itemCount: _vetements.length,
              itemBuilder: (context, index) {
                final item = _vetements[index];
                final String? base64Image = item['imagebase64'];
                final Uint8List? decodedImage = base64Image != null
                    ? base64Decode(base64Image.split(',').last)
                    : null;

                return GestureDetector(
                  onTap: () {
                    // Navigate to the detail screen with the item data and document ID
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          title: item['titre'] ?? "Titre non disponible",
                          category:
                              item['categorie'] ?? "Catégorie non disponible",
                          size: item['taille'] ?? "Taille inconnue",
                          brand: item['marque'] ?? "Marque inconnue",
                          price: item['prix'] != null
                              ? '${item['prix']}€'
                              : 'Inconnu',
                          image: decodedImage,
                          vetementDocId:
                              item['docId'], // Pass document ID to DetailScreen
                        ),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (decodedImage != null)
                            Center(
                              child: Image.memory(
                                decodedImage,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Center(
                              child: Text(
                                "Aucune image disponible",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            item['titre'] ?? "Nom du produit",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Taille: ${item['taille'] ?? 'Inconnu'}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "Prix: ${item['prix'] != null ? '${item['prix']}€' : 'Inconnu'}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
