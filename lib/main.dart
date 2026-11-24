import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dich_vu/firebase_options.dart';
import 'cot_loi/giao_dien/giao_dien_app.dart';
import 'cot_loi/giao_dien/khung_nen_app.dart';
import 'dich_vu/dich_vu_csdl.dart';
import 'dich_vu/dich_vu_thong_bao.dart';
import 'dich_vu/quan_ly_trang_thai_app.dart';
import 'mo_hinh/mo_hinh_giao_dich.dart';
import 'thanh_phan/thanh_dieu_huong_duoi.dart';
import 'khoi_dau/man_hinh_khoi_dau.dart';
import 'trang_chu/man_hinh_trang_chu.dart';
import 'giao_dich/man_hinh_danh_sach_giao_dich.dart';
import 'giao_dich/man_hinh_them_giao_dich.dart';
import 'giao_dich/man_hinh_chi_tiet_giao_dich.dart';
import 'thong_ke/man_hinh_thong_ke.dart';
import 'danh_muc/man_hinh_danh_muc.dart';
import 'ngan_sach/man_hinh_ngan_sach.dart';
import 'cai_dat/man_hinh_cai_dat.dart';
import 'thong_bao/man_hinh_cai_dat_thong_bao.dart';
import 'log in/dang_ky.dart';
import 'log in/dang_nhap.dart';

void     main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UngDungQuanLyChiTieu());
}

typedef ExpenseApp = UngDungQuanLyChiTieu;
typedef MyApp = UngDungQuanLyChiTieu;

class UngDungQuanLyChiTieu extends StatefulWidget {
  const UngDungQuanLyChiTieu({super.key});

  @override
  State<UngDungQuanLyChiTieu> createState() => _UngDungQuanLyChiTieuState();
}

class _UngDungQuanLyChiTieuState extends State<UngDungQuanLyChiTieu> {
  final QuanLyTrangThaiApp _quanLyTrangThai = QuanLyTrangThaiApp();
  bool _daHoanThanhKhoiDau = false;
  bool _laGiaoDienToi = false;

  @override
  void initState() {
    super.initState();
    _taiCauHinhGiaoDien();
    DichVuThongBao().khoiTao();
  }

  Future<void> _taiCauHinhGiaoDien() async {
    final laToi = await DichVuCSDL.layGiaoDienToi();
    final daDangNhap = await DichVuCSDL.kiemTraDangNhap();
    final email = await DichVuCSDL.layNguoiDungHienTai();

    if (daDangNhap && email != null && email.isNotEmpty) {
      await _quanLyTrangThai.chuyenNguoiDung(email);
    } else {
      await _quanLyTrangThai.dangXuat();
    }

    if (mounted) {
      setState(() {
        _laGiaoDienToi = laToi;
      });
    }
  }

  void _doiGiaoDienToi(bool laGiaoDienToi) {
    setState(() {
      _laGiaoDienToi = laGiaoDienToi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return QuanLyTrangThaiScope(
      quanLyTrangThai: _quanLyTrangThai,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quản lý chi tiêu',
        theme: GiaoDienApp.giaoDienSang,
        darkTheme: GiaoDienApp.giaoDienToi,
        themeMode: _laGiaoDienToi ? ThemeMode.dark : ThemeMode.light,
        home: _daHoanThanhKhoiDau
            ? DieuHuongChinh(
          laGiaoDienToi: _laGiaoDienToi,
          khiDoiGiaoDienToi: _doiGiaoDienToi,
        )
            : ManHinhKhoiDau(
          thoiGianChoGiay: 10,
          khiHoanThanh: () {
            setState(() {
              _daHoanThanhKhoiDau = true;
            });
          },
        ),
      ),
    );
  }
}

class DieuHuongChinh extends StatefulWidget {
  final bool laGiaoDienToi;
  final ValueChanged<bool> khiDoiGiaoDienToi;

  const DieuHuongChinh({
    super.key,
    required this.laGiaoDienToi,
    required this.khiDoiGiaoDienToi,
  });

  bool get isDarkMode => laGiaoDienToi;
  ValueChanged<bool> get onToggleDarkMode => khiDoiGiaoDienToi;

  @override
  State<DieuHuongChinh> createState() => _DieuHuongChinhState();
}

class _DieuHuongChinhState extends State<DieuHuongChinh> {
  int _viTriTab = 0;
  MoHinhGiaoDich? _giaoDichDuocChon;
  int _viTriManHinhDocLap = -1;
  int? _subScreen; // Màn hình con mở từ tab (vẫn GIỮ THANH MENU DƯỚI)

