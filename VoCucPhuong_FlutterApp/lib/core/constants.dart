import 'package:flutter/material.dart';

class ApiUrls {
  // PublicWeb hosts NhapHang + TongHop APIs
  static const String publicBase = 'https://vocucphuongmanage.vercel.app';
  // DatVe app (booking online)
  static const String datVeBase = 'https://vocucphuong.vercel.app';

  static const String nhapHangApi = '$publicBase/api/nhap-hang';
  static const String tongHopApi = '$publicBase/api/tong-hop';
  static const String datVeApi = '$datVeBase/api';
}

class AppColors {
  static const Color primary = Color(0xFF0EA5E9);
  static const Color primaryDark = Color(0xFF0284C7);
  static const Color secondary = Color(0xFFE11D48);
  static const Color accent = Color(0xFF22C55E);
  static const Color orange = Color(0xFFF59E0B);
  static const Color dark = Color(0xFF1E293B);
  static const Color light = Color(0xFFF8FAFC);
  static const Color cancelled = Color(0xFF94A3B8);
}

class AppSizes {
  static const double pagePadding = 16;
  static const double cardRadius = 12;
  static const double inputRadius = 10;
}
