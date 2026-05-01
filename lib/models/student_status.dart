import 'package:flutter/material.dart';

enum StudentStatus {
  active,
  atRisk,
  financialHold,
  medicalPersonal, 
  unexplainedAbsence,
  other,
}

extension StudentStatusExtension on StudentStatus {
  String get label {
    switch (this) {
      case StudentStatus.active:
        return 'Active';
      case StudentStatus.atRisk:
        return 'At Risk';
      case StudentStatus.financialHold:
        return 'Financial Hold';
      case StudentStatus.medicalPersonal:
        return 'Medical/Personal';
      case StudentStatus.unexplainedAbsence:
        return 'Unexplained Absence';
      case StudentStatus.other:
        return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case StudentStatus.active:
        return Colors.green;
      case StudentStatus.atRisk:
        return Colors.orange;
      case StudentStatus.financialHold:
        return Colors.blue;
      case StudentStatus.medicalPersonal:
        return Colors.purple;
      case StudentStatus.unexplainedAbsence:
        return Colors.red;
      case StudentStatus.other:
        return Colors.blueGrey;
    }
  }

  // Helper to convert from String (Firestore) to Enum
  static StudentStatus fromString(String status) {
    switch (status) {
      case 'active': return StudentStatus.active;
      case 'atRisk': return StudentStatus.atRisk;
      case 'financialHold': return StudentStatus.financialHold;
      case 'medical/personal': return StudentStatus.medicalPersonal;
      case 'unexplainedAbsence': return StudentStatus.unexplainedAbsence;
      case 'other': return StudentStatus.other;
      default: return StudentStatus.active;
    }
  }
}
