import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/user_screens/my_cart_functionality.dart';

class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  _MyCartPageState createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  User? user = FirebaseAuth.instance.currentUser;
  num totalamt = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 253, 251, 251)),
              width: double.infinity,
              height: 140,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color.fromARGB(255, 214, 0, 0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Text(
                    'My Cart',
                    style: GoogleFonts.salsa(
                      textStyle: const TextStyle(fontSize: 38),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('carts')
                      .doc(user?.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      log('position1');
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      log('position2');
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData ||
                        !snapshot.data!.exists ||
                        snapshot.data!.data() == null) {
                      log('position3');
                      return const Center(
                        child: Text('Cart is empty.'),
                      );
                    }

                    // Extract and display cart items
                    Map<String, dynamic> cartData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    List<dynamic> cartItems = cartData['cart-items'];
                    totalamt = 0;

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> cartItemMap = cartItems[index];

                        // Assuming 'item-id' field names in your documents
                        String? itemId = cartItemMap['item-id'];

                        if (itemId == null) {
                          log('position4');
                          // Handle the case where 'item-id' or 'cook-id' is null
                          return const SizedBox.shrink();
                        }

                        return FutureBuilder<DocumentSnapshot>(
                          // Fetch details for each item in the cart
                          future: FirebaseFirestore.instance
                              .collection('menu')
                              .doc(itemId)
                              .get(),
                          builder: (context, itemSnapshot) {
                            if (itemSnapshot.connectionState ==
                                ConnectionState.done) {
                              log('position5');
                              Map<String, dynamic>? itemData = itemSnapshot.data
                                  ?.data() as Map<String, dynamic>?;

                              if (itemData == null) {
                                // Handle the case where item data is null
                                return const SizedBox.shrink();
                              }

                              return FutureBuilder<DocumentSnapshot>(
                                // Fetch details for the cook of each item
                                future: FirebaseFirestore.instance
                                    .collection('cooks')
                                    .doc(itemData['cook-id'])
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<DocumentSnapshot>
                                        cookSnapshot) {
                                  if (cookSnapshot.connectionState ==
                                      ConnectionState.done) {
                                    log('position6');
                                    Map<String, dynamic>? cookData =
                                        cookSnapshot.data?.data()
                                            as Map<String, dynamic>?;

                                    if (cookData == null) {
                                      // Handle the case where cook data is null
                                      return const SizedBox.shrink();
                                    }
                                    log('positionfinal');
                                    totalamt += itemData['Price'] *
                                        cartItemMap['quantity'];
                                    return CartItemDesign(
                                      cookName:
                                          cookData['name'] ?? 'Unknown Cook',
                                      name: itemData['Name'] ?? 'Unknown Item',
                                      price: itemData['Price'] ?? 0,
                                      quantity: cartItemMap['quantity'] ?? 0,
                                      imageUrl: itemData['image'] ?? '',
                                      itemId: itemData['item-id'],
                                      
                                    );
                                  } else {
                                    return Container();
                                  }
                                },
                              );
                            } else {
                              return Container();
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.97,
              height: 130,
              child: Column(
                children: [
                  SizedBox(
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        StreamBuilder<num>(
                          stream: calculateTotalAmountStream(user!.uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            final totalAmount = snapshot.data ?? 0;
                            return Row(
                              children: [
                                const Text(
                                  'Total Amount:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  totalAmount.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22),
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await handleCheckout();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 1),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 116, 33, 33)),
                      height: 60,
                      width: double.infinity,
                      child: const Center(
                        child: Text(
                          'Checkout',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleCheckout() async {
    // Your checkout logic goes here

    // Delete the cart document
    await FirebaseFirestore.instance
        .collection('carts')
        .doc(user?.uid)
        .delete();
  }

  Stream<num> calculateTotalAmountStream(String userId) {
    try {
      return FirebaseFirestore.instance
          .collection('carts')
          .doc(userId)
          .snapshots()
          .asyncMap((cartSnapshot) async {
        if (!cartSnapshot.exists || cartSnapshot.data() == null) {
          // Return 0 if cart data is not found
          return 0;
        }

        Map<String, dynamic> cartData =
            cartSnapshot.data() as Map<String, dynamic>;
        List<dynamic> cartItems = cartData['cart-items'];

        num totalAmount = 0;

        for (var cartItem in cartItems) {
          String? itemId = cartItem['item-id'];
          int? quantity = cartItem['quantity'];

          if (itemId == null || quantity == null) {
            continue;
          }

          DocumentSnapshot itemSnapshot = await FirebaseFirestore.instance
              .collection('menu')
              .doc(itemId)
              .get();

          if (!itemSnapshot.exists || itemSnapshot.data() == null) {
            throw Exception("Item data not found for item ID: $itemId");
          }

          Map<String, dynamic> itemData =
              itemSnapshot.data() as Map<String, dynamic>;
          num price = itemData['Price'];

          num subtotal = price * quantity;

          totalAmount += subtotal;
        }

        return totalAmount;
      });
    } catch (e) {
      // Handle any errors
      print("Error calculating total amount: $e");
      throw e;
    }
  }
}

//DESIGN OF THE CARD THAT WILL TAKE THE INPUT NAME,COOKNAME,QUANTITY,PRICE,IMAGEURL AND DISPLAY IT BASED ON THE NUMBER OF ELEMENTS IN THE ARRAY OF CART-ITEMS
