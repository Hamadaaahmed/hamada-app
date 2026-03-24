import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router.dart';
import '../core/api_client.dart';
import 'theme.dart';

class HamadaSianaApp extends StatelessWidget {
  const HamadaSianaApp({super.key});

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      if (kDebugMode) {
        return Material(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                details.exceptionAsString(),
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
        );
      }

      return const Material(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'حدث خطأ غير متوقع.\nيرجى إغلاق الشاشة وفتحها مرة أخرى.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حمادة صيانة',
      theme: buildAppTheme(),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox(),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      navigatorKey: AppNavigator.key,
      initialRoute: AppRouter.authGate,
    );
  }
}
