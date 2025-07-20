import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  static const String routeName = '/collection';
  const CollectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('收藏夹')),
      body: const Center(child: Text('这里是收藏夹页面')),
    );
  }
}
