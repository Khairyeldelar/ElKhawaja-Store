import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../model/report_model.dart';

class ReportProductScreen extends StatefulWidget {
  final String productId;
  const ReportProductScreen({super.key, required this.productId});
  @override
  State<ReportProductScreen> createState() => _ReportProductScreenState();
}
class _ReportProductScreenState extends State<ReportProductScreen> {
  final details = TextEditingController();
  bool busy = false;
  @override
  void dispose() { details.dispose(); super.dispose(); }
  Future<void> send() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب تسجيل الدخول أولًا')));
      return;
    }
    if (details.text.trim().isEmpty) return;
    setState(() => busy = true);
    try {
      final report = ReportModel(productId: widget.productId,
        reporterUid: user.uid, reason: details.text.trim(), createdAt: DateTime.now());
      await FirebaseFirestore.instance.collection('Reports').add(report.toMap());
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إرسال البلاغ: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(appBar: AppBar(title: const Text('الإبلاغ عن منتج')),
      body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        TextField(controller: details, maxLines: 5,
          decoration: const InputDecoration(labelText: 'سبب البلاغ',
            border: OutlineInputBorder())),
        const SizedBox(height: 16),
        FilledButton(onPressed: busy ? null : send,
          child: Text(busy ? 'جارٍ الإرسال...' : 'إرسال البلاغ')),
      ]))),
  );
}
