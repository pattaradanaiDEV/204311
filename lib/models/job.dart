/*
 * File: job.dart
 * Description: โมเดลข้อมูลสำหรับงาน
 * Responsibilities:
 * - กำหนดโครงสร้าง Attribute ของงาน
 * - จัดการการแปลงข้อมูลกับ Firestore
 * Author: Purich Senasang
 * Course: Mobile Application Development Framework
 */
import 'package:cloud_firestore/cloud_firestore.dart';

/// ข้อมูลประกาศรับสมัครงานในระบบ MannotRobot
///
/// คลาสนี้ใช้สำหรับกำหนดโครงสร้างข้อมูลของงาน รวมถึงการแปลงข้อมูล
/// ระหว่างรูปแบบ [Map] ของ Firestore และอินสแตนซ์ของ [Job]
class Job {
  /// ไอดีอ้างอิงเอกสารในฐานข้อมูล Firestore
  final String? id;
  
  final String userId;
  final String recruiterName;
  final String companyName;
  final String title;
  final String jobType;
  final String salaryRange;
  final String location;
  final String description;
  final List<String> requirements;
  final String logoUrl;
  final String imageUrl;
  
  /// รายชื่อไอดีผู้ใช้งานที่กดบันทึกงานนี้ไว้
  final List<String> likes;
  
  final DateTime? createdAt;

  Job({
    this.id,
    required this.userId,
    required this.recruiterName,
    required this.companyName,
    required this.title,
    required this.jobType,
    required this.salaryRange,
    required this.location,
    required this.description,
    required this.requirements,
    required this.logoUrl,
    required this.imageUrl,
    required this.likes,
    this.createdAt,
  });

  /// สร้างอินสแตนซ์ [Job] จากข้อมูล [map] ที่ดึงมาจาก Firestore
  ///
  /// รับข้อมูล [id] ซึ่งเป็น Document ID และ [map] ที่มีข้อมูลของงาน
  /// หากฟิลด์ใดไม่มีข้อมูล ระบบจะกำหนดค่าเริ่มต้นที่เหมาะสมให้
  factory Job.fromMap(String id, Map<String, dynamic> map) {
    return Job(
      id: id,
      userId: map['userId'] ?? '',
      recruiterName: map['recruiterName'] ?? 'Unknown Recruiter',
      companyName: map['companyName'] ?? 'Unknown Company',
      title: map['title'] ?? '',
      jobType: map['jobType'] ?? 'Full-time',
      salaryRange: map['salaryRange'] ?? 'N/A',
      location: map['location'] ?? 'Remote',
      description: map['description'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      logoUrl: map['logoUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      likes: List<String>.from(map['likes'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// ส่งคืนข้อมูลของ [Job] ในรูปแบบ [Map] เพื่อจัดเก็บลงใน Firestore
  ///
  /// ฟังก์ชันนี้จะรวมค่า [FieldValue.serverTimestamp] เพื่อระบุเวลาที่บันทึกข้อมูล
  Map<String, dynamic> toMap() {
      return {
        'userId': userId,
        'recruiterName': recruiterName,
        'companyName': companyName,
        'title': title,
        'jobType': jobType,
        'salaryRange': salaryRange,
        'location': location,
        'description': description,
        'requirements': requirements,
        'logoUrl': logoUrl,
        'imageUrl': imageUrl,
        'likes': likes,
        'createdAt': FieldValue.serverTimestamp(),
      };
  }
}
