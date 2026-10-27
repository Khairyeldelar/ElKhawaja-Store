import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0;
  final controller = PageController();
  final items = const [
    ('أهلًا بك في الخواجة ستور', 'اكتشف منتجات مميزة من الأقسام المختلفة', Icons.storefront_outlined),
    ('تصفح المنتجات بسهولة', 'الساعات والأقلام والسبح والبخور والأحجار الكريمة', Icons.category_outlined),
    ('اعرض منتجاتك', 'أنشئ حسابًا وأضف منتجاتك وتواصل مع المهتمين', Icons.add_circle_outline),
  ];
  Future<void> finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onBoarding', true);
    widget.onFinish();
  }
  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SafeArea(child: Column(children: [
        Expanded(child: PageView.builder(
          controller: controller, itemCount: items.length,
          onPageChanged: (value) => setState(() => page = value),
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.all(30),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(items[i].$3, size: 100, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 30),
              Text(items[i].$1, textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 15),
              Text(items[i].$2, textAlign: TextAlign.center),
            ]),
          ))),
        Text('${page + 1} / ${items.length}'),
        Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          TextButton(onPressed: finish, child: const Text('تخطي')),
          const Spacer(),
          FilledButton(onPressed: page == items.length - 1 ? finish :
            () => controller.nextPage(duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut),
            child: Text(page == items.length - 1 ? 'ابدأ الآن' : 'التالي')),
        ])),
      ])),
    ),
  );
}
