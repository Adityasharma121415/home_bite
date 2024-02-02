import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
final TextEditingController _nameController = TextEditingController();
final TextEditingController _priceController = TextEditingController();
final TextEditingController _ratingController = TextEditingController();

void addNewItem(BuildContext context, String categoryId, String cookId) {
  File? newItemPic;
  bool isVeg = true;

  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 60,
                    ),
                    const Text(
                        'Select an image and fill all the details to add a new Item.',
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center),
                    const SizedBox(
                      height: 20,
                    ),
                    CupertinoButton(
                      onPressed: () async {
                        XFile? selectedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (selectedFile != null) {
                          File convertedFile = File(selectedFile.path);
                          setState(() {
                            newItemPic = convertedFile;
                          });
                        }
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          color: Colors.grey,
                          width: 140,
                          height: 140,
                          child: (newItemPic == null)
                              ? Image.asset(
                                  'assets/images/imageplaceholder.png')
                              : Image.file(
                                  newItemPic!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the Item Name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the Price';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(labelText: 'Rating'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter the Rating';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    CheckboxListTile(
                      title: const Text('Veg Food'),
                      value: isVeg,
                      onChanged: (newValue) {
                        setState(() {
                          isVeg = newValue!;
                        });
                      },
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            _nameController.clear();
                            _priceController.clear();
                            _ratingController.clear();
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              if (newItemPic != null) {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (BuildContext context) {
                                    return const Dialog(
                                      child: Padding(
                                        padding: EdgeInsets.all(20.0),
                                        child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(width: 20),
                                            Text("Uploading..."),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                                UploadTask uploadTask = FirebaseStorage.instance
                                    .ref()
                                    .child("foodimages")
                                    .child("menuimages")
                                    .child('${const Uuid().v1()}.jpg')
                                    .putFile(newItemPic!);

                                TaskSnapshot taskSnapshot = await uploadTask;
                                String downloadURL =
                                    await taskSnapshot.ref.getDownloadURL();
                                await uploadItemToFirestore(
                                    categoryId, cookId, downloadURL, isVeg);
                                newItemPic = null;
                                _nameController.clear();
                                _priceController.clear();
                                _ratingController.clear();

                                // ignore: use_build_context_synchronously
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                showErrorDialog(
                                    context, 'Please select an image.');
                              }
                            }
                          },
                          child: const Text('Upload Item'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> uploadItemToFirestore(
    String categoryId, String cookId, String downloadURL, bool isVeg) async {
  String itemName = _nameController.text;
  int itemPrice = int.parse(_priceController.text);
  double itemRating = double.parse(_ratingController.text);
  String imageURL = downloadURL;

  CollectionReference menuCollection =
      FirebaseFirestore.instance.collection('menu');

  try {
    DocumentReference newItemRef = await menuCollection.add({
      'Name': itemName,
      'Price': itemPrice,
      'Rating': itemRating,
      'category-id': categoryId,
      'cook-id': cookId,
      'image': imageURL,
      'isVeg': isVeg, // Added field for veg or non-veg
    });

    String newItemId = newItemRef.id;
    await newItemRef.update({'item-id': newItemId});

    log('Item uploaded to Firestore successfully!');
  } catch (error) {
    log('Error uploading item to Firestore: $error');
  }
}
