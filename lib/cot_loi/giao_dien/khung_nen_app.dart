import 'package:flutter/material.dart';

class KhungNenApp extends StatelessWidget {
  final Widget child;

  const KhungNenApp({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final bool laGiaoDienToi = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Chuyển đổi hiệu ứng mượt mà giữa Ảnh Nền Tối và Ảnh Nền Sáng (AnimatedCrossFade)
        Positioned.fill(
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 500),
            firstCurve: Curves.easeInOutCubic,
            secondCurve: Curves.easeInOutCubic,
            crossFadeState: laGiaoDienToi
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: const _NenToiWidget(),
            secondChild: const _NenSangWidget(),
          ),
        ),
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

class _NenToiWidget extends StatelessWidget {
  const _NenToiWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        'lib/images/background-toi.png',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF090D16), Color(0xFF1E1B4B)],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NenSangWidget extends StatelessWidget {
  const _NenSangWidget();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        'lib/images/background-sang.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF7ED), Color(0xFFFBFBF8), Color(0xFFF0FDF4)],
              ),
            ),
          );
        },
      ),
    );
  }
}
