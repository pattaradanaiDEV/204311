/*
 * File: create_job_screen.dart
 * Description: หน้าจอสำหรับสร้างและลงประกาศรับสมัครงานใหม่
 * Responsibilities:
 * - รับข้อมูลรายละเอียดงาน (ชื่อ, ตำแหน่ง, เงินเดือน, สถานที่, ความต้องการ)
 * - จัดการการเพิ่มและลบรายการความต้องการ (Requirements) แบบไดนามิก
 * - ดำเนินการอัปโหลดรูปภาพแบนเนอร์และบันทึกข้อมูลลงฐานข้อมูล [Firestore]
 * Author: Purich Senasang
 * Course: Mobile Application Development Framework
 */

import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; 
import '../../services/firestore_service.dart';
import '../../models/job.dart';

/// หน้าจอสำหรับสร้างประกาศรับสมัครงานในระบบ MannotRobot 
/// 
/// ทำหน้าที่รับข้อมูลจากผู้ใช้ ตรวจสอบความถูกต้องเบื้องต้น และบันทึกข้อมูลลงฐานข้อมูล
class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  // Services & Controllers
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _minSalaryController = TextEditingController();
  final TextEditingController _maxSalaryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  /// ลำดับของประเภทงานที่ถูกเลือกจาก [jobTypes] 
  int jobTypeIndex = 0;
  
  /// รายการตัวเลือกประเภทการจ้างงานที่มีให้เลือกในแอป
  final List<String> jobTypes = ['Full-time', 'Part-time', 'Contract', 'Internship'];
  
  /// รายการคุณสมบัติหรือความต้องการที่ผู้ใช้เพิ่มเข้ามา
  List<String> requirements = [];

  /// ไฟล์รูปภาพแบนเนอร์ที่ผู้ใช้เลือกจากคลังภาพ
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    /// คืนทรัพยากรให้กับระบบโดยการทำลาย [TextEditingController] เมื่อไม่ได้ใช้งาน
    _titleController.dispose();
    _companyController.dispose();
    _minSalaryController.dispose();
    _maxSalaryController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// เริ่มต้นกระบวนการเลือกรูปภาพจากคลังภาพในเครื่อง (Gallery) 
  /// 
  /// เมื่อเลือกรูปสำเร็จ จะทำการอัปเดตสถานะของ [_imageFile] เพื่อแสดงผลตัวอย่างบน UI 
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  /// ดำเนินการส่งข้อมูลประกาศงานขึ้นระบบ [Firebase] 
  /// 
  /// [Side effects]: 
  /// - อัปโหลดรูปภาพไปยัง Storage และบันทึกเอกสารงานใหม่ลงใน [Firestore] 
  /// - แสดง SnackBar แจ้งเตือนสถานะความสำเร็จและย้อนกลับไปยังหน้าก่อนหน้า 
  /// 
  /// [Failure mode]:
  /// - แสดงข้อความแจ้งเตือนหากผู้ใช้ยังไม่ได้เข้าสู่ระบบหรือกรอกข้อมูลสำคัญไม่ครบ 
  Future<void> _handlePostJob() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("กรุณาเข้าสู่ระบบก่อน")));
      return;
    }
    if (_titleController.text.isEmpty || _companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("กรุณากรอกข้อมูลสำคัญให้ครบ")));
      return;
    }

    // แสดงหน้าจอ Loading ขณะกำลังบันทึกข้อมูล
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    String finalImageUrl = "https://images.unsplash.com/photo-1556910103-1c02745aae4d"; 

    try {
      if (_imageFile != null) {
        // อัปโหลดรูปภาพผ่านบริการของ [_firestoreService]
        String? uploadedUrl = await _firestoreService.uploadImage(_imageFile!);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        }
      }

      Job newJob = Job(
        userId: user.uid,
        recruiterName: user.displayName ?? "Anonymous Recruiter",
        companyName: _companyController.text,
        title: _titleController.text,
        jobType: jobTypes[jobTypeIndex],
        salaryRange: "฿${_minSalaryController.text} - ฿${_maxSalaryController.text}",
        location: _locationController.text,
        description: _descriptionController.text,
        requirements: requirements,
        logoUrl: user.photoURL ?? "",
        imageUrl: finalImageUrl, 
        likes: [],
      );

      await _firestoreService.addJob(newJob);
      if (mounted) {
        Navigator.pop(context); // ปิดหน้าจอ Loading
        Navigator.pop(context); // ปิดหน้าจอสร้างโพสต์
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("โพสต์ประกาศสำเร็จ!")));
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI Layout Code
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "Anonymous";
    final String photoUrl = user?.photoURL ?? "";
    final String initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : "?";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Post a New Job', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty ? Text(initial, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade800)) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Posting publicly as Recruiter', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Job Title'),
            _buildTextField('e.g. Head Chef', controller: _titleController),
            const SizedBox(height: 20),

            _buildSectionTitle('Company Name'),
            _buildTextField('e.g. The Velvet Lounge', controller: _companyController),
            const SizedBox(height: 20),

            _buildSectionTitle('Job Type'),
            Wrap(
              spacing: 8,
              children: List.generate(jobTypes.length, (index) => _buildTypeChip(jobTypes[index], index)),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Salary Range'),
            Row(
              children: [
                Expanded(child: _buildTextField('Min', prefix: '฿ ', controller: _minSalaryController)),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('to')),
                Expanded(child: _buildTextField('Max', prefix: '฿ ', controller: _maxSalaryController)),
                const SizedBox(width: 8),
                Expanded(child: _buildDropdown('/ month')),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Location'),
            _buildTextField('Address or city', icon: Icons.location_on_outlined, controller: _locationController),
            const SizedBox(height: 20),

            _buildSectionTitle('Description'),
            Container(
              height: 120,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: _descriptionController,
                maxLines: null,
                decoration: const InputDecoration(hintText: 'Share details...', border: InputBorder.none),
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Qualifications & Requirements'),
            ...requirements.asMap().entries.map((entry) {
              int index = entry.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.blue, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => requirements[index] = v,
                          decoration: const InputDecoration(hintText: 'Requirement...', border: InputBorder.none),
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => setState(() => requirements.removeAt(index))),
                    ],
                  ),
                ),
              );
            }).toList(),

            TextButton.icon(
              onPressed: () => setState(() => requirements.add('')),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Requirement'),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle('Job Banner Photo'),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, color: Colors.grey.shade400, size: 40),
                    const SizedBox(height: 8),
                    const Text('Tap to upload job photo', style: TextStyle(color: Colors.grey)),
                  ],
                )
                    : Stack(
                  children: [
                    Positioned(
                      top: 8, right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54, radius: 18,
                        child: IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 18), onPressed: () => setState(() => _imageFile = null)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: _handlePostJob,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade500, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Post Job Listing', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A2B4C))));
  }

  Widget _buildTextField(String hint, {String? prefix, IconData? icon, TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, prefixText: prefix, prefixIcon: icon != null ? Icon(icon, size: 20) : null),
      ),
    );
  }

  Widget _buildTypeChip(String label, int index) {
    bool isSelected = jobTypeIndex == index;
    return ChoiceChip(
      label: Text(label), selected: isSelected,
      onSelected: (v) => setState(() => jobTypeIndex = index),
      selectedColor: Colors.blue.shade100,
    );
  }

  Widget _buildDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: value, items: [value].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (_) {})),
    );
  }
}