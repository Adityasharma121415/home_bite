import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/user_screens/dynamic_screen_functions.dart';

class CartItemDesign extends StatefulWidget {
  const CartItemDesign({
    super.key,
    required this.name,
    required this.cookName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.itemId,
  });

  final String name;
  final String cookName;
  final int quantity;
  final int price;
  final String imageUrl;
  final String itemId;

  @override
  State<CartItemDesign> createState() => _CartItemDesignState();
}

class _CartItemDesignState extends State<CartItemDesign> {
  int itemCount=0;
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
            if (item['item-id'] == widget.itemId) {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Card(
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 233, 235, 237),
          ),
          width: double.infinity,
          height: 165, // Set the desired height for the container
          child: Column(
            children: [
              Row(
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
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Row(
                              children: [
                                SizedBox(
                                  width: 20,
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
                            const Icon(
                              Icons.person_rounded,
                              color: Color.fromARGB(255, 24, 121, 7),
                              size: 22,
                            ),
                            Text(
                              widget.cookName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Quantity: ${widget.quantity}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w700,
                              ),
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
                            const Icon(
                              Icons.currency_rupee,
                              color: Color.fromARGB(255, 1, 0, 3),
                              size: 22,
                            ),
                            Text(
                              '${widget.price}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
              
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 12,right: 12),
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              widget.imageUrl,
                              alignment: Alignment.topRight,
                              width: 100,
                              height: 100,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  itemCount--;
                                });
                                addToCart(widget.itemId, itemCount,context);
                              },
                              icon: const Icon(size: 20,
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
                                addToCart(widget.itemId, itemCount,context);
                              },
                              icon: const Icon(size: 20,
                                Icons.add_circle,
                                color: Color.fromARGB(255, 27, 103, 29),
                              ),
                            ),
                          ],
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
