import 'package:flutter/material.dart';
import 'package:home_bite/food_item_list.dart';
import 'package:home_bite/models/food_data.dart';

class FoodItems extends StatefulWidget {
  const FoodItems({super.key});

  @override
  State<FoodItems> createState() {
    return _FoodItemsState();
  }
}

class _FoodItemsState extends State<FoodItems> {
  @override
  Widget build(context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 205,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                          Color.fromARGB(255, 240, 192, 192),
                        ),
                        shape: MaterialStatePropertyAll(
                          CircleBorder(eccentricity: 0),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 214, 0, 0),
                      ),
                    ),
                    const SizedBox(
                      child: Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 35,
                          ),
                          SizedBox(width: 15),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Text(
                  'North Indian',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 68,
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      textAlignVertical: TextAlignVertical.bottom,
                      controller: SearchController(),
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        hintText: 'Enter your search term',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 560,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...fooditems.map(
                    (element) {
                      return FoodItemsList(element);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
