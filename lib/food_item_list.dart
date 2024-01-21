import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home_bite/models/food_items_datastructure.dart';

class FoodItemsList extends StatefulWidget {
  const FoodItemsList(this.content, {super.key});
  final FoodDataStructure content;

  @override
  State<FoodItemsList> createState() {
    return _FoodItemsListState();
  }
}

class _FoodItemsListState extends State<FoodItemsList> {
  @override
  Widget build(context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(border:const Border.symmetric(horizontal: BorderSide(style: BorderStyle.solid)),
        
        
        color: const Color.fromARGB(255, 255, 255, 255), 
        borderRadius: BorderRadius.circular(0.0), 
      ),
      height: 160,
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
                      widget.content.foodname,
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
                      widget.content.rating.toString(),
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),],
                ),
                
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(Icons.currency_rupee,
                        color: Color.fromARGB(255, 1, 0, 3), size: 22),
                    Text(
                      widget.content.price.toString(),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    const Icon(Icons.person_rounded,
                        color: Color.fromARGB(255, 24, 121, 7), size: 22),
                    Text(
                      widget.content.cookName,
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
                    Text(' ${
                      widget.content.location}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ), ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    'assets/images/veg.jpg',
                    alignment: Alignment.topRight,
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
