import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/student_status.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // MARK ATTENDANCE (One-Click)
  Future<void> markAttendance(String studentId, bool isPresent) async {
    final docRef = _db.collection('students').doc(studentId);
    
    if (isPresent) {
      await docRef.update({
        'attendancePercentage': FieldValue.increment(0.5), 
        'status': 'active', // Being present keeps you active
        'consecutiveDaysAttended': FieldValue.increment(1), // INCREASE STREAK
      });
    } else {
      // Logic for Absence
      final studentDoc = await docRef.get();
      final currentAbsentDates = List<String>.from(studentDoc.data()?['absentDates'] ?? []);
      
      // Add new absence
      currentAbsentDates.add(DateTime.now().toIso8601String());

      // Check for consecutive absences (At Risk logic)
      // If they missed the last class too, they become 'atRisk'
      String nextStatus = 'unexplainedAbsence';
      if (currentAbsentDates.length >= 2) {
        nextStatus = 'atRisk';
        // Send a warning message
        await sendMessage(studentId, 'URGENT: At Risk Status', 'You have missed multiple classes without explanation. Your services are now LOCKED until you appeal.');
      }

      await docRef.update({
        'absentDates': currentAbsentDates,
        'attendancePercentage': FieldValue.increment(-1.0),
        'status': nextStatus,
        'consecutiveDaysAttended': 0, // RESET STREAK ON MISS
        'probationCleared': false,    // REVOKE PROBATION OVERRIDE
      });
      
      _checkPatterns(studentId);
    }
  }

  // CLEAR PROBATION MANUALLY
  Future<void> clearProbation(String studentId) async {
    await _db.collection('students').doc(studentId).update({
      'probationCleared': true,
      'status': 'active',
    });

    // AUTO-CLEAN: Delete messages once the issue is resolved
    final messages = await _db.collection('messages').where('studentId', isEqualTo: studentId).get();
    final batch = _db.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // PATTERN DETECTION (Solution 3)
  Future<void> _checkPatterns(String studentId) async {
    final doc = await _db.collection('students').doc(studentId).get();
    final student = Student.fromMap(doc.data()!, doc.id);
    
    // Logic: Flag if absent more than 2 Fridays
    int fridayAbsences = student.absentDates
        .where((date) => date.weekday == DateTime.friday)
        .length;

    if (fridayAbsences >= 2) {
      await _db.collection('flags').add({
        'studentId': studentId,
        'studentName': student.name,
        'reason': 'Pattern detected: Repeated Friday absences',
        'severity': 'High',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // SUBMIT APPEAL (Solution 2 & 3)
  Future<void> submitAppeal(String studentId, String category, String explanation, {String? attachmentName}) async {
    await _db.collection('appeals').add({
      'studentId': studentId,
      'category': category,
      'explanation': explanation,
      'attachmentName': attachmentName, // Store the name of the proof
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // Map Appeal Category to Student Status
    String newStatus;
    switch (category) {
      case 'medical':
      case 'familyEmergency':
        newStatus = 'medical/personal';
        break;
      case 'financial':
        newStatus = 'financialHold';
        break;
      case 'transportation':
      case 'other':
      default:
        newStatus = 'other';
        break;
    }

    // Update student with new appeal count AND the categorized status
    await _db.collection('students').doc(studentId).update({
      'appealCount': FieldValue.increment(1),
      'status': newStatus, // Categorize student immediately
    });
  }

  // SEND A MESSAGE TO STUDENT
  Future<void> sendMessage(String studentId, String title, String body) async {
    await _db.collection('messages').add({
      'studentId': studentId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // MARK ALL MESSAGES AS READ
  Future<void> markMessagesAsRead(String studentId) async {
    final batch = _db.batch();
    final unread = await _db.collection('messages')
        .where('studentId', isEqualTo: studentId)
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // GET STUDENTS (For Lecturer)
  Stream<List<Student>> getStudents() {
    return _db.collection('students').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Student.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // SEED DATA (One-time setup for development)
  Future<void> seedInitialData() async {
    final List<Student> initialStudents = [
      Student(id: '1', name: 'John Doe', email: 'john@school.edu', attendancePercentage: 95.0),
      Student(id: '2', name: 'Jane Smith', email: 'jane@school.edu', attendancePercentage: 75.0, status: StudentStatus.atRisk),
      Student(id: '3', name: 'Bob Wilson', email: 'bob@school.edu', status: StudentStatus.financialHold),
      Student(id: '4', name: 'Alice Brown', email: 'alice@school.edu', attendancePercentage: 55.0, status: StudentStatus.unexplainedAbsence),
    ];

    for (var student in initialStudents) {
      await _db.collection('students').doc(student.id).set(student.toMap());
    }
  }
}
