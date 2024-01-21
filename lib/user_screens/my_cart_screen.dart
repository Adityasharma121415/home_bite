import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  _MyCartPageState createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  User? user = FirebaseAuth.instance.currentUser;
  num totalamt=0;
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              decoration: const BoxDecoration(color: Color.fromARGB(255, 253, 251, 251)),
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
            SizedBox(
              width: double.infinity,
              height: 550,
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
                  totalamt=0;

                  return ListView.builder(padding: EdgeInsets.zero,
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
                                  totalamt+=itemData['Price']*cartItemMap['quantity'];
                                  return CartItemDesign(
                                    cookName:
                                        cookData['name'] ?? 'Unknown Cook',
                                    name: itemData['Name'] ?? 'Unknown Item',
                                    price: itemData['Price'] ?? 0,
                                    quantity: cartItemMap['quantity'] ?? 0,
                                    imageUrl: itemData['image'] ?? '',
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
            SizedBox(
              width: double.infinity,
              height: 130,
              child: Column(children: [
                 SizedBox(height: 60,
                  child: Row( mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text('Total Amount',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 22),),
                    Text('Rs $totalamt',style: const TextStyle(fontWeight: FontWeight.w700,fontSize: 22),),
                  ],
                ),),
                
                GestureDetector(
                  onTap: () async {
                    await handleCheckout();
                  },
                  child: Container(margin: const EdgeInsets.symmetric(horizontal: 9,vertical: 1),
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
                    )),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> handleCheckout() async {
  // Your checkout logic goes here

  // Delete the cart document
  await FirebaseFirestore.instance.collection('carts').doc(user?.uid).delete();
}
}






//DESIGN OF THE CARD THAT WILL TAKE THE INPUT NAME,COOKNAME,QUANTITY,PRICE,IMAGEURL AND DISPLAY IT BASED ON THE NUMBER OF ELEMENTS IN THE ARRAY OF CART-ITEMS
class CartItemDesign extends StatelessWidget {
  const CartItemDesign({
    super.key,
    required this.name,
    required this.cookName,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  final String name;
  final String cookName;
  final int quantity;
  final int price;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 233, 235, 237),
        ),
        width: double.infinity,
        height: 126, // Set the desired height for the container
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
                        name,
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
                        cookName,
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
                        'Quantity: $quantity',
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
                        '$price',
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
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        imageUrl,
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
      ),
    );
  }
}
