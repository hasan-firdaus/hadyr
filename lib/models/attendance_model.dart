import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

enum AttendanceStatus { hadir, izin, sakit, alfa, terlambat }

extension AttendanceStatusExt on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'Hadir';
      case AttendanceStatus.izin:
        return 'Izin';
      case AttendanceStatus.sakit:
        return 'Sakit';
      case AttendanceStatus.alfa:
        return 'Alfa';
      case AttendanceStatus.terlambat:
        return 'Terlambat';
    }
  }

  String get code {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'H';
      case AttendanceStatus.izin:
        return 'I';
      case AttendanceStatus.sakit:
        return 'S';
      case AttendanceStatus.alfa:
        return 'A';
      case AttendanceStatus.terlambat:
        return 'T';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.hadir:
        return AppColors.statusHadir;
      case AttendanceStatus.izin:
        return AppColors.statusIzin;
      case AttendanceStatus.sakit:
        return AppColors.statusSakit;
      case AttendanceStatus.alfa:
        return AppColors.statusAlfa;
      case AttendanceStatus.terlambat:
        return AppColors.statusTerlambat;
    }
  }

  Color get bgColor {
    switch (this) {
      case AttendanceStatus.hadir:
        return AppColors.statusHadirBg;
      case AttendanceStatus.izin:
        return AppColors.statusIzinBg;
      case AttendanceStatus.sakit:
        return AppColors.statusSakitBg;
      case AttendanceStatus.alfa:
        return AppColors.statusAlfaBg;
      case AttendanceStatus.terlambat:
        return AppColors.statusTerlambatBg;
    }
  }
}

AttendanceStatus attendanceStatusFromString(String s) {
  switch (s.toLowerCase()) {
    case 'hadir':
    case 'h':
      return AttendanceStatus.hadir;
    case 'izin':
    case 'i':
      return AttendanceStatus.izin;
    case 'sakit':
    case 's':
      return AttendanceStatus.sakit;
    case 'terlambat':
    case 't':
      return AttendanceStatus.terlambat;
    default:
      return AttendanceStatus.alfa;
  }
}

class AttendanceModel {
  final String id;
  final String courseId;
  final String courseName;
  final String studentId;
  final String studentName;
  final String studentNim;
  final AttendanceStatus status;
  final DateTime date;
  final int meetingNumber;
  final String? note;
  final String room;
  final String building;

  const AttendanceModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.studentId,
    required this.studentName,
    required this.studentNim,
    required this.status,
    required this.date,
    required this.meetingNumber,
    this.note,
    this.room = '',
    this.building = '',
  });

  factory AttendanceModel.fromMap(String id, Map<String, dynamic> map) {
    return AttendanceModel(
      id: id,
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentNim: map['studentNim'] ?? '',
      status: attendanceStatusFromString(map['status'] ?? 'alfa'),
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),
      meetingNumber: map['meetingNumber'] ?? 1,
      note: map['note'],
      room: map['room'] ?? '',
      building: map['building'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'studentId': studentId,
      'studentName': studentName,
      'studentNim': studentNim,
      'status': status.label,
      'date': date.toIso8601String(),
      'meetingNumber': meetingNumber,
      'note': note,
      'room': room,
      'building': building,
    };
  }

  AttendanceModel copyWith({AttendanceStatus? status, String? note}) {
    return AttendanceModel(
      id: id,
      courseId: courseId,
      courseName: courseName,
      studentId: studentId,
      studentName: studentName,
      studentNim: studentNim,
      status: status ?? this.status,
      date: date,
      meetingNumber: meetingNumber,
      note: note ?? this.note,
      room: room,
      building: building,
    );
  }
}
