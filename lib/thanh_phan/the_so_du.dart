import 'package:flutter/material.dart';
import '../thien_ich/dinh_dang_tien.dart';

class TheSoDu extends StatefulWidget {
  final double tongSoDu;
  final double tongThuNhap;
  final double tongChiTieu;

  const TheSoDu({
    super.key,
    this.tongSoDu = 5250000,
    this.tongThuNhap = 8000000,
    this.tongChiTieu = 2750000,
  });

  static const Color mauChinh = Color(0xFFE07852);

  @override
  State<TheSoDu> createState() => _TheSoDuState();
}

class _TheSoDuState extends State<TheSoDu> {
  bool _hienSoDu = true;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Color> mauGradient = isDark
        ? const [
            Color(0xFF14B8A6),
            Color(0xFF0F766E),
            Color(0xFF042F2E),
          ]
        : const [
            Color(0xFFF07E56),
            Color(0xFFE06C42),
            Color(0xFFC7552D),
          ];

    final Color mauBong = isDark
        ? const Color(0xFF14B8A6).withValues(alpha: 0.35)
        : const Color(0xFFE06C42).withValues(alpha: 0.38);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: mauGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: mauBong,
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Vòng tròn họa tiết mờ góc trên phải
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Vòng tròn họa tiết mờ góc dưới phải
            Positioned(
              right: 20,
              bottom: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Nội dung chính của Thẻ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hàng tiêu đề + Nút ẩn/hiện + Badge Ví chính
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Tổng số dư',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _hienSoDu = !_hienSoDu;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                _hienSoDu
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white70,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 5),
                            Text(
                              'Ví chính',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Con số số dư lớn tự co giãn chống tràn chữ
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _hienSoDu
                          ? DinhDangTienInputFormatter.dinhDang(widget.tongSoDu)
                          : '•••••••• đ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 2 Hộp kính mờ hiển thị Thu nhập & Chi tiêu
                  Row(
                    children: [
                      Expanded(
                        child: _taoHopThongKe(
                          nhan: 'Thu nhập',
                          soTien: widget.tongThuNhap,
                          laThuNhap: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _taoHopThongKe(
                          nhan: 'Chi tiêu',
                          soTien: widget.tongChiTieu,
                          laThuNhap: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taoHopThongKe({
    required String nhan,
    required double soTien,
    required bool laThuNhap,
  }) {
    final mauIcon = laThuNhap ? const Color(0xFF4ADE80) : const Color(0xFFFF8A80);
    final icon = laThuNhap ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final dau = laThuNhap ? '+' : '-';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mauIcon.withValues(alpha: 0.22),
                ),
                child: Icon(icon, size: 12, color: mauIcon),
              ),
              const SizedBox(width: 6),
              Text(
                nhan,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _hienSoDu
                  ? '$dau${DinhDangTienInputFormatter.dinhDang(soTien)}'
                  : '••••••',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
