import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({Key? key}) : super(key: key);

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
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

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var orderData =
                          orders[index].data() as Map<String, dynamic>;

                      return OrderItemDesign(
                        cookName: '',
                        orderId: orderData['order-id'] ?? '',
                        status: orderData['status'] ?? '',
                        timestamp: orderData['timestamp'] ??
                            Timestamp.fromDate(DateTime.now()),
                        totalPrice: (orderData['total-price'] ?? 0).toDouble(),
                        items: orderData['items'] ?? [],
                      );
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
      return await FirebaseFirestore.instance
          .collection('orders')
          .where('user-id', isEqualTo: 'dI98g5eWiNVce6U3zyJqz90ySPp1')
          .get();
    } catch (error) {
      print('Error fetching orders: $error');
      throw error;
    }
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
    required  this.cookName,
  }) : super(key: key);

  final String orderId;
  final String status;
  final Timestamp timestamp;
  final double totalPrice;
  final List<dynamic> items;
  final String cookName;

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
              child: Text(
                'Status: $status',
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
                'Cook: $cookName',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Padding(
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