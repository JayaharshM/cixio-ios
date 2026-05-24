import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'SmartHub',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B4DFF),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF030716),
          useMaterial3: true,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF030716),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5B4DFF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF40378F),
              disabledForegroundColor: Colors.white70,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1D1F24),
            hintStyle: const TextStyle(color: Color(0xFFC6C2D5)),
            labelStyle: const TextStyle(color: Color(0xFFC6C2D5)),
            prefixIconColor: const Color(0xFFC6C2D5),
            suffixIconColor: const Color(0xFFC6C2D5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF545064)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF545064)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF746BFF),
                width: 1.4,
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFD9D5FF),
            ),
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
