import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../routes.dart';
import '../../../utils/utils.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "404 -- Page Not Found",
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            TextButton(
              key: const ValueKey('notFound_homeButton'),
              onPressed: () => context.goNamed(AppRoute.home.name),
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}
