import 'package:flutter/material.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
        title: Text(title ?? 'Endelea'),
      ),
      body: const Center(
        child: Text('Sport Gymnasium Tracking'),
      ),
    );
  }
}
