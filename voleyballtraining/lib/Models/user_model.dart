import 'package:cloud_firestore/cloud_firestore.dart'; // Necesario para Timestamp

class UserModel {
  final String userId; // Este será el UID de Firebase Authentication
  final String email;
  final String fullName;
  final String? idNumber; // Cédula - Opcional, por eso el '?'
  final Timestamp? dateOfBirth; // Fecha de Nacimiento - Opcional
  final String? phoneNumber; // Teléfono - Opcional
  final String role; // 'Entrenador' o 'Jugador'
  final Timestamp createdAt; // Cuándo se creó el registro en Firestore

  // Constructor
  UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    this.idNumber, // Campos opcionales no necesitan 'required'
    this.dateOfBirth,
    this.phoneNumber,
    required this.role,
    required this.createdAt,
  });

  // Método para convertir nuestro objeto UserModel a un Mapa
  // que Firestore pueda entender para guardarlo.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'idNumber': idNumber, // Firestore manejará bien los valores null
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'role': role,
      'createdAt': createdAt,
      // OJO: No guardamos el userId DENTRO del documento,
      // porque el userId ES el ID del documento en Firestore.
    };
  }

  // Método 'Factory' para crear un objeto UserModel a partir
  // de un DocumentSnapshot que leemos de Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic>? data = doc.data(); // El data() puede ser null

    // Validación básica para evitar errores si el documento está vacío o incompleto
    // (En una app real podrías querer un manejo de errores más robusto)
    if (data == null) {
      // Lanza un error o devuelve un objeto por defecto si prefieres
       throw StateError('¡Datos no encontrados para el usuario con ID: ${doc.id}!');
    }

    return UserModel(
      userId: doc.id, // ¡Importante! El ID del documento es nuestro userId
      email: data['email'] ?? 'sin_email@error.com', // Valor por defecto si falta
      fullName: data['fullName'] ?? 'Sin Nombre', // Valor por defecto si falta
      idNumber: data['idNumber'] as String?, // El 'as String?' permite que sea null
      dateOfBirth: data['dateOfBirth'] as Timestamp?, // El 'as Timestamp?' permite que sea null
      phoneNumber: data['phoneNumber'] as String?, // El 'as String?' permite que sea null
      role: data['role'] ?? 'Jugador', // Valor por defecto si falta
      createdAt: data['createdAt'] ?? Timestamp.now(), // Valor por defecto si falta
    );
  }

  // Método útil para imprimir el objeto y depurar (opcional)
  @override
  String toString() {
    return 'UserModel(userId: $userId, email: $email, fullName: $fullName, role: $role)';
  }
}