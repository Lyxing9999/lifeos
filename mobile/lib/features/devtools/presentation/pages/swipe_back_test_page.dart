import 'package:flutter/material.dart';

class SwipeBackTestPage extends StatelessWidget {
  const SwipeBackTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Back Test')),
      body: ListView.separated(
        itemCount: 50,
        separatorBuilder: (_, index) => const Divider(height: 1),
        itemBuilder: (context, i) => ListTile(title: Text('Item #${i + 1}')),
      ),
    );
  }
}
