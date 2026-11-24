import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dich_vu/quan_ly_trang_thai_app.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import '../thien_ich/dinh_dang_tien.dart';

// Mục trong danh sách đã gom nhóm theo ngày
class _TieuDeNgay {
  final String nhan;
  final double tongThu;
  final double tongChi;
  const _TieuDeNgay(this.nhan, this.tongThu, this.tongChi);
}

class ManHinhDanhSachGiaoDich extends StatefulWidget {
  final Function(MoHinhGiaoDich)? chonGiaoDich;

  const ManHinhDanhSachGiaoDich({
    super.key,
    this.chonGiaoDich,
  });

  @override
  State<ManHinhDanhSachGiaoDich> createState() => _ManHinhDanhSachGiaoDichState();
}

class _ManHinhDanhSachGiaoDichState extends State<ManHinhDanhSachGiaoDich> {
  int _viTriLoc = 0; // 0: Tất cả, 1: Thu nhập, 2: Chi tiêu
  String _tuKhoaTimKiem = '';

  // Bộ lọc nâng cao
  DateTime? _tuNgay;
  DateTime? _denNgay;
  double? _soTienMin;
  double? _soTienMax;
  String? _danhMucChonLoc;

  // Chế độ chọn nhiều để xóa hàng loạt (Long-press & Select All)
  bool _cheDoChonNhieu = false;
  final Set<String> _dsIdDaChon = {};

  bool get _dangDungBoLocNangCao =>
      _tuNgay != null ||
      _denNgay != null ||
      _soTienMin != null ||
      _soTienMax != null ||
      (_danhMucChonLoc != null && _danhMucChonLoc!.isNotEmpty);

  static const Color mauChinh = Color(0xFFE07852);
  static const Color mauThu = Color(0xFF27AE60);
  static const List<String> _nhanLoc = ['Tất cả', 'Thu nhập', 'Chi tiêu'];

