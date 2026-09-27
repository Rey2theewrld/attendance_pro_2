# Attendance Pro — Project Documentation

**Project Name:** Attendance Pro (Student Accountability & Attendance System)  
**Repository:** [https://github.com/Rey2theewrld/attendance_pro_2](https://github.com/Rey2theewrld/attendance_pro_2)  
**Framework:** Flutter (Dart)  
**Backend:** Google Cloud Firebase (Firestore, Firebase Core)  

---

## Executive Summary

**Attendance Pro** is a modern Flutter application designed to shift academic attendance from passive tracking to an active **Student Accountability System**. Unlike traditional attendance logs that simply count missed classes, Attendance Pro enforces a progressive penalty system with automated probation monitoring, categorized appeals, and pattern detection (e.g., recurring Friday absences).

---

## Key Features & Architecture

### 1. Phased Penalty Framework
The system categorizes academic consequences into escalating phases based on permanent attendance records:
- **Phase 1 (Warning):** Learning materials are locked, warning notification issued.
- **Phase 2 (Soft Lockdown):** Timetable, messages, and learning materials locked.
- **Phase 3 / At Risk (Full Restriction):** Total restriction including exams; student must meet in person with the Lead Lecturer.

### 2. Smart Appeals System
- Students can submit structured appeals under specific categories (*Medical*, *Financial*, *Family Emergency*, *Transportation*, *Other*).
- System limits students to **a maximum of 3 appeals per semester**.
- Final appeals (Appeal #3) mandate evidence/attachment upload (PDF, medical docs, image proof).

### 3. Automated Pattern Detection Engine
- Monitors Firestore records for suspicious behavior (e.g., 2+ Friday absences).
- Automatically generates high-severity alert flags visible on the Admin Console.

### 4. Delayed Forgiveness & Probation Watch
- When an appeal is approved, the student enters probation rather than receiving immediate full forgiveness.
- Students must maintain a **5-day consecutive attendance streak** to clear probation and unlock restricted services.

### 5. Multi-Role User Portals
- **Lecturer Dashboard:** One-click live attendance marking (Present/Absent), status filtering (Hide Financial Hold, Unexplained Only).
- **Student Dashboard:** Real-time attendance stats, status badge, locked/unlocked service cards, notification center.
- **Admin Console:** High-risk flags review, pending appeals management (Approve & Pardon vs. Reject), Probation Watch streak tracker, dev data cloud resetting.

---

## Data Models & Database Architecture

### Data Models (`lib/models/`)
1. **`Student` (`student.dart`)**:
   - `id`, `name`, `email`, `status`, `attendancePercentage`, `appealCount`
   - `absentDates` (List of DateTime timestamps)
   - `consecutiveDaysAttended` (Streak counter for probation)
   - `probationCleared` (Admin manual override flag)
   - `penaltyPhase` & `isLocked(phaseThreshold)` calculations

2. **`StudentStatus` (`student_status.dart`)**:
   - Enums: `active`, `atRisk`, `financialHold`, `medicalPersonal`, `unexplainedAbsence`, `other`
   - Extension getters for labels, color coding, and string parsing.

3. **`Appeal` (`appeal.dart`)**:
   - `id`, `studentId`, `category`, `explanation`, `status`, `timestamp`
   - Enum `AppealCategory` for structured reason categorization.

### Database Service (`lib/services/database_service.dart`)
- **`markAttendance(studentId, isPresent)`**: Updates attendance percentage, status, and streak.
- **`submitAppeal(...)`**: Submits appeal to Firestore, updates student appeal count and categorizes status.
- **`clearProbation(studentId)`**: Marks probation as cleared and auto-cleans resolved notification messages.
- **`seedInitialData()`**: Initializes sample development data in Firebase Firestore.

---

## Getting Started & Running the Project

### Prerequisites
- Flutter SDK (v3.27+)
- Firebase Account & Configured Firebase CLI (`firebase_options.dart`)

### Commands
```bash
# Get dependencies
flutter pub get

# Run static code analysis
flutter analyze

# Run unit and widget tests
flutter test

# Launch the app
flutter run
```

---

## Repository & Source Control Information

- **GitHub Repository:** `https://github.com/Rey2theewrld/attendance_pro_2.git`
- **Main Branch:** `master`
- **Code Quality:** 0 Analysis Issues (`flutter analyze`), 100% Passing Tests (`flutter test`).
