import 'student_status.dart';

class Student {
  final String id;
  final String name;
  final String email;
  final StudentStatus status;
  final double attendancePercentage;
  final int appealCount;
  final List<DateTime> absentDates;
  final int consecutiveDaysAttended; // TRACK STREAK FOR SOLUTION 4
  final bool probationCleared;       // MANUAL OVERRIDE BY ADMIN

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.status = StudentStatus.active,
    this.attendancePercentage = 100.0,
    this.appealCount = 0,
    this.absentDates = const [],
    this.consecutiveDaysAttended = 0,
    this.probationCleared = false,
  });

  // ALWAYS returns the actual phase based on history (Permanent Record)
  int get penaltyPhase {
    if (status == StudentStatus.financialHold) return 3;
    return absentDates.length;
  }

  // Check if services should be locked for a certain phase
  bool isLocked(int phaseThreshold, {bool isCritical = false}) {
    if (status == StudentStatus.financialHold) return true;
    if (status == StudentStatus.atRisk) return true; // AT RISK = FULL LOCKOUT
    if (probationCleared) return false; // ADMIN OVERRIDE

    // 1. If not approved, lock if we hit the threshold
    if (status != StudentStatus.active) {
      return penaltyPhase >= phaseThreshold;
    }

    // 2. DELAYED FORGIVENESS (Solution 4)
    if (penaltyPhase == 1) return false;

    if (penaltyPhase == 2) {
      // Even if pardoned, keep Learning Materials and Exams locked
      return phaseThreshold == 1 || isCritical;
    }

    if (penaltyPhase >= 3) return true; 

    return false;
  }

  // Should we show the Appeal button?
  bool get needsToAppeal {
    // Only show if they are currently restricted and haven't hit the max limit
    return (status == StudentStatus.unexplainedAbsence || status == StudentStatus.atRisk) && 
           appealCount < 3 && 
           penaltyPhase > 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'status': status.name,
      'attendancePercentage': attendancePercentage,
      'appealCount': appealCount,
      'absentDates': absentDates.map((d) => d.toIso8601String()).toList(),
      'consecutiveDaysAttended': consecutiveDaysAttended,
      'probationCleared': probationCleared,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      status: StudentStatusExtension.fromString(map['status'] ?? 'active'),
      attendancePercentage: (map['attendancePercentage'] ?? 100.0).toDouble(),
      appealCount: map['appealCount'] ?? 0,
      absentDates: (map['absentDates'] as List? ?? [])
          .map((d) => DateTime.parse(d as String))
          .toList(),
      consecutiveDaysAttended: map['consecutiveDaysAttended'] ?? 0,
      probationCleared: map['probationCleared'] ?? false,
    );
  }
}
