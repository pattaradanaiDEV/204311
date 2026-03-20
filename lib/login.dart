/*
 * File: login_page.dart
 * Description: ผู้ใช้งาน login ผ่านหน้านี้
 * Responsibilities:
 * - สามารถใช้อีเมลที่สมัคร และรหัสผ่าน login เข้ามาได้
 * - สามารถกดไปหน้า sign-up ได้จากหน้า login
 * - ทำให้เปิด/ปิด การมองเห็นรหัสผ่านได้
 * - นำไปสู่หน้า home ได้เมื่อ login สำเร็จ
 * Author: Pattaradanai Chaitan และ Purich Senasang(จัดการปุ่มมองเห็นรหัสผ่าน)
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/layout/main_layout.dart';

/// หน้าจอเข้าสู่ระบบสำหรับผู้ใช้งานแอปพลิเคชัน MannotRobot
/// 
/// รองรับการตรวจสอบสิทธิ์ผ่านอีเมลและรหัสผ่าน พร้อมการจัดการสถานะ UI เบื้องต้น
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  /// ว่ากำลังซ่อนรหัสผ่านอยู่หรือไม่
  bool _isObscure = true;

  @override
  void dispose() {
    /// คืนทรัพยากรให้กับระบบเมื่อไม่มีการใช้งาน Controller แล้ว
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// ดำเนินการเข้าสู่ระบบด้วยอีเมลและรหัสผ่านผ่าน [FirebaseAuth]
  /// 
  /// Side effects:
  /// - หากสำเร็จ จะทำการล้างหน้าจอเดิมและนำผู้ใช้ไปยัง [MainLayout]
  /// - แจ้งเตือนสถานะความผิดพลาดผ่านบล็อก catch (ถ้ามี)
  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // ใช้ pushAndRemoveUntil เพื่อป้องกันการกด Back กลับมาหน้า Login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      // สามารถเพิ่ม SnackBar แจ้งเตือน Error ตรงนี้ได้ในอนาคต
    }
  }

  @override
  Widget build(BuildContext context) {
    // Overridden methods ไม่ต้องใส่ Doc Comment ตามเกณฑ์หน้า 21
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 80),
              // ส่วนแสดงโลโก้แอป
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD35400),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'MannotRobot',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const Text(
                'Welcome back to your culinary community',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              _buildTextField(
                label: 'Email or Username',
                hint: '',
                icon: Icons.person_outline,
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Password',
                hint: '',
                icon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _login,
                  child: const Text('Log In'),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignUpPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color(0xFFD35400),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget สำหรับสร้างช่องกรอกข้อมูล (Private method)
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword ? _isObscure : false,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isObscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}