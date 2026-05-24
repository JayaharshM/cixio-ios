import 'package:flutter/material.dart';

class TabPlaceholderScreen extends StatelessWidget {
  const TabPlaceholderScreen({
    required this.pageName,
    super.key,
  });

  final String pageName;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF101415),
            Color(0xFF070A12),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Text(
            pageName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
