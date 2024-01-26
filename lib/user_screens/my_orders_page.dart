import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  // User? user = FirebaseAuth.instance.currentUser;

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
                    'My Orders',
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
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('user-id',
                          isEqualTo: 'dI98g5eWiNVce6U3zyJqz90ySPp1')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData && snapshot.data != null) {
                        if (snapshot.data!.docs.isEmpty) {
                          // Display a message or widget when no items are found
                          return const Center(
                            child: Text("No items found in this category."),
                          );
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> orders =
                                snapshot.data!.docs[index].data();
                            List<dynamic> itemList = orders['items'];

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('cooks')
                                  .doc(orders['cook-id'])
                                  .get(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot>
                                      cookSnapshot) {
                                if (cookSnapshot.connectionState ==
                                    ConnectionState.done) {
                                  Map<String, dynamic>? cookData =
                                      cookSnapshot.data?.data()
                                          as Map<String, dynamic>?;

                                  return MyOrderPageItemLists(
                                    cookName: cookData!['name'],
                                    listOfItems: itemList,
                                    orderid: orders['order-id'],
                                    price: orders['total-price'],
                                    timestamp: orders['timestamp'],
                                  );
                                } else {
                                  return MyOrderPageItemLists(
                                    cookName: 'loading..',
                                    listOfItems: itemList,
                                    orderid: orders['order-id'],
                                    price: orders['total-price'],
                                    timestamp: orders['timestamp'],
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                    }
                    return Container();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyOrderPageItemLists extends StatefulWidget {
  const MyOrderPageItemLists({
    super.key,
    required this.listOfItems,
    required this.cookName,
    required this.price,
    required this.timestamp,
    required this.orderid,
  });

  final List<dynamic> listOfItems;
  final String orderid;
  final String cookName;
  final int price;
  final Timestamp timestamp;

  @override
  State<MyOrderPageItemLists> createState() => _MyOrderPageItemListsState();
}

class _MyOrderPageItemListsState extends State<MyOrderPageItemLists> {
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(margin: EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.blue),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true, // Set shrinkWrap to true
                  padding: EdgeInsets.zero,
                  itemCount: widget.listOfItems.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> itemMap = widget.listOfItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Text(itemMap['itemName'],
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                  'Rs ${itemMap['itemPrice'].toString()} * ${itemMap['quantity'].toString()}',
                                  style:const  TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                child: Image.network(itemMap['image']),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                 SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.orderid,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w600)),
                           Text(widget.timestamp.toDate().toString(),
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w600)),
                        ],
                      ),
                       Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.cookName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          Text(widget.price.toString(),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
