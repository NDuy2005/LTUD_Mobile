import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import '../thien_ich/dinh_dang_tien.dart';
import '../thien_ich/kiem_tra_dieu_kien.dart';

class ManHinhThemGiaoDich extends StatefulWidget {
  final VoidCallback? khiDaLuu;

  const ManHinhThemGiaoDich({
    super.key,
    this.khiDaLuu,
  });

  @override
  State<ManHinhThemGiaoDich> createState() => _ManHinhThemGiaoDichState();
}

class _ManHinhThemGiaoDichState extends State<ManHinhThemGiaoDich> {
  LoaiGiaoDich _loai = LoaiGiaoDich.chiTieu;
  final TextEditingController _soTienController = TextEditingController();
  final TextEditingController _tieuDeController = TextEditingController();
  final TextEditingController _ghiChuController = TextEditingController();
  MoHinhDanhMuc? _danhMucChon;
  DateTime _ngayChon = DateTime.now();

  bool _coSoTien = false; // Chỉ hiện nút Lưu khi có số tiền > 0

  static const Color mauChinh = Color(0xFFE07852);
  static const Color mauChiTieu = Color(0xFFE07852);

  @override
  void initState() {
    super.initState();
    _soTienController.addListener(_kiemTraSoTien);
  }

  void _kiemTraSoTien() {
    final double? val = DinhDangTienInputFormatter.giaiMaSoTien(_soTienController.text);
    final bool hopLe = val != null && val > 0;
    if (hopLe != _coSoTien) {
      setState(() {
        _coSoTien = hopLe;
      });
    }
  }

  @override
  void dispose() {
    _soTienController.removeListener(_kiemTraSoTien);
    _soTienController.dispose();
    _tieuDeController.dispose();
    _ghiChuController.dispose();
    super.dispose();
  }

