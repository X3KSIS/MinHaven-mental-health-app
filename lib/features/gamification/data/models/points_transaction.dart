import 'package:cloud_firestore/cloud_firestore.dart';

class PointsTransaction {
  final String id;
  final String userId;
  final int points;
  final String action;
  final String category;
  final DateTime timestamp;
  final String description;
  final String? relatedId;

  PointsTransaction({
    required this.id,
    required this.userId,
    required this.points,
    required this.action,
    required this.category,
    required this.timestamp,
    required this.description,
    this.relatedId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'action': action,
      'category': category,
      'timestamp': timestamp,
      'description': description,
      'relatedId': relatedId,
    };
  }

  factory PointsTransaction.fromMap(Map<String, dynamic> map) {
    return PointsTransaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      points: map['points'] ?? 0,
      action: map['action'] ?? '',
      category: map['category'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      description: map['description'] ?? '',
      relatedId: map['relatedId'],
    );
  }
}
