/*
 * File: main.dart
 * Description: จุดเริ่มต้นการทำงาน (Entry Point) ของแอปพลิเคชัน MannotRobot
 * Responsibilities:
 * - เริ่มต้นการทำงานของ Flutter Framework, Firebase และการตั้งค่าสภาพแวดล้อมต่างๆ
 * - ตั้งค่าระบบจัดการสถานะส่วนกลาง (Global State) โดยใช้ Provider
 * - กำหนดเส้นทางการใช้งานแอปพลิเคชันและการเปลี่ยนเส้นทางอัตโนมัติด้วย GoRouter
 * Author: Pattaradanai Chaitan และ Purich Senasang
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'app_state.dart'; 
import 'screens/layout/main_layout.dart';
import 'login.dart';

/// จุดเริ่มต้นหลักของการทำงานในแอปพลิเคชัน
/// 
/// ทำหน้าที่เตรียมความพร้อมของ [Framework] และเริ่มต้นการทำงานของ Root Widget
void main() async {
  // มั่นใจว่า Flutter Framework พร้อมทำงานก่อนเรียกใช้ระบบภายนอก 
  WidgetsFlutterBinding.ensureInitialized();

  // โหลดค่ากำหนดสภาพแวดล้อม (API Keys) จากไฟล์ .env
  await dotenv.load(fileName: ".env");

  // เริ่มต้นการเชื่อมต่อกับระบบ [Firebase] 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ครอบแอปด้วย [Provider] เพื่อให้สามารถเข้าถึงสถานะการล็อกอินได้จากทุกส่วนของแอป 
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: ((context, child) => const MyApp()),
    ),
  );
}

/// การตั้งค่าเส้นทาง (Routing) และการตรวจสอบสิทธิ์การเข้าถึงหน้าจอ
/// 
/// Side effects:
/// - บังคับให้ผู้ใช้เปลี่ยนเส้นทางไปหน้า '/login' หากยังไม่ได้เข้าสู่ระบบ
/// - ป้องกันการเข้าหน้าล็อกอินซ้ำหากผู้ใช้ยืนยันตัวตนสำเร็จแล้วผ่าน [ApplicationState]
final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    final bool loggedIn = appState.loggedIn;
    final bool isLoggingIn = state.matchedLocation == '/login';

    // ตรวจสอบเงื่อนไขการบังคับล็อกอิน (Auth Guard)
    if (!loggedIn && !isLoggingIn) return '/login';
    if (loggedIn && isLoggingIn) return '/';

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainLayout()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
  ],
);

/// Root Widget ของแอปพลิเคชันที่ทำหน้าที่กำหนด Theme และ Router
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Culinary Connect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFF97316),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}