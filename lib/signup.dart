/*
 * File: signup.dart
 * Description: หน้าจอสำหรับลงทะเบียนผู้ใช้ใหม่ (Sign-up)
 * Responsibilities:
 * - รวบรวมข้อมูลชื่อ อีเมล และรหัสผ่านเพื่อสร้างบัญชีใหม่ในระบบ
 * - ดำเนินการลงทะเบียนและอัปเดตข้อมูลผู้ใช้ผ่าน Firebase Authentication
 * - จัดการสถานะการรอโหลด (Loading state) และการตอบสนองต่อข้อมูลที่ไม่ถูกต้อง
 * Author: Pattaradanai Chaitan และ Purich Senasang
 * Course: Mobile Application Development Framework
 */

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

/// หน้าจอสำหรับลงทะเบียนผู้ใช้ใหม่ในระบบ MannotRobot
/// 
/// ทำหน้าที่รับข้อมูลพื้นฐาน ตรวจสอบความถูกต้อง และสร้างบัญชีผู้ใช้ใน [Firebase]
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  /// ว่าระบบกำลังอยู่ในระหว่างการประมวลผลการสมัครสมาชิกหรือไม่
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    /// คืนทรัพยากรให้กับระบบโดยการทำลาย [TextEditingController] เมื่อ Widget ถูกทำลาย
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  /// ดำเนินการสร้างบัญชีผู้ใช้ใหม่ผ่าน [FirebaseAuth]
  /// 
  /// Side effects:
  /// - สร้างข้อมูลผู้ใช้ใหม่ (User Credential) ในระบบ [Firebase Auth]
  /// - อัปเดตชื่อที่ใช้แสดง (Display Name) ของผู้ใช้ตามข้อมูลใน [_nameController]
  /// - นำทางผู้ใช้ไปยังหน้าหลัก '/' ผ่าน [GoRouter] เมื่อการสมัครเสร็จสิ้น
  /// 
  /// [Failure mode]:
  /// - แสดง SnackBar แจ้งเตือนหากรหัสผ่านไม่ตรงกันหรือเกิดข้อผิดพลาดจากระบบ [Firebase]
  Future<void> _signUp() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // สร้างบัญชีผู้ใช้ใหม่ด้วยอีเมลและรหัสผ่าน
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // ตั้งค่าชื่อที่แสดงบนโปรไฟล์ผู้ใช้
      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Sign up failed")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.orange,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Join the culinary community to share recipes and find your next role.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),

            _buildField(
              "Full Name",
              "Chef Ramsay",
              Icons.person_outline,
              _nameController,
            ),
            _buildField(
              "Email Address",
              "you@example.com",
              Icons.email_outlined,
              _emailController,
            ),
            _buildField(
              "Password",
              "",
              Icons.lock_outline,
              _passwordController,
              isPass: true,
            ),
            _buildField(
              "Confirm Password",
              "",
              Icons.history_outlined,
              _confirmController,
              isPass: true,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[800],
                  disabledBackgroundColor: Colors.orange[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Create Account',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller, {
    bool isPass = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPass,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}