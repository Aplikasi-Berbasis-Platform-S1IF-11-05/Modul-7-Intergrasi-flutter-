import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import 'add_edit_pin_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final auth = AuthService();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Pinspiration",
          style: TextStyle(
            color: Color(0xffE60023),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Color(0xffE60023),
            ),
            onPressed: () async {
              await auth.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                (_) => false,
              );
            },
          )
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getPins(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada inspirasi",
              ),
            );
          }

          return MasonryGridView.count(
            padding: const EdgeInsets.all(12),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final pin = docs[index];

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(0.15),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: pin['imageUrl'],
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(
                          height: 200,
                          alignment:
                              Alignment.center,
                          child:
                              const CircularProgressIndicator(),
                        ),
                        errorWidget:
                            (_, __, ___) =>
                                Container(
                          height: 200,
                          color:
                              Colors.grey.shade200,
                          child: const Icon(
                            Icons.image,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            pin['title'],
                            style:
                                const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Text(
                            pin['description'],
                            maxLines: 3,
                            overflow:
                                TextOverflow.ellipsis,
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color:
                                      Colors.orange,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddEditPinPage(
                                        docId:
                                            pin.id,
                                        title:
                                            pin['title'],
                                        imageUrl:
                                            pin['imageUrl'],
                                        description:
                                            pin['description'],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final confirm =
                                      await showDialog(
                                    context:
                                        context,
                                    builder:
                                        (_) =>
                                            AlertDialog(
                                      title:
                                          const Text(
                                        "Hapus Inspirasi",
                                      ),
                                      content:
                                          const Text(
                                        "Yakin ingin menghapus inspirasi ini?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () {
                                            Navigator.pop(
                                              context,
                                              false,
                                            );
                                          },
                                          child:
                                              const Text(
                                            "Batal",
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed:
                                              () {
                                            Navigator.pop(
                                              context,
                                              true,
                                            );
                                          },
                                          child:
                                              const Text(
                                            "Hapus",
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm !=
                                      true) {
                                    return;
                                  }

                                  await firestore
                                      .deletePin(
                                    pin.id,
                                  );

                                  await NotificationService
                                      .showNotification(
                                    title:
                                        "Pinspiration",
                                    body:
                                        "Inspirasi berhasil dihapus",
                                  );

                                  ScaffoldMessenger.of(
                                          context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Inspirasi berhasil dihapus",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xffE60023),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddEditPinPage(),
            ),
          );
        },
      ),
    );
  }
}