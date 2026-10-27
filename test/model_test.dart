import 'package:flutter_test/flutter_test.dart';
import 'package:elkhawaja_store/model/product_model.dart';
import 'package:elkhawaja_store/model/user_model.dart';

void main() {
  test('product serialization preserves fields', () {
    final product = ProductModel(title: 'ساعة', price: '10',
      category: 'Watches', images: ['https://example.com/a.jpg']);
    final decoded = ProductModel.fromJson(product.toMap());
    expect(decoded.title, 'ساعة');
    expect(decoded.price, '10');
    expect(decoded.images, hasLength(1));
  });
  test('user model maps correctly', () {
    final user = UserModel(uid: 'abc', name: 'Test', email: 'a@example.com');
    expect(UserModel.fromJson(user.toMap()).uid, 'abc');
  });
}
