class FoodDataStructure {
  const FoodDataStructure({required this.foodname,required this.price,required this.rating,required this.cookName,required this.location, this.imageurl='assets/images/veg.jpg'});
   

  final String foodname;
  final int    price;
  final double rating;
  final String cookName;
  final String location;
  final String imageurl;

}