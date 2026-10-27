import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final phone = TextEditingController();
  bool busy = false;
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    name.text = user.displayName ?? '';
    try {
      final doc = await FirebaseFirestore.instance.collection('Users').doc(user.uid).get();
      if (doc.exists) {
        name.text = (doc.data()?['name'] ?? name.text).toString();
        phone.text = (doc.data()?['phone'] ?? '').toString();
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }
  Future<void> save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => busy = true);
    try {
      await user.updateDisplayName(name.text.trim());
      await FirebaseFirestore.instance.collection('Users').doc(user.uid).set({
        'uid': user.uid, 'name': name.text.trim(), 'email': user.email ?? '',
        'phone': phone.text.trim(),
      }, SetOptions(merge: true));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ البيانات: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  @override
  void dispose() { name.dispose(); phone.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(appBar: AppBar(title: const Text('الملف الشخصي')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')),
        TextField(controller: phone, keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'رقم الهاتف')),
        const SizedBox(height: 20),
        FilledButton(onPressed: busy ? null : save,
          child: Text(busy ? 'جارٍ الحفظ...' : 'حفظ التغييرات')),
      ]))),
  );
}