  Future<void> _hienThanhCuonChonGio(DateTime ngay, bool isDark) async {
    int gioDaChon = _ngayChon.hour;
    int phutDaChon = _ngayChon.minute;

    final FixedExtentScrollController gioController =
        FixedExtentScrollController(initialItem: gioDaChon);
    final FixedExtentScrollController phutController =
        FixedExtentScrollController(initialItem: phutDaChon);

    final Color mauChuDao = isDark ? const Color(0xFF2DD4BF) : mauChinh;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time_filled_rounded, color: mauChuDao, size: 24),
              const SizedBox(width: 8),
              Text(
                'Cuộn chọn Giờ & Phút',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : const Color(0xFF1E232A),
                ),
              ),
            ],
          ),
          content: SizedBox(
            height: 180,
            child: Stack(
              children: [
                // Khung đánh dấu vùng đang chọn ở giữa
                Center(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: mauChuDao.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: mauChuDao.withValues(alpha: 0.4), width: 1.5),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cột chọn Giờ (00 -> 23)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Giờ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: gioController,
                              itemExtent: 40,
                              perspective: 0.003,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                gioDaChon = index;
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 24,
                                builder: (context, index) {
                                  final String haiSo = index.toString().padLeft(2, '0');
                                  return Center(
                                    child: Text(
                                      '$haiSo giờ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF1E232A),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      ':',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: mauChuDao,
                      ),
                    ),
                    // Cột chọn Phút (00 -> 59)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Phút',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: ListWheelScrollView.useDelegate(
                              controller: phutController,
                              itemExtent: 40,
                              perspective: 0.003,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) {
                                phutDaChon = index;
                              },
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 60,
                                builder: (context, index) {
                                  final String haiSo = index.toString().padLeft(2, '0');
                                  return Center(
                                    child: Text(
                                      '$haiSo phút',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : const Color(0xFF1E232A),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.all(16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E232A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      setState(() {
                        _ngayChon = DateTime(
                          ngay.year,
                          ngay.month,
                          ngay.day,
                          gioDaChon,
                          phutDaChon,
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mauChuDao,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Xác nhận',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _chonNgayGio() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final ngay = await showDatePicker(
      context: context,
      initialDate: _ngayChon,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (ngay == null || !mounted) return;

    await _hienThanhCuonChonGio(ngay, isDark);
  }

  String _dinhDangNgayGio(DateTime d) {
    String hai(int n) => n.toString().padLeft(2, '0');
    return '${hai(d.day)}/${hai(d.month)}/${d.year} - ${hai(d.hour)}:${hai(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final danhMucKhaDung = quanLy.danhSachDanhMuc.where((c) => c.loai == _loai).toList();

    _danhMucChon ??= danhMucKhaDung.isNotEmpty ? danhMucKhaDung.first : null;

    final bool chuacoThuNhap = _loai == LoaiGiaoDich.chiTieu && quanLy.tongThuNhap <= 0;
    final Color mauChuDao = isDark ? const Color(0xFF2DD4BF) : mauChinh;
    final Color mauThuNhap = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF27AE60);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Thêm giao dịch mới',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1E232A),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nút chuyển Chi tiêu / Thu nhập
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF062320).withValues(alpha: 0.9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF134E48) : const Color(0xFFE8EAE5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _taoNutLoai(
                      loai: LoaiGiaoDich.chiTieu,
                      nhan: 'Chi tiêu',
                      mauKichHoat: mauChiTieu,
                      isDark: isDark,
                      quanLy: quanLy,
                    ),
                  ),
                  Expanded(
                    child: _taoNutLoai(
                      loai: LoaiGiaoDich.thuNhap,
                      nhan: 'Thu nhập',
                      mauKichHoat: mauThuNhap,
                      isDark: isDark,
                      quanLy: quanLy,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cảnh báo khi chưa có thu nhập mà chọn Chi tiêu
            if (chuacoThuNhap)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade700, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bạn chưa có thu nhập nào. Vui lòng nhập thu nhập vào trước mới được chi tiêu!',
                        style: TextStyle(
                          color: isDark ? Colors.amber.shade200 : Colors.amber.shade900,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Nhập số tiền
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF062320).withValues(alpha: 0.88) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF134E48) : const Color(0xFFE8EAE5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số tiền',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF99F6E4) : Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _loai == LoaiGiaoDich.thuNhap ? '+' : '-',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: _loai == LoaiGiaoDich.thuNhap
                              ? mauThuNhap
                              : mauChiTieu,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _soTienController,
                          autofocus: true,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: false,
                            signed: false,
                          ),
                          inputFormatters: [DinhDangTienInputFormatter()],
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: isDark ? const Color(0xFF115E59) : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'đ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFF99F6E4) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tiêu đề
            _taoONhap(
              controller: _tieuDeController,
              nhan: 'Tên giao dịch / Nội dung',
              goiY: 'Ví dụ: Ăn trưa, Mua quần áo...',
              icon: Icons.edit_note_rounded,
              isDark: isDark,
            ),

            const SizedBox(height: 20),

            // Chọn danh mục
            Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E232A),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: danhMucKhaDung.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 14,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                final cat = danhMucKhaDung[index];
                final dangChon = _danhMucChon?.id == cat.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _danhMucChon = cat;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    transform: Matrix4.translationValues(0, dangChon ? -7 : 0, 0),
                    decoration: BoxDecoration(
                      color: dangChon
                          ? cat.mauSac
                          : (isDark ? const Color(0xFF062320).withValues(alpha: 0.88) : Colors.white),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: dangChon
                            ? cat.mauSac
                            : (isDark ? const Color(0xFF134E48) : const Color(0xFFE8EAE5)),
                        width: dangChon ? 2.5 : 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: dangChon
                              ? cat.mauSac.withValues(alpha: 0.45)
                              : Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                          blurRadius: dangChon ? 12 : 2,
                          offset: Offset(0, dangChon ? 6 : 1),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat.icon,
                          color: dangChon ? Colors.white : cat.mauSac,
                          size: 28,
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Text(
                            cat.tenDanhMuc,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: dangChon ? FontWeight.bold : FontWeight.w600,
                              color: dangChon
                                  ? Colors.white
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Chọn ngày + giờ
            GestureDetector(
              onTap: _chonNgayGio,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF062320).withValues(alpha: 0.88) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF134E48) : const Color(0xFFE8EAE5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_rounded, color: mauChuDao),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Thời gian: ${_dinhDangNgayGio(_ngayChon)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: isDark ? const Color(0xFF99F6E4) : Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Ghi chú
            _taoONhap(
              controller: _ghiChuController,
              nhan: 'Ghi chú thêm',
              goiY: 'Nhập chi tiết ghi chú...',
              icon: Icons.notes_rounded,
              soDong: 2,
              isDark: isDark,
            ),

            const SizedBox(height: 24),

            // Chỉ xuất hiện Nút Lưu khi có số tiền > 0 được nhập
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: _coSoTien
                  ? SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          final double? soTien = DinhDangTienInputFormatter.giaiMaSoTien(_soTienController.text);
                          final String tieuDe = _tieuDeController.text.trim().isNotEmpty
                              ? _tieuDeController.text.trim()
                              : (_danhMucChon?.tenDanhMuc ?? 'Giao dịch');

                          final ketQua = KiemTraDieuKien.kiemTraGiaoDichTongHop(
                            laChiTieu: _loai == LoaiGiaoDich.chiTieu,
                            soTien: soTien,
                            tieuDe: tieuDe,
                            ngayGiaoDich: _ngayChon,
                            tongThuNhap: quanLy.tongThuNhap,
                            tongSoDu: quanLy.tongSoDu,
                          );

                          if (!ketQua.hopLe) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(ketQua.thongBao),
                                backgroundColor: Colors.redAccent,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          final giaoDichMoi = MoHinhGiaoDich(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            tieuDe: tieuDe,
                            soTien: soTien!,
                            ngayGiaoDich: _ngayChon,
                            loai: _loai,
                            icon: _danhMucChon?.icon ?? Icons.receipt_long_rounded,
                            mauNenIcon: _danhMucChon?.mauSac.withValues(alpha: 0.2) ?? const Color(0xFFFFE7D9),
                            danhMuc: _danhMucChon?.tenDanhMuc ?? 'Khác',
                            ghiChu: _ghiChuController.text.trim(),
                          );

                          await quanLy.themGiaoDich(giaoDichMoi);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã lưu giao dịch thành công!')),
                            );
                            if (widget.khiDaLuu != null) {
                              widget.khiDaLuu!();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _loai == LoaiGiaoDich.thuNhap ? const Color(0xFF27AE60) : mauChiTieu,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        child: const Text(
                          'Lưu giao dịch',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _taoNutLoai({
    required LoaiGiaoDich loai,
    required String nhan,
    required Color mauKichHoat,
    bool isDark = false,
    required QuanLyTrangThaiApp quanLy,
  }) {
    final bool dangChon = _loai == loai;
    return GestureDetector(
      onTap: () {
        setState(() {
          _loai = loai;
          final danhMucKhaDung = quanLy.danhSachDanhMuc.where((c) => c.loai == _loai).toList();
          _danhMucChon = danhMucKhaDung.isNotEmpty ? danhMucKhaDung.first : null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: dangChon ? mauKichHoat : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            nhan,
            style: TextStyle(
              color: dangChon
                  ? Colors.white
                  : (isDark ? const Color(0xFF94A3B8) : Colors.black87),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _taoONhap({
    required TextEditingController controller,
    required String nhan,
    required String goiY,
    required IconData icon,
    int soDong = 1,
    bool isDark = false,
  }) {
    final Color mauChuDao = isDark ? const Color(0xFF2DD4BF) : mauChinh;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nhan,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E232A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: soDong,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: goiY,
            hintStyle: TextStyle(color: isDark ? const Color(0xFF99F6E4) : Colors.grey),
            prefixIcon: Icon(icon, color: mauChuDao),
            filled: true,
            fillColor: isDark ? const Color(0xFF062320).withValues(alpha: 0.88) : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF134E48) : const Color(0xFFE8EAE5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: mauChuDao, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
