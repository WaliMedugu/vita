import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vita/router/app_router.dart';
import 'package:vita/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const VitaApp());
}

class VitaApp extends StatelessWidget {
  const VitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VITA',
      debugShowCheckedModeBanner: false,
      theme: VitaTheme.theme,
      routerConfig: appRouter,
    );
  }
}
