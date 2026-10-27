import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  bool register = false;
  bool busy = false;
  String? error;

  @override
  void dispose() {
    email.dispose(); password.dispose(); name.dispose(); super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() { busy = true; error = null; });
    try {
      if (register) {
        final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(), password: password.text);
        await result.user?.updateDisplayName(name.text.trim());
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text.trim(), password: password.text);
      }
      if (mounted) Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => error = e.message ?? e.code);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(appBar: AppBar(title: Text(register ? 'إنشاء حساب' : 'تسجيل الدخول')),
      body: Form(key: form, child: ListView(padding: const EdgeInsets.all(20), children: [
        if (register) TextFormField(controller: name,
          decoration: const InputDecoration(labelText: 'الاسم'),
          validator: (v) => v == null || v.trim().isEmpty ? 'أدخل الاسم' : null),
        TextFormField(controller: email,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
          validator: (v) => v == null || !v.contains('@') ? 'بريد غير صالح' : null),
        TextFormField(controller: password, obscureText: true,
          decoration: const InputDecoration(labelText: 'كلمة المرور'),
          validator: (v) => v == null || v.length < 6 ? '6 أحرف على الأقل' : null),
        if (error != null) Padding(padding: const EdgeInsets.all(12),
          child: Text(error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 18),
        FilledButton(onPressed: busy ? null : submit,
          child: Text(busy ? 'جارٍ التحميل...' : register ? 'إنشاء حساب' : 'دخول')),
        TextButton(onPressed: busy ? null : () => setState(() => register = !register),
          child: Text(register ? 'لديك حساب؟ دخول' : 'حساب جديد')),
        TextButton(onPressed: busy ? null : () async {
          if (!email.text.contains('@')) {
            setState(() => error = 'أدخل بريدك أولًا'); return;
          }
          try {
            await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إرسال رابط إعادة تعيين كلمة المرور')));
          } catch (e) {
            if (mounted) setState(() => error = e.toString());
          }
        }, child: const Text('نسيت كلمة المرور؟')),
      ]))),
  );
}
