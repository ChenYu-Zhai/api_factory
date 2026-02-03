import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_verification_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'API Verification'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('General Settings (Coming Soon)')),
            ApiVerificationPage(),
          ],
        ),
      ),
    );
  }
}
