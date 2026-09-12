import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? firestoreDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

DateTime requireFirestoreDate(dynamic value, String field) {
  final date = firestoreDate(value);
  if (date == null) {
    throw FormatException('Missing or invalid timestamp for "$field"');
  }
  return date;
}