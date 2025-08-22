// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or create a document
  Future<void> saveData({
    required BuildContext context,
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data);
    } on FirebaseException catch (e) {
      print('Failed to send data: $e');
    }
  }

  Future<DocumentReference> addData({
    required BuildContext context,
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(collection)
          .add(data);
      return docRef;
    } catch (e) {
      print('Failed to add data: $e');
      rethrow; // or return Future.error(e) if you prefer
    }
  }

  /// Update a document
  Future<void> updateData({
    required BuildContext context,
    required String collection,
    required String docId,
    required Map<String, dynamic> newData,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).update(newData);
    } catch (e) {
      print('Failed to update data: $e');
    }
  }

  /// Delete a document
  Future<void> deleteData({
    required BuildContext context,
    required String collection,
    required String docId,
  }) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      print('Failed to delete data: $e');
    }
  }

  /// Fetch a single document
  Future<DocumentSnapshot?> fetchDocument({
    required BuildContext context,
    required String collection,
    required String docId,
  }) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection(collection).doc(docId).get();
      return doc;
    } catch (e) {
      print('Failed to fetch data: $e');
      return null;
    }
  }

  /// Fetch all documents from a collection
  Future<List<QueryDocumentSnapshot>?> fetchCollection({
    required BuildContext context,
    required String collection,
  }) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collection).get();
      return querySnapshot.docs;
    } catch (e) {
      print('Failed to fetch data: $e');
      return null;
    }
  }

  /// Fetch with a single where condition
  Future<List<QueryDocumentSnapshot>?> fetchWhere({
    required BuildContext context,
    required String collection,
    required String field,
    required dynamic isEqualTo,
  }) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection(collection)
              .where(field, isEqualTo: isEqualTo)
              .get();

      return snapshot.docs;
    } catch (e) {
      print('Failed to fetch data: $e');
      return null;
    }
  }

  /// Fetch documents with multiple where conditions
  Future<List<QueryDocumentSnapshot>?> fetchWithConditions({
    required BuildContext context,
    required String collection,
    required List<Map<String, dynamic>> conditions,
  }) async {
    try {
      CollectionReference ref = _firestore.collection(collection);
      Query query = ref;

      for (var condition in conditions) {
        query = query.where(condition['field'], isEqualTo: condition['value']);
      }

      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs;
    } catch (e) {
      print('Failed to fetch data: $e');
      return null;
    }
  }

  /// Fetch with multiple conditions, sorting, and limit
  Future<List<QueryDocumentSnapshot>?> fetchWithQuery({
    required BuildContext context,
    required String collection,
    List<Map<String, dynamic>>? conditions,
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection(collection);

      // Apply where conditions
      if (conditions != null) {
        for (var condition in conditions) {
          query = query.where(
            condition['field'],
            isEqualTo: condition['value'],
          );
        }
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('Failed to fetch data: $e');
      return null;
    }
  }
}
