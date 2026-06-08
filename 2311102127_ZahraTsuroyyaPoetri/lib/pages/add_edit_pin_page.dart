import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AddEditPinPage extends StatefulWidget {
  final String? docId;
  final String? title;
  final String? imageUrl;
  final String? description;

  const AddEditPinPage({
    super.key,
    this.docId,
    this.title,
    this.imageUrl,
    this.description,
  });

  @override
  State<AddEditPinPage> createState() =>
      _AddEditPinPageState();
}

class _AddEditPinPageState
    extends State<AddEditPinPage> {
  final titleController =
      TextEditingController();

  final imageController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  final firestore =
      FirestoreService();

  bool isLoading = false;

  bool get isEdit =>
      widget.docId != null;

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      titleController.text =
          widget.title ?? '';

      imageController.text =
          widget.imageUrl ?? '';

      descriptionController.text =
          widget.description ?? '';
    }

    imageController.addListener(() {
      setState(() {});
    });
  }

  Future<void> savePin() async {
    if (titleController.text
            .trim()
            .isEmpty ||
        imageController.text
            .trim()
            .isEmpty ||
        descriptionController.text
            .trim()
            .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text("Semua field wajib diisi"),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      if (isEdit) {
        await firestore.updatePin(
          id: widget.docId!,
          title:
              titleController.text.trim(),
          imageUrl:
              imageController.text.trim(),
          description:
              descriptionController.text
                  .trim(),
        );

        await NotificationService
            .showNotification(
          title: "Pinspiration",
          body:
              "Inspirasi berhasil diperbarui",
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Inspirasi berhasil diperbarui",
            ),
          ),
        );
      } else {
        await firestore.addPin(
          title:
              titleController.text.trim(),
          imageUrl:
              imageController.text.trim(),
          description:
              descriptionController.text
                  .trim(),
        );

        await NotificationService
            .showNotification(
          title: "Pinspiration",
          body:
              "Inspirasi berhasil ditambahkan",
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Inspirasi berhasil ditambahkan",
            ),
          ),
        );
      }

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text("Terjadi error\n$e"),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget imagePreview() {
    if (imageController.text.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(
            Icons.image,
            size: 60,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(20),
      child: Image.network(
        imageController.text,
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder:
            (_, __, ___) =>
                Container(
          height: 220,
          color: Colors.grey.shade200,
          child: const Center(
            child: Text(
              "URL gambar tidak valid",
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFAFAFA),

      appBar: AppBar(
        backgroundColor: Colors.white,

        title: Text(
          isEdit
              ? "Edit Inspirasi"
              : "Tambah Inspirasi",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            imagePreview(),

            const SizedBox(height: 20),

            TextField(
              controller:
                  titleController,
              decoration:
                  InputDecoration(
                labelText:
                    "Judul Inspirasi",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  imageController,
              decoration:
                  InputDecoration(
                labelText:
                    "URL Gambar",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              15),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller:
                  descriptionController,
              maxLines: 5,
              decoration:
                  InputDecoration(
                labelText:
                    "Deskripsi",
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              15),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                          0xffE60023),

                  foregroundColor:
                      Colors.white,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius
                            .circular(
                                15),
                  ),
                ),

                onPressed:
                    isLoading
                        ? null
                        : savePin,

                child:
                    isLoading
                        ? const CircularProgressIndicator(
                            color:
                                Colors
                                    .white,
                          )
                        : Text(
                            isEdit
                                ? "UPDATE"
                                : "SIMPAN",
                          ),
              ),
            )
          ],
        ),
      ),
    );
  }
}