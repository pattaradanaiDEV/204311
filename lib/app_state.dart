/*
 * File: app_state.dart
 * Description: จัดการสถานะแอปพลิเคชันและการยืนยันตัวตน
 * Responsibilities:
 * - ตั้งค่าเริ่มต้นระบบ Firebase และบริการยืนยันตัวตน (Authentication)
 * - เฝ้าสังเกตและแจ้งเตือนเมื่อมีการเปลี่ยนแปลงสถานะการเข้าสู่ระบบของผู้ใช้
 * Author: Pattaradanai Chaitan และ Purich Senasang
 * Course: Mobile Application Development Framework
 */

import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

/// ตัวจัดการสถานะส่วนกลางของแอปพลิเคชัน MannotRobot
/// 
/// ทำหน้าที่ควบคุมสถานะการยืนยันตัวตนและตั้งค่าเริ่มต้นให้กับระบบ [Firebase]
class ApplicationState extends ChangeNotifier {
  /// สร้างอินสแตนซ์ของ [ApplicationState] และเริ่มต้นการตั้งค่าระบบ
  ApplicationState() {
    init();
  }

  bool _loggedIn = false;

  /// ว่าผู้ใช้ล็อกอินเข้าสู่ระบบแล้วหรือไม่
  bool get loggedIn => _loggedIn;

  /// ตั้งค่าคอนฟิกสำหรับ Firebase Auth และเฝ้าสังเกตการเปลี่ยนแปลงสถานะผู้ใช้
  /// 
  /// Side effects:
  /// - ลงทะเบียน [EmailAuthProvider] สำหรับการใช้งานร่วมกับ FirebaseUI
  /// - เรียกใช้ [notifyListeners] เพื่อแจ้งให้ UI อัปเดตเมื่อสถานะการล็อกอินเปลี่ยน
  Future<void> init() async {
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

    FirebaseAuth.instance.userChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}