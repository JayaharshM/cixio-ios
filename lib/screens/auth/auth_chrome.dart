import 'package:flutter/material.dart';

const Color authBackgroundColor = Color(0xFF030716);
const Color authPanelColor = Color(0xFF101827);
const Color authRegisterPanelColor = Color(0xFF1B1F20);
const Color authBorderColor = Color(0xFF253149);
const Color authRegisterBorderColor = Color(0xFF3C4246);
const Color authPrimaryColor = Color(0xFF5B4DFF);
const Color authMutedTextColor = Color(0xFFC7C3D7);

class AuthBackground extends StatelessWidget {
  const AuthBackground({
    required this.child,
    super.key,
    this.maxWidth = 420,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: authBackgroundColor,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SmartHubMark extends StatelessWidget {
  const SmartHubMark({
    super.key,
    this.size = 32,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          _LogoTile(
            size: size * 0.44,
            alignment: Alignment.topCenter,
          ),
          _LogoTile(
            size: size * 0.44,
            alignment: Alignment.centerLeft,
          ),
          _LogoTile(
            size: size * 0.44,
            alignment: Alignment.centerRight,
          ),
          _LogoTile(
            size: size * 0.44,
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
}

class _LogoTile extends StatelessWidget {
  const _LogoTile({
    required this.size,
    required this.alignment,
  });

  final double size;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.rotate(
        angle: 0.78,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: authPrimaryColor,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: const Color(0xFF7B72FF), width: 0.8),
          ),
        ),
      ),
    );
  }
}

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFF30374A)),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      child: const FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 14),
            Text('Continue with Google'),
          ],
        ),
      ),
    );
  }
}

class AuthDivider extends StatelessWidget {
  const AuthDivider({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(child: Divider(color: Color(0xFF253149))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFC3BED5),
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF253149))),
      ],
    );
  }
}