  String _nhanNgay(DateTime d) {
    final now = DateTime.now();
    final homNay = DateTime(now.year, now.month, now.day);
    final ngay = DateTime(d.year, d.month, d.day);
    final chenh = homNay.difference(ngay).inDays;
    if (chenh == 0) return 'Hôm nay';
    if (chenh == 1) return 'Hôm qua';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  // Lọc + sắp xếp mới nhất trước + gom nhóm theo ngày
  List<Object> _taoDanhSachHienThi(List<MoHinhGiaoDich> nguon) {
    final tk = _tuKhoaTimKiem.toLowerCase();
    final loc = nguon.where((item) {
      if (_viTriLoc == 1 && !item.laThuNhap) return false;
      if (_viTriLoc == 2 && item.laThuNhap) return false;

      if (tk.isNotEmpty &&
          !item.tieuDe.toLowerCase().contains(tk) &&
          !item.danhMuc.toLowerCase().contains(tk)) {
        return false;
      }

      if (_tuNgay != null) {
        final tu = DateTime(_tuNgay!.year, _tuNgay!.month, _tuNgay!.day);
        if (item.ngayGiaoDich.isBefore(tu)) return false;
      }
      if (_denNgay != null) {
        final den = DateTime(_denNgay!.year, _denNgay!.month, _denNgay!.day, 23, 59, 59);
        if (item.ngayGiaoDich.isAfter(den)) return false;
      }

      if (_soTienMin != null && item.soTien < _soTienMin!) return false;
      if (_soTienMax != null && item.soTien > _soTienMax!) return false;

      if (_danhMucChonLoc != null &&
          _danhMucChonLoc!.isNotEmpty &&
          item.danhMuc != _danhMucChonLoc) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) => b.ngayGiaoDich.compareTo(a.ngayGiaoDich));

    final Map<String, List<MoHinhGiaoDich>> nhom = {};
    for (final tx in loc) {
      final d = tx.ngayGiaoDich;
      final khoa = '${d.year}-${d.month}-${d.day}';
      nhom.putIfAbsent(khoa, () => []).add(tx);
    }

    final List<Object> ketQua = [];
    for (final ds in nhom.values) {
      double thu = 0, chi = 0;
      for (final tx in ds) {
        tx.laThuNhap ? thu += tx.soTien : chi += tx.soTien;
      }
      ketQua.add(_TieuDeNgay(_nhanNgay(ds.first.ngayGiaoDich), thu, chi));
      ketQua.addAll(ds);
    }
    return ketQua;
  }

  void _hienHopThoaiBoLocNangCao(
    BuildContext context,
    QuanLyTrangThaiApp quanLy,
    bool isDark,
  ) {
    DateTime? tuNgayTam = _tuNgay;
    DateTime? denNgayTam = _denNgay;
    String? danhMucTam = _danhMucChonLoc;

    final minCtrl = TextEditingController(
      text: _soTienMin != null ? DinhDangTienInputFormatter.dinhDang(_soTienMin!) : '',
    );
    final maxCtrl = TextEditingController(
      text: _soTienMax != null ? DinhDangTienInputFormatter.dinhDang(_soTienMax!) : '',
    );

    final tapHopDanhMuc = quanLy.danhSachDanhMuc.map((e) => e.tenDanhMuc).toSet().toList();
    final Color mauNhan = isDark ? const Color(0xFF2DD4BF) : mauChinh;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF062320) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Bộ lọc tìm kiếm nâng cao',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          color: isDark ? const Color(0xFF99F6E4) : Colors.grey,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Khoảng thời gian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFCCFBF1) : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: tuNgayTam ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setModalState(() => tuNgayTam = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF041D1A) : const Color(0xFFF7F8F4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 18, color: mauNhan),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      tuNgayTam != null
                                          ? '${tuNgayTam!.day}/${tuNgayTam!.month}/${tuNgayTam!.year}'
                                          : 'Từ ngày...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: ctx,
                                initialDate: denNgayTam ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setModalState(() => denNgayTam = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF041D1A) : const Color(0xFFF7F8F4),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.event_rounded, size: 18, color: mauNhan),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      denNgayTam != null
                                          ? '${denNgayTam!.day}/${denNgayTam!.month}/${denNgayTam!.year}'
                                          : 'Đến ngày...',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Khoảng số tiền (VNĐ)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFCCFBF1) : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [DinhDangTienInputFormatter()],
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Từ số tiền (Min)',
                              labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF99F6E4) : Colors.grey),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF041D1A) : const Color(0xFFF7F8F4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: maxCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [DinhDangTienInputFormatter()],
                            style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              labelText: 'Đến số tiền (Max)',
                              labelStyle: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF99F6E4) : Colors.grey),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF041D1A) : const Color(0xFFF7F8F4),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'Danh mục giao dịch',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFCCFBF1) : const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: danhMucTam,
                      dropdownColor: isDark ? const Color(0xFF041D1A) : Colors.white,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Tất cả danh mục',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF99F6E4) : Colors.grey),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF041D1A) : const Color(0xFFF7F8F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Tất cả danh mục'),
                        ),
                        ...tapHopDanhMuc.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat,
                            child: Text(cat),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setModalState(() => danhMucTam = val);
                      },
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _tuNgay = null;
                                _denNgay = null;
                                _soTienMin = null;
                                _soTienMax = null;
                                _danhMucChonLoc = null;
                              });
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide(color: isDark ? const Color(0xFF134E48) : Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Đặt lại',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF99F6E4) : Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final minVal = DinhDangTienInputFormatter.giaiMaSoTien(minCtrl.text);
                              final maxVal = DinhDangTienInputFormatter.giaiMaSoTien(maxCtrl.text);
                              setState(() {
                                _tuNgay = tuNgayTam;
                                _denNgay = denNgayTam;
                                _soTienMin = minVal;
                                _soTienMax = maxVal;
                                _danhMucChonLoc = danhMucTam;
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: mauNhan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Áp dụng',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF042F2E) : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _hienHopThoaiSuaGiaoDich(
    BuildContext context,
    QuanLyTrangThaiApp quanLy,
    MoHinhGiaoDich item,
    bool isDark,
  ) {
    final tieuDeCtrl = TextEditingController(text: item.tieuDe);
    final soTienCtrl = TextEditingController(
      text: DinhDangTienInputFormatter.dinhDang(item.soTien),
    );
    final ghiChuCtrl = TextEditingController(text: item.ghiChu);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF062320) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chỉnh sửa giao dịch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tieuDeCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Tên giao dịch',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF041D1A) : const Color(0xFFF7F8F4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: soTienCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DinhDangTienInputFormatter()],
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Số tiền (VNĐ)',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF041D1A) : const Color(0xFFF7F8F4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ghiChuCtrl,
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Ghi chú',
                    filled: true,
                    fillColor: isDark ? const Color(0xFF041D1A) : const Color(0xFFF7F8F4),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final double? st = DinhDangTienInputFormatter.giaiMaSoTien(soTienCtrl.text);
                      if (st == null || st <= 0) return;

                      final itemSua = MoHinhGiaoDich(
                        id: item.id,
                        tieuDe: tieuDeCtrl.text.trim().isNotEmpty ? tieuDeCtrl.text.trim() : item.danhMuc,
                        soTien: st,
                        ngayGiaoDich: item.ngayGiaoDich,
                        loai: item.loai,
                        icon: item.icon,
                        mauNenIcon: item.mauNenIcon,
                        danhMuc: item.danhMuc,
                        ghiChu: ghiChuCtrl.text.trim(),
                      );

                      await quanLy.capNhatGiaoDich(itemSua);
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã cập nhật giao dịch thành công!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF2DD4BF) : mauChinh,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Cập nhật giao dịch',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? const Color(0xFF042F2E) : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _xacNhanXoaCacGiaoDich(BuildContext context, QuanLyTrangThaiApp quanLy) {
    if (_dsIdDaChon.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa hàng loạt'),
          content: Text('Bạn có chắc chắn muốn xóa ${_dsIdDaChon.length} giao dịch đã chọn không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                for (final id in _dsIdDaChon.toList()) {
                  await quanLy.xoaGiaoDich(id);
                }
                setState(() {
                  _dsIdDaChon.clear();
                  _cheDoChonNhieu = false;
                });
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xóa thành công các giao dịch đã chọn!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Xóa tất cả', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color mauChuDao = isDark ? const Color(0xFF2DD4BF) : mauChinh;
    final quanLy = QuanLyTrangThaiScope.of(context);
    final mucHienThi = _taoDanhSachHienThi(quanLy.danhSachGiaoDich);
    final giaoDichLoc = mucHienThi.whereType<MoHinhGiaoDich>().toList();

    double tongThu = 0, tongChi = 0;
    for (final tx in giaoDichLoc) {
      tx.laThuNhap ? tongThu += tx.soTien : tongChi += tx.soTien;
    }

    final bool chonTatCaActive = _dsIdDaChon.length == giaoDichLoc.length && giaoDichLoc.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar với Chế độ Chọn Nhiều / Sửa / Xóa
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _cheDoChonNhieu ? 'Đã chọn ${_dsIdDaChon.length}' : 'Lịch sử giao dịch',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1E232A),
                      ),
                    ),
                  ),

                  if (_cheDoChonNhieu) ...[
                    // Nút Chọn Tất Cả / Bỏ Chọn Tất Cả
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          if (chonTatCaActive) {
                            _dsIdDaChon.clear();
                          } else {
                            _dsIdDaChon.addAll(giaoDichLoc.map((e) => e.id));
                          }
                        });
                      },
                      icon: Icon(
                        chonTatCaActive ? Icons.check_box_outlined : Icons.select_all_rounded,
                        size: 18,
                        color: mauChuDao,
                      ),
                      label: Text(
                        chonTatCaActive ? 'Bỏ chọn' : 'Chọn tất cả',
                        style: TextStyle(color: mauChuDao, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),

                    // Nút Xóa Hàng Loạt
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                      tooltip: 'Xóa các mục đã chọn',
                      onPressed: () => _xacNhanXoaCacGiaoDich(context, quanLy),
                    ),

                    // Nút Thoát Chọn Nhiều
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: isDark ? Colors.white70 : Colors.black54,
                      onPressed: () {
                        setState(() {
                          _cheDoChonNhieu = false;
                          _dsIdDaChon.clear();
                        });
                      },
                    ),
                  ] else ...[
                    // Nút Bật Chế Độ Chọn Nhiều / Xóa
                    IconButton(
                      icon: const Icon(Icons.checklist_rounded),
                      color: mauChuDao,
                      tooltip: 'Chọn nhiều để xóa',
                      onPressed: () {
                        setState(() {
                          _cheDoChonNhieu = true;
                        });
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: mauChuDao.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${giaoDichLoc.length} giao dịch',
                        style: TextStyle(
                            color: mauChuDao, fontWeight: FontWeight.w600, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Thẻ tổng quan thu / chi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _theTongQuan(tongThu, tongChi, isDark),
            ),
            const SizedBox(height: 14),

            // Ô tìm kiếm & Nút Lọc nâng cao
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _tuKhoaTimKiem = v),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên hoặc danh mục...',
                        hintStyle: TextStyle(color: isDark ? const Color(0xFF99F6E4) : Colors.grey),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: isDark ? const Color(0xFF99F6E4) : Colors.grey),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF062320).withValues(alpha: 0.9)
                            : Colors.white,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                              color: isDark ? const Color(0xFF134E48) : Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: mauChuDao, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _hienHopThoaiBoLocNangCao(context, quanLy, isDark),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _dangDungBoLocNangCao
                            ? mauChuDao
                            : (isDark ? const Color(0xFF062320).withValues(alpha: 0.9) : Colors.white),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _dangDungBoLocNangCao
                              ? mauChuDao
                              : (isDark ? const Color(0xFF134E48) : Colors.transparent),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: _dangDungBoLocNangCao
                                ? (isDark ? const Color(0xFF042F2E) : Colors.white)
                                : (isDark ? const Color(0xFF99F6E4) : Colors.black87),
                          ),
                          if (_dangDungBoLocNangCao)
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Bộ lọc dạng segmented có hiệu ứng trượt
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _boLoc(isDark),
            ),
            const SizedBox(height: 8),

            // Danh sách giao dịch
            Expanded(
              child: mucHienThi.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              size: 54,
                              color: isDark ? const Color(0xFF475569) : Colors.black26),
                          const SizedBox(height: 10),
                          Text(
                            'Không tìm thấy giao dịch nào',
                            style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                      itemCount: mucHienThi.length,
                      itemBuilder: (context, index) {
                        final muc = mucHienThi[index];
                        if (muc is _TieuDeNgay) return _tieuDeNgay(muc, isDark);
                        final tx = muc as MoHinhGiaoDich;
                        return _hienDan(
                          key: ValueKey(tx.id),
                          index: index,
                          child: _mucGiaoDich(tx, isDark, quanLy),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Thành phần ----------

  Widget _theTongQuan(double thu, double chi, bool isDark) {
    Widget taoCotSoLieu(IconData icon, String nhan, double so) => Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nhan,
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DinhDangTienInputFormatter.dinhDang(so),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

    final List<Color> gradientMau = isDark
        ? const [Color(0xFF0F766E), Color(0xFF14B8A6)]
        : const [Color(0xFFE07852), Color(0xFF8B5CF6)];

    final Color mauBong = isDark
        ? const Color(0xFF14B8A6).withValues(alpha: 0.3)
        : mauChinh.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientMau,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: mauBong,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          taoCotSoLieu(Icons.south_west_rounded, 'Thu nhập', thu),
          Container(width: 1, height: 36, color: Colors.white24),
          const SizedBox(width: 12),
          taoCotSoLieu(Icons.north_east_rounded, 'Chi tiêu', chi),
        ],
      ),
    );
  }

  Widget _boLoc(bool isDark) {
    final Color mauChon = isDark ? const Color(0xFF2DD4BF) : mauChinh;
    return LayoutBuilder(builder: (context, c) {
      final double rong = (c.maxWidth - 8) / 3;
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF062320).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF134E48) : Colors.transparent,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              left: rong * _viTriLoc,
              top: 0,
              bottom: 0,
              width: rong,
              child: Container(
                decoration: BoxDecoration(
                  color: mauChon,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Row(
              children: List.generate(3, (i) {
                final chon = _viTriLoc == i;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _viTriLoc = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: chon ? FontWeight.bold : FontWeight.w500,
                            color: chon
                                ? (isDark ? const Color(0xFF042F2E) : Colors.white)
                                : (isDark ? const Color(0xFF99F6E4) : Colors.black54),
                          ),
                          child: Text(_nhanLoc[i]),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  Widget _tieuDeNgay(_TieuDeNgay h, bool isDark) {
    final mauChu = isDark ? const Color(0xFF94A3B8) : Colors.black54;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Row(
        children: [
          Text(
            h.nhan,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Spacer(),
          if (h.tongThu > 0)
            Text('+${DinhDangTienInputFormatter.dinhDang(h.tongThu)}  ',
                style: const TextStyle(
                    color: mauThu, fontSize: 12, fontWeight: FontWeight.w600)),
          if (h.tongChi > 0)
            Text('-${DinhDangTienInputFormatter.dinhDang(h.tongChi)}',
                style: TextStyle(
                    color: mauChu, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _hienDan({required Key key, required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + math.min(index, 8) * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: c),
      ),
      child: child,
    );
  }

  Widget _mucGiaoDich(MoHinhGiaoDich item, bool isDark, QuanLyTrangThaiApp quanLy) {
    final t = item.ngayGiaoDich;
    final gio =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    final mauTien = item.laThuNhap
        ? (isDark ? const Color(0xFF2DD4BF) : mauThu)
        : (isDark ? const Color(0xFFFF8A80) : mauChinh);

    final bool duocChon = _dsIdDaChon.contains(item.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: duocChon
            ? (isDark ? const Color(0xFF134E48) : const Color(0xFFFFE7D9))
            : (isDark
                ? const Color(0xFF062320).withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.95)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: duocChon
              ? (isDark ? const Color(0xFF2DD4BF) : mauChinh)
              : (isDark ? const Color(0xFF134E48) : const Color(0xFFF0F1EE)),
          width: duocChon ? 2.0 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (_cheDoChonNhieu) {
              setState(() {
                if (duocChon) {
                  _dsIdDaChon.remove(item.id);
                } else {
                  _dsIdDaChon.add(item.id);
                }
              });
            } else {
              widget.chonGiaoDich?.call(item);
            }
          },
          onLongPress: () {
            setState(() {
              _cheDoChonNhieu = true;
              _dsIdDaChon.add(item.id);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                if (_cheDoChonNhieu)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      duocChon ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: duocChon ? (isDark ? const Color(0xFF2DD4BF) : mauChinh) : Colors.grey,
                    ),
                  ),

                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: item.mauNenIcon,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.icon, color: Colors.black87),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.tieuDe,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: mauTien.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.danhMuc,
                              style: TextStyle(
                                  color: mauTien,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            gio,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.laThuNhap ? '+' : '-'}${DinhDangTienInputFormatter.dinhDang(item.soTien)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: mauTien,
                      ),
                    ),
                    if (!_cheDoChonNhieu) ...[
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _hienHopThoaiSuaGiaoDich(context, quanLy, item, isDark),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.edit_outlined, size: 14, color: Colors.blue),
                              SizedBox(width: 2),
                              Text('Sửa', style: TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
