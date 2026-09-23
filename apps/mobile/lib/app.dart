import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'routes/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp.router(
      title: 'Cashflow Inc Exp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routeInformationParser: AppRouter.router.routeInformationParser,
      routerDelegate: AppRouter.router.routerDelegate,
      routeInformationProvider: AppRouter.router.routeInformationProvider,
    );
  }
}
