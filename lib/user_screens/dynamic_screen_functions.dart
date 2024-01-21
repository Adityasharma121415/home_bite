// ignore_for_file: file_names

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class EachItemListElement extends StatefulWidget {
  const EachItemListElement({
    required this.name,
    required this.cookName,
    required this.location,
    required this.price,
    required this.rating,
    required this.image,
    required this.itemid,
    super.key,
  });

  final String cookName;
  final String location;
  final int price;
  final double rating;
  final String name;
  final String image;
  final String itemid;

  @override
  State<EachItemListElement> createState() {
    return _EachItemListElementState();
  }
}

class _EachItemListElementState extends State<EachItemListElement> {
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    initializeItemCount();
  }

  void initializeItemCount() async {
    try {
      String userId = getCurrentUserId();
      DocumentSnapshot cartSnapshot = await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .get();

      if (cartSnapshot.exists) {
        Map<String, dynamic>? cartData =
            cartSnapshot.data() as Map<String, dynamic>?;

        if (cartData != null && cartData['cart-items'] != null) {
          // Calculate itemCount based on the quantity of items in the cart

          for (Map<String, dynamic> item in cartData['cart-items']) {
            if (item['item-id'] == widget.itemid) {
              setState(() {
                itemCount = item['quantity'];
              });
              break;
            }
          }
        }
      }
    } catch (e) {
      log('Error initializing item count: $e');
    }
  }

  @override
  Widget build(context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: const Border.symmetric(
            horizontal: BorderSide(style: BorderStyle.solid)),
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(0.0),
      ),
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                  width: 60,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      widget.name,
                      style: GoogleFonts.robotoSlab(
                          fontSize: 18,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w800),
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        const Icon(
                          Icons.star_half_rounded,
                          color: Color.fromARGB(255, 210, 203, 20),
                        ),
                        Text(
                          widget.rating.toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(Icons.currency_rupee,
                        color: Color.fromARGB(255, 1, 0, 3), size: 22),
                    Text(
                      widget.price.toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(Icons.person_rounded,
                        color: Color.fromARGB(255, 24, 121, 7), size: 22),
                    Text(
                      widget.cookName,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                        ),
                        const Icon(Icons.my_location_rounded,
                            color: Color.fromARGB(255, 231, 4, 4), size: 21),
                        Text(
                          widget.location,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.image,
                      alignment: Alignment.topRight,
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  itemCount == 0
                      ? ClipRRect(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(30),
                          ),
                          child: Container(
                            color: const Color.fromARGB(255, 8, 108, 63),
                            width: 99,
                            height: 35,
                            child: TextButton(
                              onPressed: () {
                                // Implement your add to cart logic here
                                // You can update the state or perform any other actions

                                setState(() {
                                  itemCount++;
                                });
                                addToCart(widget.itemid, itemCount);
                              },
                              child: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 250, 251, 250),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  itemCount--;
                                });
                                addToCart(widget.itemid, itemCount);
                              },
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Color.fromARGB(255, 178, 37, 27),
                              ),
                            ),
                            Text(
                              '$itemCount',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  itemCount++;
                                });
                                addToCart(widget.itemid, itemCount);
                              },
                              icon: const Icon(
                                Icons.add_circle,
                                color: Color.fromARGB(255, 27, 103, 29),
                              ),
                            ),
                          ],
                        ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

// Assume you have a function to get the current user ID
String getCurrentUserId() {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid ?? '';
}

Future<void> addToCart(String itemId, int quantity) async {
  try {
    String userId = getCurrentUserId();

    DocumentSnapshot cartSnapshot =
        await FirebaseFirestore.instance.collection('carts').doc(userId).get();

    // Explicitly cast to Map<String, dynamic>
    Map<String, dynamic>? cartData =
        (cartSnapshot.data() as Map<String, dynamic>?);

    // If cartData is null, initialize it as an empty map
    cartData ??= {'user-id': userId, 'cart-items': []};

    // Check if the item with itemId already exists in the cart
    bool itemExists = false;
    for (Map<String, dynamic> item in cartData['cart-items'] ?? []) {
      if (item['item-id'] == itemId) {
        if (quantity > 0) {
          item['quantity'] = quantity;
        } else {
          // If quantity is 0, remove the item from the array
          cartData['cart-items']?.remove(item);
        }
        itemExists = true;
        break;
      }
    }

    // If the item doesn't exist and quantity is greater than 0, add a new item to the cart
    if (!itemExists && quantity > 0) {
      cartData['cart-items']?.add({'item-id': itemId, 'quantity': quantity});
    }

    // If the cart array is empty, delete the entire document
    if ((cartData['cart-items'] as List).isEmpty) {
      await FirebaseFirestore.instance.collection('carts').doc(userId).delete();
    } else {
      // Save updated cart data back to Firestore
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .set(cartData);
    }
  } catch (e) {
    log('Error adding item to cart: $e');
  }
}
