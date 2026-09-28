class CatatanModel {
  final int? id;
  final String judul;
  final String isi;
  final String tanggal;

  CatatanModel({
    this.id,
    required this.judul,
    required this.isi,
    required this.tanggal,
  });

  // Mengubah data model menjadi Map
  // agar dapat disimpan ke SQLite.
  Map<String, dynamic> toMap() {
    return {'id': id, 'judul': judul, 'isi': isi, 'tanggal': tanggal};
  }

  // Mengubah data dari SQLite menjadi object CatatanModel.
  factory CatatanModel.fromMap(Map<String, dynamic> map) {
    return CatatanModel(
      id: map['id'] as int?,
      judul: map['judul'] as String,
      isi: map['isi'] as String,
      tanggal: map['tanggal'] as String,
    );
  }
}
// class CatatanModel {
//   final int? id;
//   final String judul;
//   final String isi;
//   final String tanggal;

//   CatatanModel({
//     this.id,
//     required this.judul,
//     required this.isi,
//     required this.tanggal,
//   });

//   Map<String, dynamic> toMap() {
//     return {'id': id, 'judul': judul, 'isi': isi, 'tanggal': tanggal};
//   }

//   factory CatatanModel.fromMap(Map<String, dynamic> map) {
//     return CatatanModel(
//       id: map['id'] as int?,
//       judul: map['judul'] as String,
//       isi: map['isi'] as String,
//       tanggal: map['tanggal'] as String,
//     );
//   }
// }
// // // ignore_for_file: public_member_api_docs, sort_constructors_first
// // import 'dart:convert';

// // class CatatanModel {
// //   final int? id;
// //   final String judul;
// //   final String isi;
// //   final String tanggal;

// //   CatatanModel({
// //     this.id,
// //     required this.judul,
// //     required this.isi,
// //     required this.tanggal,
// //   });

// //   // Mengubah object menjadi Map
// //   Map<String, dynamic> toMap() {
// //     return {'id': id, 'judul': judul, 'isi': isi, 'tanggal': tanggal};
// //   }

// //   // Mengubah Map dari database menjadi object
// //   factory CatatanModel.fromMap(Map<String, dynamic> map) {
// //     return CatatanModel(
// //       id: map['id'] as int?,
// //       judul: map['judul'] as String,
// //       isi: map['isi'] as String,
// //       tanggal: map['tanggal'] as String,
// //     );
// //   }
// // }

// // // class CatatanModel {
// // //   final int? id;
// // //   final String email;
// // //   final String password;

// // //   CatatanModel({
// // //     this.id,
// // //     required this.email,
// // //     required this.password,
// // //   });

// // //   // CatatanModel({
// // //   //   this.id,
// // //   //   required this.judul,
// // //   //   required this.isi,
// // //   //   required this.tanggal,
// // //   // });

// // //   // Map<String, dynamic> toMap() {
// // //   //   return {'id': id, 'judul': judul, 'isi': isi, 'tanggal': tanggal};
// // //   // }

// // //   // factory CatatanModel.fromMap(Map<String, dynamic> map) {
// // //   //   return CatatanModel(
// // //   //     id: map['id'] as int?,
// // //   //     judul: map['judul'] as String,
// // //   //     isi: map['isi'] as String,
// // //   //     tanggal: map['tanggal'] as String,
// // //   //   );
// // //   // }

// // //   Map<String, dynamic> toMap() {
// // //     return <String, dynamic>{
// // //       'id': id,
// // //       'email': email,
// // //       'password': password,
// // //     };
// // //   }

// // //   factory CatatanModel.fromMap(Map<String, dynamic> map) {
// // //     return CatatanModel(
// // //       id: map['id'] != null ? map['id'] as int : null,
// // //       email: map['email'] as String,
// // //       password: map['password'] as String,
// // //     );
// // //   }

// // //   String toJson() => json.encode(toMap());

// // //   factory CatatanModel.fromJson(String source) => CatatanModel.fromMap(json.decode(source) as Map<String, dynamic>);
// // // }
