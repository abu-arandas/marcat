import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sale.dart';

class SaleHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'sales';

  Future<void> addSale(Sale sale) async {
    await _firestore
        .collection(_collectionName)
        .doc(sale.id)
        .set(sale.toJson());
  }

  Future<Sale?> getSaleById(String id) async {
    DocumentSnapshot doc =
        await _firestore.collection(_collectionName).doc(id).get();
    if (doc.exists) {
      return Sale.fromJson(doc);
    }
    return null;
  }

  Future<List<Sale>> getSales() async {
    QuerySnapshot querySnapshot =
        await _firestore.collection(_collectionName).get();
    return querySnapshot.docs.map((doc) => Sale.fromJson(doc)).toList();
  }

  Future<void> updateSale(Sale sale) async {
    await _firestore
        .collection(_collectionName)
        .doc(sale.id)
        .update(sale.toJson());
  }

  Future<void> deleteSale(String id) async {
    await _firestore.collection(_collectionName).doc(id).delete();
  }
}
