import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  User? user = FirebaseAuth.instance.currentUser;

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
                      .where('user-id', isEqualTo: user!.uid)
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

                        // Sort the data by timestamp
                        final sortedDocs = snapshot.data!.docs
                          ..sort((a, b) {
                            final aTimestamp = a['timestamp'] as Timestamp;
                            final bTimestamp = b['timestamp'] as Timestamp;
                            return bTimestamp.compareTo(aTimestamp);
                          });

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: sortedDocs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> orders =
                                sortedDocs[index].data();
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
                                    status: orders['status'],
                                  );
                                } else {
                                  return MyOrderPageItemLists(
                                    cookName: 'loading..',
                                    listOfItems: itemList,
                                    orderid: orders['order-id'],
                                    price: orders['total-price'],
                                    timestamp: orders['timestamp'],
                                    status: orders['status'],
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
    required this.status,
  });

  final List<dynamic> listOfItems;
  final String orderid;
  final String cookName;
  final int price;
  final Timestamp timestamp;
  final String status;
  @override
  State<MyOrderPageItemLists> createState() => _MyOrderPageItemListsState();
}

class _MyOrderPageItemListsState extends State<MyOrderPageItemLists> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 208, 212, 215)),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  ' ${widget.status.toUpperCase()}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: (widget.status == 'pending')
                          ? Color.fromARGB(255, 203, 53, 42)
                          : const Color.fromARGB(255, 46, 168, 50)),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Order Id: ',
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(widget.orderid,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Text(
                        DateFormat.yMd()
                            .add_jm()
                            .format(widget.timestamp.toDate()),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 10,),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                itemMap['itemName'],
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Quantity: ${itemMap['quantity'].toString()}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.currency_rupee_rounded,
                                    size: 18,
                                  ),
                                  Text(
                                    itemMap['itemPrice'].toString(),
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ],
                              ),
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
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 20,
                              ),
                              Text(' ${widget.cookName}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.currency_rupee_sharp),
                              Text(
                                widget.price.toString(),
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
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
