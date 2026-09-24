import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velix_core/velix_core.dart';
import 'core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await VelixRealtimeService().initialize();
  runApp(
    const ProviderScope(
      child: VelixPartnerApp(),
    ),
  );
}

class VelixPartnerApp extends ConsumerWidget {
  const VelixPartnerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    return MaterialApp.router(
      title: 'Velix Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: partnerAppRouter,
    );
  }
}
