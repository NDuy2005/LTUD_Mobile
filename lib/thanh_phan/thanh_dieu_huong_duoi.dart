import 'dart:ui';
import 'package:flutter/material.dart';

class MucDieuHuong {
  final IconData icon;
  final String nhan;
  const MucDieuHuong({required this.icon, required this.nhan});
}

class ThanhDieuHuongDuoi extends StatefulWidget {
  final int viTriHienTai;
  final ValueChanged<int> khiChon;

  const ThanhDieuHuongDuoi({
    super.key,
    required this.viTriHienTai,
    required this.khiChon,
  });

  static const List<MucDieuHuong> danhSachMuc = [
    MucDieuHuong(icon: Icons.home_rounded, nhan: 'Trang chủ'),
    MucDieuHuong(icon: Icons.receipt_long_rounded, nhan: 'Giao dịch'),
    MucDieuHuong(icon: Icons.add_rounded, nhan: 'Thêm mới'),
    MucDieuHuong(icon: Icons.bar_chart_rounded, nhan: 'Thống kê'),
    MucDieuHuong(icon: Icons.person_rounded, nhan: 'Cài đặt'),
  ];

  @override
  State<ThanhDieuHuongDuoi> createState() => _ThanhDieuHuongDuoiState();
}

class _ThanhDieuHuongDuoiState extends State<ThanhDieuHuongDuoi>
    with SingleTickerProviderStateMixin {
  static const int _thoiGianMs = 520;
  static const double _duongKinhBubble = 56.0;
  static const double _chieuCaoBar = 64.0;
  static const double _tongChieuCao = 104.0;
  static const double _leNgang = 16.0;
  static const double _doLom = 16.0; // Tăng độ lõm để nút lún sâu hơn

  late final AnimationController _controller;
  late double _tuPos;
  late int _denIdx;

  int get _viTriHopLe =>
      widget.viTriHienTai.clamp(0, ThanhDieuHuongDuoi.danhSachMuc.length - 1);

  @override
  void initState() {
    super.initState();
    _denIdx = _viTriHopLe;
    _tuPos = _viTriHopLe.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _thoiGianMs),
      value: 1.0,
    );
  }

  @override
  void didUpdateWidget(covariant ThanhDieuHuongDuoi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viTriHienTai != widget.viTriHienTai) {
      _tuPos = _tinhPos(_controller.value);
      _denIdx = _viTriHopLe;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _tinhPos(double t) {
    final double curved = Curves.easeOutCubic.transform(t);
    return _tuPos + (_denIdx - _tuPos) * curved;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color mauKinh = isDark
        ? const Color(0xFF0C2B27).withValues(alpha: 0.72)
        : const Color(0xFF1E293B).withValues(alpha: 0.78);

    final Color mauVien = isDark
        ? const Color(0xFF2DD4BF).withValues(alpha: 0.50)
        : Colors.white.withValues(alpha: 0.35);

    final Color mauChon =
    isDark ? const Color(0xFF2DD4BF) : const Color(0xFFE07852);
    final Color mauChuaChon =
    isDark ? const Color(0xFF94A3B8) : Colors.white70;

    final List<Color> mauCircleGradient = isDark
        ? const [Color(0xFF34D399), Color(0xFF0D9488)]
        : const [Color(0xFFF59E0B), Color(0xFFE07852)];

    final danhSachMuc = ThanhDieuHuongDuoi.danhSachMuc;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _tongChieuCao,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double beRongBar = constraints.maxWidth - (_leNgang * 2);
            final double beRongMoiMuc = beRongBar / danhSachMuc.length;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final double pos = _tinhPos(_controller.value);
                final double centerX = (pos + 0.5) * beRongMoiMuc;
                final double bubbleLeft =
                    _leNgang + centerX - (_duongKinhBubble / 2);

                // Hạ bubbleTop xuống một chút để nút nằm sâu hơn vào phần lõm
                const double bubbleTop =
                    _tongChieuCao - _chieuCaoBar - (_duongKinhBubble * 0.50);

                final int dangChonIdx = _viTriHopLe;

                return Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: _leNgang,
                      right: _leNgang,
                      bottom: 4,
                      height: _chieuCaoBar,
                      child: ClipPath(
                        clipper: _ThanhVienThuocLomClipper(
                          centerX: centerX,
                          banKinhOm: (_duongKinhBubble / 2) + 7,
                          doLom: _doLom,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: CustomPaint(
                            size: Size(beRongBar, _chieuCaoBar),
                            painter: _VienThuocLomPainter(
                              centerX: centerX,
                              banKinhOm: (_duongKinhBubble / 2) + 7,
                              doLom: _doLom,
                              mauNen: mauKinh,
                              mauVien: mauVien,
                            ),
                            child: Row(
                              children: List.generate(danhSachMuc.length, (index) {
                                final muc = danhSachMuc[index];
                                final bool dangChon = index == dangChonIdx;

                                return Expanded(
                                  child: InkWell(
                                    onTap: () => widget.khiChon(index),
                                    borderRadius: BorderRadius.circular(999),
                                    splashColor:
                                    mauChon.withValues(alpha: 0.14),
                                    highlightColor: Colors.transparent,
                                    child: SizedBox(
                                      height: _chieuCaoBar,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          dangChon
                                              ? const SizedBox(height: 21)
                                              : Icon(
                                            muc.icon,
                                            size: 21,
                                            color: mauChuaChon,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            muc.nhan,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: dangChon
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                              color: dangChon
                                                  ? mauChon
                                                  : mauChuaChon,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: bubbleLeft,
                      top: bubbleTop,
                      width: _duongKinhBubble,
                      height: _duongKinhBubble,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: mauCircleGradient,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: mauChon.withValues(alpha: 0.65),
                                blurRadius: 22,
                                spreadRadius: 3,
                              ),
                              BoxShadow(
                                color: mauChon.withValues(alpha: 0.30),
                                blurRadius: 36,
                                spreadRadius: 6,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.55),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                danhSachMuc[dangChonIdx].icon,
                                key: ValueKey('active_icon_$dangChonIdx'),
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Path _taoDuongVienThuocLom({
  required Size size,
  required double centerX,
  required double banKinhOm,
  required double doLom,
}) {
  final double w = size.width;
  final double h = size.height;

  final Path pillPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h),
        Radius.circular(h / 2),
      ),
    );

  final double rX = banKinhOm * 1.18;
  final Path notchPath = Path()
    ..moveTo(centerX - rX, 0)
    ..cubicTo(
      centerX - rX * 0.55,
      0,
      centerX - rX * 0.55,
      doLom,
      centerX,
      doLom,
    )
    ..cubicTo(
      centerX + rX * 0.55,
      doLom,
      centerX + rX * 0.55,
      0,
      centerX + rX,
      0,
    )
    ..close();

  return Path.combine(PathOperation.difference, pillPath, notchPath);
}

class _ThanhVienThuocLomClipper extends CustomClipper<Path> {
  final double centerX;
  final double banKinhOm;
  final double doLom;

  _ThanhVienThuocLomClipper({
    required this.centerX,
    required this.banKinhOm,
    required this.doLom,
  });

  @override
  Path getClip(Size size) {
    return _taoDuongVienThuocLom(
      size: size,
      centerX: centerX,
      banKinhOm: banKinhOm,
      doLom: doLom,
    );
  }

  @override
  bool shouldReclip(covariant _ThanhVienThuocLomClipper oldClipper) {
    return oldClipper.centerX != centerX ||
        oldClipper.banKinhOm != banKinhOm ||
        oldClipper.doLom != doLom;
  }
}

class _VienThuocLomPainter extends CustomPainter {
  final double centerX;
  final double banKinhOm;
  final double doLom;
  final Color mauNen;
  final Color mauVien;

  _VienThuocLomPainter({
    required this.centerX,
    required this.banKinhOm,
    required this.doLom,
    required this.mauNen,
    required this.mauVien,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _taoDuongVienThuocLom(
      size: size,
      centerX: centerX,
      banKinhOm: banKinhOm,
      doLom: doLom,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = mauNen
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = mauVien
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
  }

  @override
  bool shouldRepaint(covariant _VienThuocLomPainter oldDelegate) {
    return oldDelegate.centerX != centerX ||
        oldDelegate.banKinhOm != banKinhOm ||
        oldDelegate.doLom != doLom ||
        oldDelegate.mauNen != mauNen ||
        oldDelegate.mauVien != mauVien;
  }
}