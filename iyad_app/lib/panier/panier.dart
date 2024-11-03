import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> cartItems = [];
  double total = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot panierSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('panier')
            .get();

        Map<String, Map<String, dynamic>> itemsMap = {};
        double calculatedTotal = 0.0; // Reset total

        for (var panierDoc in panierSnapshot.docs) {
          var panierData = panierDoc.data() as Map<String, dynamic>;
          String? vetementId = panierData['vetementId'];

          if (vetementId != null) {
            DocumentSnapshot vetementDoc = await FirebaseFirestore.instance
                .collection('vetements')
                .doc(vetementId)
                .get();

            if (vetementDoc.exists) {
              var vetementData = vetementDoc.data() as Map<String, dynamic>;
              double itemPrice =
                  double.tryParse(vetementData['prix'].toString()) ?? 0.0;

              if (itemsMap.containsKey(vetementId)) {
                // Increase quantity if item already exists
                itemsMap[vetementId]!['quantity'] += 1;
              } else {
                // Add item with quantity 1 if it doesn’t exist
                itemsMap[vetementId] = {
                  'id': panierDoc.id,
                  'titre': vetementData['titre'] ?? 'Titre non disponible',
                  'taille': vetementData['taille'] ?? 'Non spécifié',
                  'prix': itemPrice,
                  'imagebase64': vetementData['imagebase64'] ?? '',
                  'quantity': 1,
                };
              }
              // Calculate total based on quantity
              calculatedTotal += itemPrice;
            } else {
              print("Vetement document not found: $vetementId");
            }
          } else {
            print("vetementId is null for panier document: ${panierDoc.id}");
          }
        }

        setState(() {
          cartItems = itemsMap.values.toList(); // Convert map to list
          total = calculatedTotal; // Update total
        });
      } catch (e) {
        print("Error fetching cart items: $e");
      }
    } else {
      print("No user is currently signed in.");
    }
  }

  Future<void> _removeItem(String docId, double price, int quantity) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('panier')
            .doc(docId)
            .delete();

        setState(() {
          total -= price * quantity;
          cartItems.removeWhere((item) => item['id'] == docId);
        });
        print("Item removed: $docId");
      } catch (e) {
        print("Error removing item: $e");
      }
    } else {
      print("No user is currently signed in.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        elevation: 4,
        title: const Text(
          'Mon Panier',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      var item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        child: ListTile(
                          leading: item['imagebase64'] is String
                              ? Image.memory(
                                  base64Decode(item['imagebase64']),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 30,
                                    color: Colors.grey,
                                  ),
                                ),
                          title: Text(
                            item['titre'] ?? 'Titre non disponible',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.lightBlue,
                            ),
                          ),
                          subtitle: Text(
                            "Taille: ${item['taille'] ?? 'Non spécifié'} | Prix: ${item['prix']} \$"
                            "${item['quantity'] > 1 ? ' | Quantité: ${item['quantity']}' : ''}",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _removeItem(
                              item['id'],
                              item['prix'],
                              item['quantity'],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total général:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
