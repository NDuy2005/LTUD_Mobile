import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../mo_hinh/mo_hinh_giao_dich.dart';
import 'dich_vu_csdl.dart';

/// Kết quả chung cho đăng nhập / đăng ký / sao lưu / phục hồi.
class KetQuaFirebase {
  final bool thanhCong;
  final String thongBao;
  final dynamic duLieu;
  const KetQuaFirebase(this.thanhCong, [this.thongBao = '', this.duLieu]);
}

/// Bản dùng Firebase SDK chính thức. Cần: firebase_core, firebase_auth,
/// firebase_database + Firebase.initializeApp() trong main().
class DichVuFirebase {
  static const Duration _thoiGianCho = Duration(seconds: 15);
  static const String _phienBanDuLieu = '2';

  static DatabaseReference get _dbRef => FirebaseDatabase.instance.ref();
  static FirebaseAuth get _auth => FirebaseAuth.instance;

  static String _nguoiDungHienTai = 'khach';
  static double _soDuBanDau = 0.0;
  static String _hoTen = 'HỨA TRÍ NGUYÊN';

  static final StreamController<List<MoHinhNganSach>> _nganSachStreamController =
  StreamController<List<MoHinhNganSach>>.broadcast();
  static final StreamController<List<MoHinhGiaoDich>> _giaoDichStreamController =
  StreamController<List<MoHinhGiaoDich>>.broadcast();

  static final List<MoHinhNganSach> _danhSachNganSachBoNho = [];
  static final List<MoHinhGiaoDich> _danhSachGiaoDichBoNho = [];

  static Stream<List<MoHinhNganSach>> get luongNganSachStream =>
      _nganSachStreamController.stream;
  static Stream<List<MoHinhGiaoDich>> get luongGiaoDichStream =>
      _giaoDichStreamController.stream;
  static String get nguoiDungHienTai => _nguoiDungHienTai;
  static double get soDuBanDau => _soDuBanDau;
  static String get hoTen => _hoTen;
  static bool get laKhach => _nguoiDungHienTai == 'khach';

  /// Nền tảng đang chạy: web, android, iOS, windows...
  static String get _nenTang => kIsWeb ? 'web' : defaultTargetPlatform.name;

  static String _bayGio() => DateTime.now().toIso8601String();

  static String idTuEmail(String? email) =>
      (email == null || email.trim().isEmpty)
          ? 'khach'
          : email.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');

  // ===================== HÀM GHI CƠ BẢN =====================

  /// Ghi đè hoàn toàn một node. Không treo giao diện khi mất mạng, không ném lỗi.
  static Future<void> _ghi(String path, Object? value) async {
    if (laKhach) return;
    try {
      await _dbRef.child(path).set(value).timeout(_thoiGianCho);
    } catch (e) {
      debugPrint('[Firebase] Ghi $path lỗi: $e');
    }
  }

  /// Gộp thêm trường vào node (không xóa các trường khác). Bỏ qua giá trị null.
  static Future<void> _capNhat(String path, Map<String, Object?> value) async {
    if (laKhach) return;
    final sach = <String, Object?>{};
    value.forEach((k, v) {
      if (v != null) sach[k] = v;
    });
    if (sach.isEmpty) return;
    try {
      await _dbRef.child(path).update(sach).timeout(_thoiGianCho);
    } catch (e) {
      debugPrint('[Firebase] Cập nhật $path lỗi: $e');
    }
  }

  /// Thêm một bản ghi mới vào danh sách (dùng cho lịch sử, không ghi đè).
  static Future<void> _them(String path, Object? value) async {
    if (laKhach) return;
    try {
      await _dbRef.child(path).push().set(value).timeout(_thoiGianCho);
    } catch (e) {
      debugPrint('[Firebase] Thêm $path lỗi: $e');
    }
  }

  static Future<void> _xoa(String path) async {
    if (laKhach) return;
    try {
      await _dbRef.child(path).remove().timeout(_thoiGianCho);
    } catch (e) {
      debugPrint('[Firebase] Xóa $path lỗi: $e');
    }
  }

  /// Đếm số lượng mục trong từng nhóm dữ liệu của gói sao lưu.
  static Map<String, dynamic> _thongKeGoi(Map<String, dynamic> goi) {
    final Map<String, dynamic> kq = {};
    goi.forEach((k, v) {
      if (v is List) kq['so_luong_$k'] = v.length;
      if (v is Map) kq['so_luong_$k'] = v.length;
    });
    return kq;
  }

  // ===================== NGƯỜI DÙNG =====================

