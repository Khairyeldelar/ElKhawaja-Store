import 'package:flutter/material.dart';
import '../../model/product_model.dart';
import '../../services/store_repository.dart';

class ProductEditorScreen extends StatefulWidget {
  final ProductModel? existing;
  const ProductEditorScreen({super.key, this.existing});
  @override
  State<ProductEditorScreen> createState() => _ProductEditorScreenState();
}

class _ProductEditorScreenState extends State<ProductEditorScreen> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.existing?.title ?? '');
  late final price = TextEditingController(text: widget.existing?.price ?? '');
  late final description = TextEditingController(text: widget.existing?.description ?? '');
  late final phone = TextEditingController(text: widget.existing?.phoneNumber ?? '');
  late final image = TextEditingController(
    text: widget.existing?.images?.isNotEmpty == true
      ? widget.existing!.images!.first.toString() : '');
  late String category = widget.existing?.category ?? 'Watches';
  late String currency = widget.existing?.currency ?? 'KWD';
  bool saving = false;
  String? error;
  final categories = const ['Watches', 'Pens', 'Rosary', 'Incense', 'Gemstones', 'Other'];

  @override
  void dispose() {
    title.dispose(); price.dispose(); description.dispose();
    phone.dispose(); image.dispose(); super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() { saving = true; error = null; });
    try {
      final old = widget.existing;
      final product = ProductModel(
        productId: old?.productId, uid: old?.uid,
        title: title.text.trim(), price: price.text.trim(),
        description: description.text.trim(), category: category,
        currency: currency, phoneNumber: phone.text.trim(),
        countryName: old?.countryName ?? 'Kuwait',
        countryCode: old?.countryCode ?? '+965',
        dateTime: old?.dateTime,
        images: image.text.trim().isEmpty ? [] : [image.text.trim()],
      );
      if (old == null) {
        await StoreRepository().addProduct(product);
      } else {
        await StoreRepository().updateProduct(product);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(appBar: AppBar(title: Text(widget.existing == null ? 'إضافة منتج' : 'تعديل المنتج')),
      body: Form(key: form, child: ListView(padding: const EdgeInsets.all(18), children: [
        TextFormField(controller: title, decoration: const InputDecoration(labelText: 'اسم المنتج'),
          validator: (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null),
        TextFormField(controller: price, keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'السعر'),
          validator: (v) => double.tryParse(v ?? '') == null ? 'أدخل سعرًا صحيحًا' : null),
        DropdownButtonFormField<String>(initialValue: category,
          decoration: const InputDecoration(labelText: 'القسم'),
          items: categories.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => category = v!)),
        DropdownButtonFormField<String>(initialValue: currency,
          decoration: const InputDecoration(labelText: 'العملة'),
          items: ['KWD', 'EGP', 'USD', 'SAR', 'AED']
            .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
          onChanged: (v) => setState(() => currency = v!)),
        TextFormField(controller: description, maxLines: 4,
          decoration: const InputDecoration(labelText: 'الوصف')),
        TextFormField(controller: phone, keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'رقم التواصل')),
        TextFormField(controller: image,
          decoration: const InputDecoration(labelText: 'رابط صورة المنتج')),
        if (error != null) Text(error!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 18),
        FilledButton(onPressed: saving ? null : save,
          child: Text(saving ? 'جارٍ الحفظ...' : 'حفظ المنتج')),
      ]))),
  );
}
