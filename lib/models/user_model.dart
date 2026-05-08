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
    };
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? prodi,
    String? fakultas,
    String? jabatan,
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
    );
  }
}