  final List<String> _tenCacManHinh = [
    '0. Màn hình khởi đầu (Loading 10s)',
    '1. Trang chủ (Trang chu)',
    '2. Danh sách giao dịch (Danh sach giao dich)',
    '3. Thêm giao dịch mới (Them giao dich)',
    '4. Chi tiết giao dịch (Chi tiet giao dich)',
    '5. Thống kê & Báo cáo (Thong ke)',
    '6. Quản lý danh mục (Danh muc)',
    '7. Ngân sách & Tiết kiệm (Ngan sach)',
    '8. Cài đặt & Tài khoản (Cai dat)',
    '9. Đăng ký tài khoản (Dang ky)',
    '10. Đăng nhập (Dang nhap)',
    '11. Cài đặt thông báo & Nhắc nhở (Thong bao)',
  ];

  @override
  Widget build(BuildContext context) {
    Widget noiDung;

    if (_viTriManHinhDocLap != -1) {
      noiDung = _taoManHinhDocLap(_viTriManHinhDocLap);
    } else if (_subScreen != null) {
      switch (_subScreen) {
        case 4:
          noiDung = ManHinhChiTietGiaoDich(
            giaoDich: _giaoDichDuocChon ?? (QuanLyTrangThaiScope.of(context).danhSachGiaoDich.isNotEmpty
                ? QuanLyTrangThaiScope.of(context).danhSachGiaoDich.first
                : DuLieuMau.danhSachGiaoDich.first),
            khiQuayLai: () {
              setState(() {
                _subScreen = null;
              });
            },
          );
          break;
        case 6:
          noiDung = ManHinhDanhMuc(
            khiQuayLai: () {
              setState(() {
                _subScreen = null;
              });
            },
          );
          break;
        case 7:
          noiDung = ManHinhNganSach(
            khiQuayLai: () {
              setState(() {
                _subScreen = null;
              });
            },
          );
          break;
        case 11:
          noiDung = ManHinhCaiDatThongBao(
            khiQuayLai: () {
              setState(() {
                _subScreen = null;
              });
            },
          );
          break;
        default:
          noiDung = const ManHinhTrangChu();
      }
    } else {
      switch (_viTriTab) {
        case 0:
          noiDung = ManHinhTrangChu(
            chuyenToiDanhSachGiaoDich: () {
              setState(() {
                _viTriTab = 1;
              });
            },
            chuyenToiThemGiaoDich: () {
              setState(() {
                _viTriTab = 2;
              });
            },
            chuyenToiThongBao: () {
              setState(() {
                _viTriManHinhDocLap = 11;
              });
            },
            chonGiaoDich: (tx) {
              setState(() {
                _giaoDichDuocChon = tx;
                _viTriManHinhDocLap = 4;
              });
            },
          );
          break;
        case 1:
          noiDung = ManHinhDanhSachGiaoDich(
            chonGiaoDich: (tx) {
              setState(() {
                _giaoDichDuocChon = tx;
                _subScreen = 4;
              });
            },
          );
          break;
        case 2:
          noiDung = ManHinhThemGiaoDich(
            khiDaLuu: () {
              setState(() {
                _viTriTab = 0;
              });
            },
          );
          break;
        case 3:
          noiDung = const ManHinhThongKe();
          break;
        case 4:
          noiDung = ManHinhCaiDat(
            laGiaoDienToi: widget.isDarkMode,
            khiDoiGiaoDienToi: widget.onToggleDarkMode,
            chuyenToiDanhMuc: () {
              setState(() {
                _subScreen = 6;
              });
            },
            chuyenToiNganSach: () {
              setState(() {
                _subScreen = 7;
              });
            },
            chuyenToiThongBao: () {
              setState(() {
                _subScreen = 11;
              });
            },
            dangXuat: () {
              setState(() {
                _viTriTab = 0;
                _subScreen = null;
                _viTriManHinhDocLap = 10;
              });
            },
          );
          break;
        default:
          noiDung = const ManHinhTrangChu();
      }
    }

    return KhungNenApp(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          toolbarHeight: 46,
          backgroundColor: widget.isDarkMode
              ? const Color(0xFF062320)
              : const Color(0xFFE07852),
          foregroundColor: Colors.white,
          title: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _viTriManHinhDocLap,
              dropdownColor: widget.isDarkMode
                  ? const Color(0xFF092925)
                  : const Color(0xFFB8532F),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
              icon: const Icon(Icons.arrow_drop_down_rounded,
                  color: Colors.white),
              items: [
                const DropdownMenuItem<int>(
                  value: -1,
                  child: Text('📱 Chế độ Xem Toàn Bộ App'),
                ),
                ...List.generate(_tenCacManHinh.length, (index) {
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text('🖼️ ${_tenCacManHinh[index]}'),
                  );
                }),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _viTriManHinhDocLap = value;
                  });
                }
              },
            ),
          ),
          actions: [
            if (_viTriManHinhDocLap != -1)
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _viTriManHinhDocLap = -1;
                  });
                },
                icon: const Icon(Icons.arrow_back_rounded,
                    size: 16, color: Colors.white),
                label: const Text('Quay lại',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
            return Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (Widget child, Animation<double> animation) {
            final viTriTruocVaSau = Tween<Offset>(
              begin: const Offset(0.0, 0.20), // Trồi từ dưới lên
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            return SlideTransition(
              position: viTriTruocVaSau,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(_viTriManHinhDocLap != -1
                ? 1000 + _viTriManHinhDocLap
                : (_subScreen != null ? 100 + _subScreen! : _viTriTab)),
            child: noiDung,
          ),
        ),
        bottomNavigationBar: (_viTriManHinhDocLap == -1 ||
                _viTriManHinhDocLap == 1 ||
                _viTriManHinhDocLap == 2 ||
                _viTriManHinhDocLap == 3 ||
                _viTriManHinhDocLap == 4 ||
                _viTriManHinhDocLap == 5 ||
                _viTriManHinhDocLap == 6 ||
                _viTriManHinhDocLap == 7 ||
                _viTriManHinhDocLap == 8 ||
                _viTriManHinhDocLap == 11)
            ? ThanhDieuHuongDuoi(
                viTriHienTai: _viTriTab,
                khiChon: (index) {
                  setState(() {
                    _viTriManHinhDocLap = -1;
                    _subScreen = null;
                    _viTriTab = index;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _taoManHinhDocLap(int index) {
    switch (index) {
      case 0:
        return ManHinhKhoiDau(
          thoiGianChoGiay: 10,
          khiHoanThanh: () => setState(() => _viTriManHinhDocLap = -1),
        );
      case 1:
        return ManHinhTrangChu(
          chuyenToiDanhSachGiaoDich: () =>
              setState(() => _viTriManHinhDocLap = 2),
          chuyenToiThemGiaoDich: () =>
              setState(() => _viTriManHinhDocLap = 3),
          chuyenToiThongBao: () =>
              setState(() => _viTriManHinhDocLap = 11),
          chonGiaoDich: (tx) => setState(() {
            _giaoDichDuocChon = tx;
            _viTriManHinhDocLap = 4;
          }),
        );
      case 2:
        return ManHinhDanhSachGiaoDich(
          chonGiaoDich: (tx) => setState(() {
            _giaoDichDuocChon = tx;
            _viTriManHinhDocLap = 4;
          }),
        );
      case 3:
        return ManHinhThemGiaoDich(
          khiDaLuu: () => setState(() => _viTriManHinhDocLap = 1),
        );
      case 4:
        return ManHinhChiTietGiaoDich(
          giaoDich: _giaoDichDuocChon ?? DuLieuMau.danhSachGiaoDich.first,
          khiQuayLai: () => setState(() => _viTriManHinhDocLap = 1),
        );
      case 5:
        return const ManHinhThongKe();
      case 6:
        return ManHinhDanhMuc(
          khiQuayLai: () => setState(() => _viTriManHinhDocLap = 8),
        );
      case 7:
        return ManHinhNganSach(
          khiQuayLai: () => setState(() => _viTriManHinhDocLap = 8),
        );
      case 8:
        return ManHinhCaiDat(
          laGiaoDienToi: widget.laGiaoDienToi,
          khiDoiGiaoDienToi: widget.khiDoiGiaoDienToi,
          chuyenToiDanhMuc: () => setState(() => _viTriManHinhDocLap = 6),
          chuyenToiNganSach: () => setState(() => _viTriManHinhDocLap = 7),
          chuyenToiThongBao: () => setState(() => _viTriManHinhDocLap = 11),
          dangXuat: () => setState(() {
            _viTriTab = 0;
            _viTriManHinhDocLap = 10;
          }),
        );
      case 9:
        return ManHinhDangKy(
          chuyenToiDangNhap: () => setState(() => _viTriManHinhDocLap = 10),
          khiDangKyThanhCong: () => setState(() => _viTriManHinhDocLap = -1),
        );
      case 10:
        return ManHinhDangNhap(
          chuyenToiDangKy: () => setState(() => _viTriManHinhDocLap = 9),
          khiDangNhapThanhCong: () => setState(() => _viTriManHinhDocLap = -1),
        );
      case 11:
        return ManHinhCaiDatThongBao(
          khiQuayLai: () => setState(() => _viTriManHinhDocLap = 8),
        );
      default:
        return const ManHinhTrangChu();
    }
  }
}