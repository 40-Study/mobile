import 'package:flutter/material.dart';
import 'package:flutter_bloc_app_template/generated/l10n.dart';
import 'package:flutter_bloc_app_template/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navigator = NavigationService.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => navigator.navigateTo(Routes.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              S.of(context).appTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => navigator.navigateTo(Routes.appearance),
              icon: const Icon(Icons.palette_outlined),
              label: Text(S.of(context).themeTitle),
            ),
          ],
        ),
      ),
    );
  }
}
