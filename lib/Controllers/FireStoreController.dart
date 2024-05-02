import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:register/Auth/Auth.dart';
import 'package:register/Controllers/CloudStorageController.dart';
import 'package:register/Models/ProductInfo.dart';

import '../Models/Feedback.dart';
import '../Pages/myProducts.dart';
import '../Pages/filterProduct.dart' as filter;

class FireStoreController{

  final db = FirebaseFirestore.instance;


  Future<String> addToProductsCollection(String productName, String description, String? category) async {

    final product = <String, dynamic>{
      "ProductName": productName,
      "Description": description,
      "Category": category,
      "Owner": await Auth().getUid()
    };

    final DocumentReference docRef = await db.collection("Products").add(
        product);
    return docRef.id;
  }

  Future<String> addFCMTokenToCollection( String FCMtoken) async {

    // Create a new user with a first and last name
    final tokenInfo = <String, dynamic>{
      "UserID": await Auth().getUid(),
      "Token": FCMtoken,
    };

    final DocumentReference docRef = await db.collection("FCMToken").add(
        tokenInfo);
    return docRef.id;
  }

  Future<List<info>> getOwnedProducts() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot ownedProducts = await db.collection('Products').where('Owner', isEqualTo: user.uid).get();
      List<info> products = [];
      for (QueryDocumentSnapshot doc in ownedProducts.docs) {
        String name = doc['ProductName'];
        String category = doc['Category'];
        String description = doc['Description'];
        String productId = doc.id;

        String imageUrl = await CloudStorageController().getDownloadURL('ProductImages/$productId');

        products.add(info(productID: productId, productName: name, description: description, category: category, imageURL: imageUrl));
      }
      return products;
    } else {
      throw 'Not logged in.';
    }
  }


  Future<void> deleteProduct(info product) async {
    try {
      CloudStorageController().deleteImage('ProductImages/${product.productID}');
      DocumentReference productRef = FirebaseFirestore.instance.collection('Products').doc(product.productID);
      await productRef.delete();

    } catch (error) {
      print("Error while deleting: $error");
    }
  }

  Future<List<ProductInfo>> fetchProductsByCategory(String category) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      QuerySnapshot categoryProducts;
      if (category == "all") {
        categoryProducts = await db.collection('Products').where('Owner', isNotEqualTo: user.uid).get();
      } else {
        categoryProducts = await db.collection('Products').where('Category', isEqualTo: category).where('Owner', isNotEqualTo: user.uid).get();
      }
      List<ProductInfo> products = [];
      for (QueryDocumentSnapshot doc in categoryProducts.docs) {
        String name = doc['ProductName'];
        String productCategory = doc['Category'];
        String description = doc['Description'];
        String productId = doc.id;
        String userId = doc['Owner'];

        String imageUrl = await CloudStorageController().getDownloadURL('ProductImages/$productId');
        products.add(ProductInfo(productName: name, description: description, category: productCategory, imageURL: imageUrl, UserID: userId, productID: productId));
      }
      return products;
    } else {
      throw 'Not logged in.';
    }
  }

  Future<List<ProductInfo>> fetchProductsBySearchTerm(String searchTerm, String category) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (searchTerm.isEmpty) {
        return fetchProductsByCategory(category);
      } else {
        if(category == "all"){
          QuerySnapshot productsSnapshot = await db
              .collection('Products')
              .where('Owner', isNotEqualTo: user.uid)
              .get();

          List<ProductInfo> products = [];

          for (QueryDocumentSnapshot doc in productsSnapshot.docs) {
            String name = doc['ProductName'];
            String productCategory = doc['Category'];
            String description = doc['Description'];
            String productId = doc.id;

            if (searchTerm.isEmpty || name.toLowerCase().contains(searchTerm.toLowerCase())) {
              String imageUrl = await CloudStorageController().getDownloadURL('ProductImages/$productId');
              products.add(ProductInfo(productName: name, description: description, category: productCategory, imageURL: imageUrl, UserID: user.uid, productID: productId));
            }
          }

          return products;
        }
        QuerySnapshot productsSnapshot = await db
            .collection('Products')
            .where('Owner', isNotEqualTo: user.uid)
            .where('Category', isEqualTo: category)
            .get();

        List<ProductInfo> products = [];

        for (QueryDocumentSnapshot doc in productsSnapshot.docs) {
          String name = doc['ProductName'];
          String productCategory = doc['Category'];
          String description = doc['Description'];
          String productId = doc.id;

          if (searchTerm.isEmpty || name.toLowerCase().contains(searchTerm.toLowerCase())) {
            String imageUrl = await CloudStorageController().getDownloadURL('ProductImages/$productId');
            products.add(ProductInfo(productName: name, description: description, category: productCategory, imageURL: imageUrl, UserID: user.uid, productID: productId));
          }
        }

        return products;
      }
    } else {
      throw 'Not logged in.';
    }

  }

  Future<List<FeedbackData>> getFeedbackForUser(String userId) async {
    try {
      final querySnapshot = await db
          .collection('Feedbacks')
          .where('revieweeId', isEqualTo: userId)
          .get();

      final List<FeedbackData> feedbackList = querySnapshot.docs
          .map((doc) => FeedbackData.fromFirestore(doc.data()))
          .toList();

      return feedbackList;
    } catch (error) {
      print("Error getting feedback for user: $error");
      throw error;
    }
  }

  Future<double> getUserOverallRating(String userId) async {
    try {
      final querySnapshot = await db
          .collection('Feedbacks')
          .where('revieweeId', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 0.0;
      }

      final List<FeedbackData> feedbackList = querySnapshot.docs
          .map((doc) => FeedbackData.fromFirestore(doc.data()))
          .toList();

      double overallRating = feedbackList
          .map((feedback) => feedback.rating)
          .reduce((value, element) => value + element) /
          feedbackList.length;

      return overallRating;
    } catch (error) {
      print("Error getting overall rating for user: $error");
      throw error;
    }
  }

}