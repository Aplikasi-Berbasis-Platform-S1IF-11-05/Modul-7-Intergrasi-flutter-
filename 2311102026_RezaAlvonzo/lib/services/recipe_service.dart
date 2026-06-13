// Reza Alvonzo - 2311102026 
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe.dart';

class RecipeService {
  final CollectionReference _recipesCollection =
      FirebaseFirestore.instance.collection('recipes');

  // Get all recipes for current user
  Stream<QuerySnapshot> getRecipes(String userId) {
    return _recipesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add recipe
  Future<void> addRecipe(Recipe recipe) async {
    await _recipesCollection.add(recipe.toMap());
  }

  // Update recipe
  Future<void> updateRecipe(String id, Recipe recipe) async {
    await _recipesCollection.doc(id).update(recipe.toMap());
  }

  // Delete recipe
  Future<void> deleteRecipe(String id) async {
    await _recipesCollection.doc(id).delete();
  }
}
