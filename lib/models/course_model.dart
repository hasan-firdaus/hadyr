class CourseModel {
  final String id;
  final String name;
  final String code;
  final String lecturerId;
  final String lecturerName;
  final String room;
  final String building;
  final String day;
  final String startTime;
  final String endTime;
  final int semester;
  final String prodi;
  final int totalMeetings;
  final int completedMeetings;

  const CourseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.lecturerId,
    required this.lecturerName,
    required this.room,
    required this.building,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.semester,
    required this.prodi,
    this.totalMeetings = 14,
    this.completedMeetings = 0,
  });

  String get timeRange => '$startTime - $endTime';
  String get roomFull => '$room, $building';

  factory CourseModel.fromMap(String id, Map<String, dynamic> map) {
    return CourseModel(
      id: id,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      lecturerId: map['lecturerId'] ?? '',
      lecturerName: map['lecturerName'] ?? '',
      room: map['room'] ?? '',
      building: map['building'] ?? '',
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      semester: map['semester'] ?? 1,
      prodi: map['prodi'] ?? '',
      totalMeetings: map['totalMeetings'] ?? 14,
      completedMeetings: map['completedMeetings'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'lecturerId': lecturerId,
      'lecturerName': lecturerName,
      'room': room,
      'building': building,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'semester': semester,
      'prodi': prodi,
      'totalMeetings': totalMeetings,
      'completedMeetings': completedMeetings,
    };
  }
}
