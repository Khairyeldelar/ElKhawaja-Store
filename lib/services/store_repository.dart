import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/product_model.dart';

class StoreRepository {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Stream<List<ProductModel>> watchProducts({String? category}) =>
      db.collection('Products').snapshots().map((snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'productId': doc.id}))
          .where((p) => category == null || p.category == category)
          .toList());

  Stream<List<ProductModel>> watchMyProducts() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return db.collection('Products').where('uid', isEqualTo: uid)
        .snapshots().map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson({...doc.data(), 'productId': doc.id}))
            .toList());
  }

  Future<void> addProduct(ProductModel product) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw StateError('يجب تسجيل الدخول');
    final ref = db.collection('Products').doc();
    await ref.set({...product.toMap(), 'productId': ref.id, 'uid': uid,
      'dateTime': DateTime.now().toIso8601String()});
  }

  Future<void> updateProduct(ProductModel product) async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid != product.uid) throw StateError('غير مصرح');
    if (product.productId == null) throw StateError('معرف المنتج مفقود');
    await db.collection('Products').doc(product.productId).update(product.toMap());
  }

  Future<void> deleteProduct(ProductModel product) async {
    final uid = auth.currentUser?.uid;
    if (uid == null || uid != product.uid) throw StateError('غير مصرح');
    await db.collection('Products').doc(product.productId).delete();
  }
}
