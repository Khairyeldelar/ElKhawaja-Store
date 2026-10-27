import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'model/product_model.dart';
import 'modules/login/auth_screen.dart';
import 'modules/product/product_editor_screen.dart';
import 'services/store_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool connected = false;
  try {
    await Firebase.initializeApp();
    connected = true;
  } catch (_) {
    // Firebase credentials must be supplied for live data.
  }
  runApp(ElKhawajaApp(firebaseReady: connected));
}

class ElKhawajaApp extends StatelessWidget {
  final bool firebaseReady;
  const ElKhawajaApp({super.key, required this.firebaseReady});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'الخواجة ستور',
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFFB98A57)),
    home: StoreHome(firebaseReady: firebaseReady),
  );
}

class StoreHome extends StatefulWidget {
  final bool firebaseReady;
  const StoreHome({super.key, required this.firebaseReady});
  @override
  State<StoreHome> createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  String selected = 'الكل';
  final categories = const {
    'الكل': '',
    'الساعات': 'Watches',
    'الأقلام': 'Pens',
    'السبح': 'Rosary',
    'البخور': 'Incense',
    'الأحجار الكريمة': 'Gemstones',
    'أخرى': 'Other',
  };

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('الخواجة ستور'), centerTitle: true,
        actions: [IconButton(tooltip: 'حسابي', icon: const Icon(Icons.account_circle_outlined),
          onPressed: () async {
            if (!widget.firebaseReady) return;
            if (FirebaseAuth.instance.currentUser == null) {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
            } else {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const MyProductsScreen()));
            }
            if (mounted) setState(() {});
          })]),
      floatingActionButton: widget.firebaseReady ? FloatingActionButton.extended(
        onPressed: () async {
          if (FirebaseAuth.instance.currentUser == null) {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
          } else {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductEditorScreen()));
          }
          if (mounted) setState(() {});
        },
        icon: const Icon(Icons.add), label: const Text('إضافة منتج')) : null,
      body: Column(children: [
        SizedBox(height: 58, child: ListView(
          scrollDirection: Axis.horizontal,
          children: categories.keys.map((name) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: ChoiceChip(
              label: Text(name), selected: selected == name,
              onSelected: (_) => setState(() => selected = name),
            ),
          )).toList(),
        )),
        if (!widget.firebaseReady)
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('يلزم ربط إعدادات Firebase الأصلية لعرض المنتجات الحقيقية.'),
          ),
        Expanded(child: widget.firebaseReady ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('Products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('تعذر تحميل المنتجات. راجع إعدادات قاعدة البيانات.'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final products = snapshot.data!.docs
                .map((d) => ProductModel.fromJson({...d.data(), 'productId': d.id}))
                .where((p) => selected == 'الكل' || p.category == categories[selected])
                .toList();
            if (products.isEmpty) return const Center(child: Text('لا توجد منتجات في هذا القسم'));
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, childAspectRatio: .73, crossAxisSpacing: 12, mainAxisSpacing: 12),
              itemCount: products.length,
              itemBuilder: (context, i) {
                final p = products[i];
                final image = p.images?.isNotEmpty == true ? p.images!.first.toString() : '';
                return Card(clipBehavior: Clip.antiAlias, child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProductDetails(product: p))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: image.startsWith('http')
                      ? Image.network(image, width: double.infinity, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported)))
                      : const Center(child: Icon(Icons.shopping_bag_outlined, size: 56))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(p.title ?? '',
                      maxLines: 2, overflow: TextOverflow.ellipsis)),
                    Padding(padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                      child: Text('${p.price ?? ''} ${p.currency ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                ));
              },
            );
          },
        ) : const Center(child: Icon(Icons.storefront_outlined, size: 72))),
      ]),
    ),
  );
}

class ProductDetails extends StatelessWidget {
  final ProductModel product;
  const ProductDetails({super.key, required this.product});
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: Text(product.title ?? 'تفاصيل المنتج')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        ...?product.images?.map((url) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Image.network(url.toString(), height: 240, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
        )),
        Text(product.title ?? '', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text('${product.price ?? ''} ${product.currency ?? ''}',
          style: Theme.of(context).textTheme.titleLarge),
        const Divider(height: 32),
        Text(product.description ?? ''),
        const SizedBox(height: 18),
        Text('الدولة: ${product.countryName ?? ''}'),
        Text('الهاتف: ${product.countryCode ?? ''} ${product.phoneNumber ?? ''}'),
      ]),
    ),
  );
}

class MyProductsScreen extends StatelessWidget {
  const MyProductsScreen({super.key});
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      appBar: AppBar(title: const Text('منتجاتي'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) Navigator.pop(context);
        }),
      ]),
      body: StreamBuilder<List<ProductModel>>(
        stream: StoreRepository().watchMyProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final items = snapshot.data!;
          if (items.isEmpty) return const Center(child: Text('ليس لديك منتجات بعد'));
          return ListView.builder(itemCount: items.length, itemBuilder: (context, i) {
            final p = items[i];
            return ListTile(title: Text(p.title ?? ''),
              subtitle: Text('${p.price ?? ''} ${p.currency ?? ''}'),
              trailing: Wrap(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ProductEditorScreen(existing: p)))),
                IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                  final ok = await showDialog<bool>(context: context,
                    builder: (ctx) => AlertDialog(title: const Text('حذف المنتج؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('إلغاء')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('حذف')),
                      ]));
                  if (ok == true) {
                    try { await StoreRepository().deleteProduct(p); }
                    catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())));
                    }
                  }
                }),
              ]),
            );
          });
        },
      ),
    ),
  );
}
