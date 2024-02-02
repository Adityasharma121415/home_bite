// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/user_screens/homepage.dart';
import 'package:home_bite/user_screens/my_cart_functionality.dart';

class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  State<MyCartPage> createState() {
    return _MyCartPageState();
  }
}

class _MyCartPageState extends State<MyCartPage> {
  User? user = FirebaseAuth.instance.currentUser;
  // num totalamt = 0;
  List<dynamic>? cartToOrder;
  num? checkoutamount;

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
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (!snapshot.hasData ||
                        !snapshot.data!.exists ||
                        snapshot.data!.data() == null) {
                      return Center(
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Image.asset('assets/images/emptycart.webp'),
                        ),
                      );
                    }

                    // Extract and display cart items
                    Map<String, dynamic> cartData =
                        snapshot.data!.data() as Map<String, dynamic>;

                    List<dynamic> cartItems = cartData['cart-items'];
                    cartToOrder = cartItems;
                    // totalamt = 0;

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> cartItemMap = cartItems[index];

                        // Assuming 'item-id' field names in your documents
                        String? itemId = cartItemMap['item-id'];

                        if (itemId == null) {
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
                                    Map<String, dynamic>? cookData =
                                        cookSnapshot.data?.data()
                                            as Map<String, dynamic>?;

                                    if (cookData == null) {
                                      // Handle the case where cook data is null
                                      return const SizedBox.shrink();
                                    }

                                    // totalamt += itemData['Price'] *
                                    //     cartItemMap['quantity'];
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
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            final totalAmount = snapshot.data ?? 0;
                            checkoutamount = totalAmount;
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
                                  'Rs $totalAmount',
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
                      if (cartToOrder != null && checkoutamount != null) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Text("Placing Order..."),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        await handleCheckout(
                            cartToOrder, checkoutamount, user!.uid);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Order placed successfully!'),
                        ));
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ));
                      }
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

  Future<void> handleCheckout(
      List<dynamic>? cartToOrder, num? checkoutamount, String userId) async {
    List<Map<String, dynamic>> extractedElements = [];
    String cookId = "";

    if (cartToOrder != null) {
      for (Map<String, dynamic> elements in cartToOrder) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('menu')
            .doc(elements['item-id'])
            .get();

        Map<String, dynamic> menuData = snapshot.data() as Map<String, dynamic>;
        cookId = menuData['cook-id'];

        Map<String, dynamic> menuDataOrdered = {
          'itemName': menuData['Name'],
          'itemPrice': menuData['Price'],
          'image': menuData['image'],
          'item-id': menuData['item-id'],
          'quantity': elements['quantity'],
        };
        extractedElements.add(menuDataOrdered);
      }
      Map<String, dynamic> dataToBeUploaded = {
        'items': extractedElements,
        'status': 'pending',
        'timestamp': DateTime.now(),
        'total-price': checkoutamount,
        'cook-id': cookId,
        'user-id': userId,
        'userLocation': 'TobeUpdated',
      };
      // Your checkout logic goes here
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(dataToBeUploaded);
      String orderId = docRef.id;
      await docRef.update({'order-id': orderId});
      // Delete the cart document
      await FirebaseFirestore.instance
          .collection('carts')
          .doc(user?.uid)
          .delete();
    }
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
