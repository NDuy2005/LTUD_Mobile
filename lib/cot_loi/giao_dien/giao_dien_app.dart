import 'package:flutter/material.dart';

class GiaoDienApp {
  static const Color mauChinh = Color(0xFFE07852);
  static const Color mauChiTieu = Color(0xFFE07852);
  static const Color mauNenSang = Color(0xFFF7F8F4);
  static const Color mauChuToiSang = Color(0xFF1E232A);

  // Tông màu Dark Mode Ngọc lục bảo sâu (Emerald/Teal) chuẩn theo ảnh
  static const Color mauChinhToi = Color(0xFF2DD4BF);
  static const Color mauNenToi = Color(0xFF041D1A);
  static const Color mauTheToi = Color(0xFF0A2925);
  static const Color mauVienToi = Color(0xFF134E48);
  static const Color mauChuGiaoDienToi = Color(0xFFF0FDFA);
  static const Color mauChuToiDark = mauChuGiaoDienToi;

  static ThemeData get giaoDienSang {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: mauChinh,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mauChinh,
        primary: mauChinh,
        surface: Colors.transparent,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: mauChuToiSang,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: mauChuToiSang),
      ),
    );
  }

  static ThemeData get themeSang => giaoDienSang;

  static ThemeData get giaoDienToi {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: mauChinhToi,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mauChinhToi,
        primary: mauChinhToi,
        surface: Colors.transparent,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: mauChuGiaoDienToi,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: mauChuGiaoDienToi),
      ),
    );
  }

  static ThemeData get themeToi => giaoDienToi;
}
