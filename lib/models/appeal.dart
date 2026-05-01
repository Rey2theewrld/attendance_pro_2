enum AppealCategory {
  medical,
  financial,
  familyEmergency,
  transportation,
  other
}

class Appeal {
  final String id;
  final String studentId;
  final String category;
  final String explanation;
  final String status; // pending, approved, rejected
  final DateTime timestamp;

  Appeal({
    required this.id,
    required this.studentId,
    required this.category,
    required this.explanation,
    this.status = 'pending',
    required this.timestamp,
  });

  factory Appeal.fromMap(Map<String, dynamic> map, String id) {
    return Appeal(
      id: id,
      studentId: map['studentId'] ?? '',
      category: map['category'] ?? 'other',
      explanation: map['explanation'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: (map['timestamp'] != null) 
          ? (map['timestamp'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
}
