class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role; // 'lecturer' | 'student'
  final String? nidn; // for lecturer
  final String? nim; // for student
  final String? photoUrl;
  final String? prodi;
  final String? fakultas;
  final String? jabatan;
  final int? semester; // for student

  final bool notificationsEnabled;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.nidn,
    this.nim,
    this.photoUrl,
    this.prodi,
    this.fakultas,
    this.jabatan,
    this.semester,
    this.notificationsEnabled = true,
  });

  bool get isLecturer => role == 'lecturer';
  bool get isStudent => role == 'student';

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      nidn: map['nidn'] ?? map['nip'],
      nim: map['nim'],
      photoUrl: map['photoUrl'],
      prodi: map['prodi'],
      fakultas: map['fakultas'],
      jabatan: map['jabatan'],
      semester: map['semester'],
      notificationsEnabled: map['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'nidn': nidn,
      'nim': nim,
      'photoUrl': photoUrl,
      'prodi': prodi,
      'fakultas': fakultas,
      'jabatan': jabatan,
      'semester': semester,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? prodi,
    String? fakultas,
    String? jabatan,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      role: role,
      nidn: nidn,
      nim: nim,
      photoUrl: photoUrl ?? this.photoUrl,
      prodi: prodi ?? this.prodi,
      fakultas: fakultas ?? this.fakultas,
      jabatan: jabatan ?? this.jabatan,
      semester: semester ?? semester,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