  static Future<void> datNguoiDung(String? email) async {
    _nguoiDungHienTai = idTuEmail(email);

    if (_nguoiDungHienTai == 'khach') {
      try {
        await _auth.signOut();
      } catch (_) {}
    }

    _soDuBanDau = await DichVuCSDL.laySoDuBanDau();
    _hoTen =
        (await DichVuCSDL.layThongTinNguoiDung())['hoTen'] ?? 'HỨA TRÍ NGUYÊN';

    unawaited(_capNhat('users/$_nguoiDungHienTai/profile', {
      'uid': _auth.currentUser?.uid,
      'email': email?.trim().toLowerCase(),
      'ho_ten': _hoTen,
      'so_du_ban_dau': _soDuBanDau,
      'nen_tang': _nenTang,
      'last_active': _bayGio(),
    }));
  }

  static Future<void> datSoDuBanDau(double soTien) async {
    _soDuBanDau = soTien;
    await DichVuCSDL.luuSoDuBanDau(soTien);
    unawaited(_ghi('users/$_nguoiDungHienTai/so_du_ban_dau', soTien));
    unawaited(_capNhat('users/$_nguoiDungHienTai/profile', {
      'so_du_ban_dau': soTien,
      'last_active': _bayGio(),
    }));
  }

  static Future<void> datHoTen(String ten) async {
    _hoTen = ten;
    final info = await DichVuCSDL.layThongTinNguoiDung();
    await DichVuCSDL.luuThongTinNguoiDung(email: info['email'] ?? '', hoTen: ten);
    unawaited(_ghi('users/$_nguoiDungHienTai/ho_ten', ten));
    unawaited(_capNhat('users/$_nguoiDungHienTai/profile', {
      'ho_ten': ten,
      'last_active': _bayGio(),
    }));
  }

  // ===================== XÁC THỰC =====================

