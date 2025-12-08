import 'package:awesome_flutter_extensions/awesome_flutter_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../../../../utils/screen_utils.dart';
import '../services/app/app_service.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appServiceProvider.select((state) => state.appVersion));

    final styles = context.textStyles;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Template"),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoute.settings.name),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: paddingAllM,
          child: Column(
            children: [
              const Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Home Page"),
                      ],
                    ),
                  ),
                ),
              ),
              Text(
                appVersion,
                style: styles.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
