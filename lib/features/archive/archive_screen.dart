import 'package:flutter/material.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Archive'),
        backgroundColor: const Color(0xFF121212),
      ),
      body: const Center(
        child: Text('Archived habits will appear here',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
