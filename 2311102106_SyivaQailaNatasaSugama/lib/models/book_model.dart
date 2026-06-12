import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String? id;
  final String title;
  final String author;
  final String genre;
  final String description;
  final double rating;
  final int year;
  final String userId;
  final DateTime createdAt;

  BookModel({
    this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.description,
    required this.rating,
    required this.year,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'genre': genre,
      'description': description,
      'rating': rating,
      'year': year,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map, String docId) {
    return BookModel(
      id: docId,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      genre: map['genre'] ?? '',
      description: map['description'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      year: map['year'] ?? 0,
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    String? description,
    double? rating,
    int? year,
    String? userId,
    DateTime? createdAt,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      year: year ?? this.year,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
