import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailScreen extends StatefulWidget {
  final String? title;
  final String? category;
  final String? size;
  final String? brand;
  final String? price;
  final Uint8List? image;
  final String vetementDocId;

  const DetailScreen({
    Key? key,
    this.title,
    this.category,
    this.size,
    this.brand,
    this.price,
    this.image,
    required this.vetementDocId,
  }) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  Future<bool> _checkIfItemInCart(String userId, String vetementId) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('panier')
        .where('vetement.vetementId', isEqualTo: vetementId)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<void> addToCart() async {
    setState(() => _isLoading = true);

    try {
      User? user = _auth.currentUser;
      if (user == null) {
        _showSnackBar(
            'Veuillez vous connecter pour ajouter au panier.', Colors.red);
        return;
      }

      // Vérifier si le vêtement existe toujours
      DocumentSnapshot vetementDoc = await FirebaseFirestore.instance
          .collection('vetements')
          .doc(widget.vetementDocId)
          .get();

      if (!vetementDoc.exists) {
        _showSnackBar('Ce vêtement n\'existe plus!', Colors.red);
        return;
      }

      // Vérifier si l'article est déjà dans le panier
      bool itemExists =
          await _checkIfItemInCart(user.uid, widget.vetementDocId);
      if (itemExists) {
        // Update the quantity instead of adding a new item
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('panier')
            .where('vetement.vetementId', isEqualTo: widget.vetementDocId)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({
              'vetement.quantity': FieldValue.increment(1), // Increase quantity
            });
          }
        });

        _showSnackBar('Quantité mise à jour dans votre panier!', Colors.green);
      } else {
        // Ajouter au panier
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('panier')
            .add({'vetementId': widget.vetementDocId});

        _showSnackBar('Ajouté au panier avec succès!', Colors.green);
      }
    } catch (e) {
      _showSnackBar(
          'Erreur lors de l\'ajout au panier: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Détails du Produit',
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
        backgroundColor: Colors.lightBlue,
        automaticallyImplyLeading: false, // Disable the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.image != null)
              Center(
                child: Image.memory(
                  widget.image!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Center(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              widget.title ?? "Titre du produit",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlue,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Catégorie", widget.category),
            _buildInfoRow("Taille", widget.size),
            _buildInfoRow("Marque", widget.brand),
            _buildInfoRow(
                "Prix",
                widget.price != null
                    ? "${widget.price}"
                    : null), // Removed dollar sign
            const Spacer(),
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Ajouter au panier",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Add the "Retour" button here
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .red, // Optional: Different color for the back button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Retour",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            value ?? "Non spécifié",
            style: TextStyle(
              fontSize: 16,
              color: value == null ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
