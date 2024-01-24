import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class SellerEachItemListElement extends StatefulWidget {
  const SellerEachItemListElement({
    required this.name,
    required this.cookName,
    required this.location,
    required this.price,
    required this.rating,
    required this.image,
    required this.itemid,
    Key? key,
  }) : super(key: key);

  final String cookName;
  final String location;
  final int price;
  final double rating;
  final String name;
  final String image;
  final String itemid;

  @override
  State<SellerEachItemListElement> createState() {
    return _SellerEachItemListElementState();
  }
}

class _SellerEachItemListElementState extends State<SellerEachItemListElement> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  File? menupic;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing values
    _nameController.text = widget.name;
    _priceController.text = widget.price.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: const Border.symmetric(
            horizontal: BorderSide(style: BorderStyle.solid)),
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(0.0),
      ),
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        children: [
          Row(
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
                          widget.name,
                          style: GoogleFonts.robotoSlab(
                            fontSize: 18,
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w800,
                          ),
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
                              widget.rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w500,
                              ),
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
                        const Icon(Icons.currency_rupee,
                            color: Color.fromARGB(255, 1, 0, 3), size: 22),
                        Text(
                          widget.price.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w500,
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
                        const Icon(Icons.person_rounded,
                            color: Color.fromARGB(255, 24, 121, 7), size: 22),
                        Text(
                          widget.cookName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Icon(Icons.my_location_rounded,
                                color: Color.fromARGB(255, 231, 4, 4),
                                size: 21),
                            Text(
                              widget.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
                          widget.image,
                          fit: BoxFit.fill,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  // Initialize controllers with existing values
                  _nameController.text = widget.name;
                  _priceController.text = widget.price.toString();

                  // Show the bottom modal sheet on "Edit" button press
                  _showEditModal(context);
                },
                icon: const Icon(Icons.edit, color: Colors.green),
                label: const Text('Edit'),
              ),
              const SizedBox(
                width: 40,
              ),
              TextButton.icon(onPressed:(){
                deleteDocumentWithConfirmation(context,'menu',widget.itemid);
              },
                
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Delete'),
              ),
            ],
          )
        ],
      ),
    );
  }


void deleteDocumentWithConfirmation(
    BuildContext context, String collectionName, String documentId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this Item?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel',style: TextStyle(color: Colors.green)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              DocumentReference documentReference =
        FirebaseFirestore.instance.collection(collectionName).doc(documentId);

        await documentReference.delete(); 
              
            },
            child: const Text('Delete',style: TextStyle(color: Colors.red),),
          ),
        ],
      );
    },
  );
}


  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const Text('Tap on the image to change it and edit the fields as per requirement.',style: TextStyle(fontWeight: FontWeight.w500),textAlign: TextAlign.center),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoButton(
                          onPressed: () async {
                            XFile? selectedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (selectedFile != null) {
                              File convertedFile = File(selectedFile.path);
                              setState(() {
                                menupic = convertedFile;
                              });
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                                width: 140,
                                height: 140,
                                child: (menupic == null)
                                    ? Image.network(widget.image,
                                        fit: BoxFit.cover)
                                    : Image.file(
                                        menupic!,
                                        fit: BoxFit.cover,
                                      )),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Item Name'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter a price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            menupic = null;
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
                              if (menupic != null) {
                                UploadTask uploadTask = FirebaseStorage.instance
                                    .ref()
                                    .child("foodimages")
                                    .child("menuimages")
                                    .child('${Uuid().v1()}.jpg')
                                    .putFile(menupic!);

                                TaskSnapshot taskSnapshot = await uploadTask;
                                String downloadURL =
                                    await taskSnapshot.ref.getDownloadURL();
                                updateFirestoreData(downloadURL);
                              } else {
                                updateFirestoreData(widget.image);
                              }

                              menupic = null;
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save Changes'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void updateFirestoreData(String downloadURL) {
    String newName = _nameController.text;
    int newPrice = int.parse(_priceController.text);
    String updatedURL = downloadURL;

    CollectionReference menuCollection =
        FirebaseFirestore.instance.collection('menu');

    menuCollection.doc(widget.itemid).update(
      {
        'Name': newName,
        'Price': newPrice,
        'image': updatedURL,
      },
    ).then(
      (_) {
        print('Document updated successfully!');
      },
    ).catchError(
      (error) {
        print('Error updating document: $error');
      },
    );
  }
}