  static String _dichLoiAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Email này đã được đăng ký. Hãy đăng nhập hoặc dùng email khác.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự).';
      case 'user-not-found':
        return 'Email chưa được đăng ký tài khoản.';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Email hoặc mật khẩu không đúng.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Thử quá nhiều lần. Vui lòng đợi một lúc rồi thử lại.';
      case 'operation-not-allowed':
        return 'Firebase chưa bật đăng nhập Email/Mật khẩu (Authentication -> Sign-in method).';
      case 'network-request-failed':
        return 'Không có kết nối mạng.';
      default:
        return 'Lỗi xác thực (${e.code}).';
    }
  }

  static Future<KetQuaFirebase> dangNhap(String email, String matKhau) async {
    try {
      await _auth
          .signInWithEmailAndPassword(
          email: email.trim().toLowerCase(), password: matKhau)
          .timeout(_thoiGianCho);
    } on FirebaseAuthException catch (e) {
      return KetQuaFirebase(false, _dichLoiAuth(e));
    } on TimeoutException {
      return const KetQuaFirebase(
          false, 'Hết thời gian chờ. Kiểm tra kết nối mạng.');
    } catch (e) {
      return KetQuaFirebase(false, 'Không đăng nhập được: $e');
    }

    final id = idTuEmail(email);
    _nguoiDungHienTai = id;

    String? tenTuXa;
    try {
      final snap =
      await _dbRef.child('users/$id/ho_ten').get().timeout(_thoiGianCho);
      if (snap.exists && snap.value != null) tenTuXa = snap.value.toString();
    } catch (_) {}
    if (tenTuXa != null && tenTuXa.trim().isNotEmpty) _hoTen = tenTuXa;

    final bayGio = _bayGio();
    final user = _auth.currentUser;
    final emailChuan = email.trim().toLowerCase();

    // Lịch sử đăng nhập (mỗi lần một bản ghi)
    unawaited(_them('users/$id/lich_su_dang_nhap', {
      'email': emailChuan,
      'thoi_gian': bayGio,
      'nen_tang': _nenTang,
      'trang_thai': 'Thành công',
    }));
    // Hồ sơ
    unawaited(_capNhat('users/$id/profile', {
      'uid': user?.uid,
      'email': emailChuan,
      'ho_ten': _hoTen,
      'lan_dang_nhap_cuoi': bayGio,
      'email_da_xac_thuc': user?.emailVerified ?? false,
      'nen_tang': _nenTang,
      'last_active': bayGio,
    }));
    // Giữ lại node cũ để tương thích với bản trước
    unawaited(_ghi('users/$id/phien_dang_nhap', {
      'email': email,
      'ngay_dang_nhap': bayGio,
      'trang_thai': 'Thành công',
    }));

    return KetQuaFirebase(true, 'Đăng nhập thành công', tenTuXa);
  }

  static Future<KetQuaFirebase> dangKy(
      String hoTen, String email, String matKhau) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
          email: email.trim().toLowerCase(), password: matKhau)
          .timeout(_thoiGianCho);
    } on FirebaseAuthException catch (e) {
      return KetQuaFirebase(false, _dichLoiAuth(e));
    } on TimeoutException {
      return const KetQuaFirebase(
          false, 'Hết thời gian chờ. Kiểm tra kết nối mạng.');
    } catch (e) {
      return KetQuaFirebase(false, 'Không đăng ký được: $e');
    }

    final id = idTuEmail(email);
    _nguoiDungHienTai = id;
    _hoTen = hoTen;
    final bayGio = _bayGio();
    final emailChuan = email.trim().toLowerCase();

    await _ghi('users/$id/ho_ten', hoTen);
    await _capNhat('users/$id/profile', {
      'uid': _auth.currentUser?.uid,
      'ho_ten': hoTen,
      'email': emailChuan,
      'ngay_tao': bayGio,
      'nen_tang': _nenTang,
      'so_du_ban_dau': _soDuBanDau,
      'last_active': bayGio,
    });
    await _ghi('users/$id/phien_dang_ky', {
      'ho_ten': hoTen,
      'email': email,
      'ngay_tao': bayGio,
      'nen_tang': _nenTang,
    });
    return const KetQuaFirebase(true, 'Đăng ký thành công');
  }

  // ===================== SAO LƯU / PHỤC HỒI =====================

  static String _dichLoiDb(Object e) {
    if (e is TimeoutException) return 'Hết thời gian chờ. Kiểm tra kết nối mạng.';
    final s = e.toString();
    if (s.contains('permission-denied') || s.contains('Permission denied')) {
      return 'Firebase từ chối quyền truy cập. Kiểm tra Rules của Realtime Database và đăng nhập lại.';
    }
    return 'Lỗi Firebase: $s';
  }

  /// Lưu toàn bộ dữ liệu hiện tại của người dùng vào nhánh riêng trên Firebase
  static Future<KetQuaFirebase> saoLuuToanBoDuLieu({
    required String email,
    required Map<String, dynamic> goiDuLieu,
  }) async {
    final userId = idTuEmail(email);
    if (userId == 'khach') {
      return const KetQuaFirebase(
          false, 'Vui lòng đăng nhập trước khi sao lưu.');
    }
    _nguoiDungHienTai = userId;

    try {
      final bayGio = _bayGio();
      final thongKe = _thongKeGoi(goiDuLieu);
      final payload = {
        ...goiDuLieu,
        'email': email.trim().toLowerCase(),
        'uid': _auth.currentUser?.uid,
        'ho_ten': _hoTen,
        'so_du_ban_dau': _soDuBanDau,
        'nen_tang': _nenTang,
        'phien_ban_du_lieu': _phienBanDuLieu,
        'thong_ke': thongKe,
        'cap_nhat_luc': bayGio,
      };
      await _dbRef
          .child('users/$userId/ban_sao_luu')
          .set(payload)
          .timeout(_thoiGianCho);

      // Lịch sử sao lưu (chỉ lưu tóm tắt, không nhân đôi dữ liệu)
      unawaited(_them('users/$userId/lich_su_sao_luu', {
        'thoi_gian': bayGio,
        'nen_tang': _nenTang,
        'thong_ke': thongKe,
      }));
      unawaited(_capNhat('users/$userId/profile', {'sao_luu_cuoi': bayGio}));

      return const KetQuaFirebase(
          true, 'Đã sao lưu toàn bộ dữ liệu lên Firebase!');
    } catch (e) {
      return KetQuaFirebase(false, _dichLoiDb(e));
    }
  }

  /// Tải bản sao lưu từ nhánh riêng của người dùng trên Firebase
  static Future<KetQuaFirebase> phucHoiToanBoDuLieu(String email) async {
    final userId = idTuEmail(email);
    if (userId == 'khach') {
      return const KetQuaFirebase(
          false, 'Vui lòng đăng nhập trước khi phục hồi.');
    }
    _nguoiDungHienTai = userId;

    try {
      final snap = await _dbRef
          .child('users/$userId/ban_sao_luu')
          .get()
          .timeout(_thoiGianCho);
      if (!snap.exists || snap.value == null) {
        return const KetQuaFirebase(
            false, 'Tài khoản này chưa có bản sao lưu trên Firebase.');
      }
      final duLieuChuan = jsonDecode(jsonEncode(snap.value));

      final bayGio = _bayGio();
      unawaited(_them('users/$userId/lich_su_phuc_hoi', {
        'thoi_gian': bayGio,
        'nen_tang': _nenTang,
      }));
      unawaited(_capNhat('users/$userId/profile', {'phuc_hoi_cuoi': bayGio}));

      return KetQuaFirebase(
        true,
        'Phục hồi dữ liệu thành công!',
        Map<String, dynamic>.from(duLieuChuan as Map),
      );
    } catch (e) {
      return KetQuaFirebase(false, _dichLoiDb(e));
    }
  }

  static Future<KetQuaFirebase> saoLuuDuLieu(
      String email, Map<String, dynamic> goi) async {
    return saoLuuToanBoDuLieu(email: email, goiDuLieu: goi);
  }

  static Future<KetQuaFirebase> layBanSaoLuu(String email) async {
    return phucHoiToanBoDuLieu(email);
  }

  // ===================== ĐỒNG BỘ THỜI GIAN THỰC =====================

  static Future<void> dongBoGiaoDich(MoHinhGiaoDich tx) async {
    final idx = _danhSachGiaoDichBoNho.indexWhere((x) => x.id == tx.id);
    if (idx != -1) {
      _danhSachGiaoDichBoNho[idx] = tx;
    } else {
      _danhSachGiaoDichBoNho.insert(0, tx);
    }
    _giaoDichStreamController.add(List.from(_danhSachGiaoDichBoNho));
    unawaited(_ghi('users/$_nguoiDungHienTai/giao_dich/${tx.id}', {
      ...tx.toMap(),
      'cap_nhat_luc': _bayGio(),
      'nen_tang': _nenTang,
    }));
  }

  static Future<void> xoaGiaoDich(String id) async {
    // Lưu bản sao vào "da_xoa" để có thể khôi phục sau này
    final idx = _danhSachGiaoDichBoNho.indexWhere((x) => x.id == id);
    if (idx != -1) {
      unawaited(_ghi('users/$_nguoiDungHienTai/da_xoa/giao_dich/$id', {
        ..._danhSachGiaoDichBoNho[idx].toMap(),
        'xoa_luc': _bayGio(),
        'nen_tang': _nenTang,
      }));
    }
    _danhSachGiaoDichBoNho.removeWhere((x) => x.id == id);
    _giaoDichStreamController.add(List.from(_danhSachGiaoDichBoNho));
    unawaited(_xoa('users/$_nguoiDungHienTai/giao_dich/$id'));
  }

  static Future<void> dongBoDanhMuc(MoHinhDanhMuc cat) async {
    unawaited(_ghi('users/$_nguoiDungHienTai/danh_muc/${cat.id}', {
      ...cat.toMap(),
      'cap_nhat_luc': _bayGio(),
    }));
  }

  static Future<void> dongBoNganSach(MoHinhNganSach ns) async {
    final idx = _danhSachNganSachBoNho
        .indexWhere((x) => x.id == ns.id || x.danhMuc == ns.danhMuc);
    if (idx != -1) {
      _danhSachNganSachBoNho[idx] = ns;
    } else {
      _danhSachNganSachBoNho.add(ns);
    }
    _nganSachStreamController.add(List.from(_danhSachNganSachBoNho));
    unawaited(_ghi('users/$_nguoiDungHienTai/ngan_sach/${ns.id}', {
      ...ns.toMap(),
      'cap_nhat_luc': _bayGio(),
    }));
  }

  static void phatCapNhatNganSach(List<MoHinhNganSach> list) {
    _danhSachNganSachBoNho.clear();
    _danhSachNganSachBoNho.addAll(list);
    _nganSachStreamController.add(List.from(_danhSachNganSachBoNho));

    final bayGio = _bayGio();
    final Map<String, dynamic> data = {};
    for (var item in list) {
      data[item.id] = {...item.toMap(), 'cap_nhat_luc': bayGio};
    }
    unawaited(_ghi('users/$_nguoiDungHienTai/ngan_sach', data));
  }

  static Future<void> xoaNganSach(String id) async {
    // Lưu bản sao vào "da_xoa" trước khi xóa
    final idx = _danhSachNganSachBoNho.indexWhere((x) => x.id == id);
    if (idx != -1) {
      unawaited(_ghi('users/$_nguoiDungHienTai/da_xoa/ngan_sach/$id', {
        ..._danhSachNganSachBoNho[idx].toMap(),
        'xoa_luc': _bayGio(),
      }));
    }
    _danhSachNganSachBoNho.removeWhere((x) => x.id == id);
    _nganSachStreamController.add(List.from(_danhSachNganSachBoNho));
    unawaited(_xoa('users/$_nguoiDungHienTai/ngan_sach/$id'));
  }

  static Future<void> dongBoTyLeHu(List<double> tyLe) async {
    unawaited(_ghi('users/$_nguoiDungHienTai/ty_le_hu', tyLe));
    unawaited(_capNhat('users/$_nguoiDungHienTai/profile', {
      'ty_le_hu_cap_nhat_luc': _bayGio(),
    }));
  }
}