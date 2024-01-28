import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentOrders extends StatefulWidget {
  const CurrentOrders({Key? key}) : super(key: key);

  @override
  _CurrentOrdersState createState() => _CurrentOrdersState();
}

class _CurrentOrdersState extends State<CurrentOrders> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Orders'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: fetchOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final orders = snapshot.data?.docs;

                  if (orders == null || orders.isEmpty) {
                    return Center(
                      child: Text('No orders found.'),
                    );
                  }

                  // Convert Timestamp to DateTime and sort in ascending order
                  orders.sort((a, b) => (a['timestamp'] as Timestamp)
                      .toDate()
                      .compareTo((b['timestamp'] as Timestamp).toDate()));

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var orderData =
                          orders[index].data() as Map<String, dynamic>;

                      // Check if cook-id matches the current user's id and status is pending
                      if (orderData['cook-id'] == user?.uid &&
                          orderData['status'] == 'pending') {
                        return OrderItemDesign(
                          orderId: orderData['order-id'] ?? '',
                          status: orderData['status'] ?? '',
                          timestamp: orderData['timestamp'] ??
                              Timestamp.fromDate(DateTime.now()),
                          totalPrice:
                              (orderData['total-price'] ?? 0).toDouble(),
                          items: orderData['items'] ?? [],
                          markAsCompleted: () {
                            // Mark order as completed function
                            markOrderAsCompleted(orderData['order-id']);
                          },
                        );
                      } else {
                        // If conditions are not met, return an empty container
                        return Container();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<QuerySnapshot> fetchOrders() async {
    try {
      // Modify the query to include conditions for cook-id and status
      return await FirebaseFirestore.instance
          .collection('orders')
          .where('cook-id', isEqualTo: user?.uid)
          .where('status', isEqualTo: 'pending')
          .get();
    } catch (error) {
      print('Error fetching orders: $error');
      throw error;
    }
  }

  // Function to mark an order as completed
  void markOrderAsCompleted(String orderId) {
    // You can implement the logic here to update the order status in Firestore
    // For example, you can use the orderId to update the 'status' field to 'completed'
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': 'completed'}).then((value) {
      // Success, you can add any additional logic here
      print('Order marked as completed successfully!');
      // You may want to update the UI or perform other actions after marking as completed
      setState(() {});
    }).catchError((error) {
      // Handle errors, if any
      print('Error marking order as completed: $error');
    });
  }
}

class OrderItemDesign extends StatelessWidget {
  const OrderItemDesign({
    Key? key,
    required this.orderId,
    required this.status,
    required this.timestamp,
    required this.totalPrice,
    required this.items,
    required this.markAsCompleted,
  }) : super(key: key);

  final String orderId;
  final String status;
  final Timestamp timestamp;
  final double totalPrice;
  final List<dynamic> items;
  final VoidCallback markAsCompleted;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Order ID: $orderId',
                style: TextStyle(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    'Status: $status',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  TextButton.icon(
                    onPressed: markAsCompleted,
                    icon: Icon(Icons.download_done,size: 20,color: Colors.red,),
                    label: Text('Prepared ?',style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Date: ${timestamp.toDate().toString()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Items:',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (var item in items) ...[
              ListTile(
                title: Text(item['itemName'] ?? 'Unknown Item'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item ID: ${item['item-id'] ?? ''}'),
                    Text('Quantity: ${item['quantity'] ?? 0}'),
                    Text('Price: Rs ${item['itemPrice'] ?? 0}'),
                  ],
                ),
                trailing: SizedBox(
                  width: 50,
                  height: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['image'] ?? '', // Use the 'image' field
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total Amount: Rs $totalPrice',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}