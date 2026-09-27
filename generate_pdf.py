import sys

def create_pdf(filename):
    pages_content = []

    # Page 1: Title, Executive Summary, Key Features
    p1 = []
    # Header bar
    p1.append("0.10 0.14 0.49 rg") # Deep Indigo (#1A237E)
    p1.append("0 740 612 52 re f")
    p1.append("1 1 1 rg")
    p1.append("BT /F2 20 Tf 36 758 Td (ATTENDANCE PRO - PROJECT DOCUMENTATION) Tj ET")

    # Meta box
    p1.append("0.95 0.95 0.98 rg")
    p1.append("36 650 540 70 re f")
    p1.append("0.8 0.8 0.9 rg")
    p1.append("36 650 540 70 re S")

    p1.append("0.1 0.1 0.3 rg")
    p1.append("BT /F2 10 Tf 46 700 Td (Project Name:) Tj /F1 10 Tf 120 700 Td (Attendance Pro (Student Accountability System)) Tj ET")
    p1.append("BT /F2 10 Tf 46 685 Td (Repository:) Tj /F1 10 Tf 120 685 Td (https://github.com/Rey2theewrld/attendance_pro_2) Tj ET")
    p1.append("BT /F2 10 Tf 46 670 Td (Framework:) Tj /F1 10 Tf 120 670 Td (Flutter (Dart v3.27+)  |  Backend: Firebase Firestore) Tj ET")
    p1.append("BT /F2 10 Tf 46 655 Td (Status:) Tj /F1 10 Tf 120 655 Td (0 Analysis Errors, 100% Tests Passing) Tj ET")

    # Section 1: Executive Summary
    p1.append("0.10 0.14 0.49 rg")
    p1.append("BT /F2 14 Tf 36 620 Td (1. Executive Summary) Tj ET")
    p1.append("0.2 0.2 0.2 rg")
    p1.append("BT /F1 10 Tf 36 600 Td (Attendance Pro is a modern Flutter application designed to shift academic attendance) Tj ET")
    p1.append("BT /F1 10 Tf 36 586 Td (from passive tracking to an active Student Accountability System. Unlike simple attendance) Tj ET")
    p1.append("BT /F1 10 Tf 36 572 Td (logs, Attendance Pro enforces a phased penalty framework, probation monitoring, categorized) Tj ET")
    p1.append("BT /F1 10 Tf 36 558 Td (appeals, and automated pattern detection for recurring unexplained absences.) Tj ET")

    # Section 2: Key Features & Architecture
    p1.append("0.10 0.14 0.49 rg")
    p1.append("BT /F2 14 Tf 36 525 Td (2. Key Features & System Architecture) Tj ET")

    features = [
        ("Phased Penalty Framework:", "Escalating consequences based on skip records."),
        (" - Phase 1 (Warning):", "Warning notification issued; Learning Materials locked."),
        (" - Phase 2 (Soft Lockdown):", "Timetable, Messages, and Learning Materials locked."),
        (" - Phase 3 (Full Lockdown):", "Exams and all services locked; requires in-person admin review."),
        ("Smart Appeals System:", "Structured reasons (Medical, Financial, Emergency, etc.). Max 3 per semester."),
        (" - Evidence Requirement:", "Appeal #3 mandates PDF / documentation upload."),
        ("Pattern Detection Engine:", "Automatically flags suspicious trends (e.g. 2+ Friday absences)."),
        ("Probation Watch & Streak:", "Approved appeals require a 5-day streak to clear probation."),
        ("Multi-Role User Portals:", "Lecturer Dashboard, Student Dashboard, and Admin Console.")
    ]

    y = 495
    for title, desc in features:
        p1.append("0.1 0.1 0.3 rg")
        p1.append(f"BT /F2 10 Tf 44 {y} Td ({title}) Tj ET")
        p1.append("0.3 0.3 0.3 rg")
        p1.append(f"BT /F1 10 Tf 210 {y} Td ({desc}) Tj ET")
        y -= 18

    # Page footer
    p1.append("0.5 0.5 0.5 rg")
    p1.append("BT /F1 9 Tf 260 30 Td (Page 1 of 2  |  Attendance Pro Documentation) Tj ET")
    pages_content.append("\n".join(p1))

    # Page 2: Data Models, Services, Commands, GitHub Info
    p2 = []
    # Header bar
    p2.append("0.10 0.14 0.49 rg")
    p2.append("0 740 612 52 re f")
    p2.append("1 1 1 rg")
    p2.append("BT /F2 20 Tf 36 758 Td (ATTENDANCE PRO - TECHNICAL SPECIFICATIONS) Tj ET")

    # Section 3: Data Models & Service Layer
    p2.append("0.10 0.14 0.49 rg")
    p2.append("BT /F2 14 Tf 36 700 Td (3. Data Models & Service Layer) Tj ET")

    p2.append("0.2 0.2 0.2 rg")
    p2.append("BT /F2 10 Tf 44 680 Td (Student Model (lib/models/student.dart):) Tj ET")
    p2.append("BT /F1 10 Tf 54 666 Td (- Tracks id, name, email, status, attendancePercentage, appealCount.) Tj ET")
    p2.append("BT /F1 10 Tf 54 652 Td (- Maintains absentDates list, consecutiveDaysAttended streak, probationCleared flag.) Tj ET")
    p2.append("BT /F1 10 Tf 54 638 Td (- Computes penaltyPhase dynamically and evaluates isLocked(phaseThreshold).) Tj ET")

    p2.append("BT /F2 10 Tf 44 618 Td (Student Status Enum (lib/models/student_status.dart):) Tj ET")
    p2.append("BT /F1 10 Tf 54 604 Td (- Defines states: active, atRisk, financialHold, medicalPersonal, unexplainedAbsence, other.) Tj ET")

    p2.append("BT /F2 10 Tf 44 584 Td (Database Service (lib/services/database_service.dart):) Tj ET")
    p2.append("BT /F1 10 Tf 54 570 Td (- Cloud syncing for Firestore collections: students, appeals, flags, messages.) Tj ET")
    p2.append("BT /F1 10 Tf 54 556 Td (- Handles markAttendance, submitAppeal, clearProbation, and seedInitialData.) Tj ET")

    # Section 4: Installation & Verification
    p2.append("0.10 0.14 0.49 rg")
    p2.append("BT /F2 14 Tf 36 520 Td (4. Verification & CLI Commands) Tj ET")

    p2.append("0.95 0.95 0.95 rg")
    p2.append("36 410 540 90 re f")
    p2.append("0.8 0.8 0.8 rg")
    p2.append("36 410 540 90 re S")

    p2.append("0.1 0.1 0.1 rg")
    p2.append("BT /F2 9 Tf 46 480 Td (# Resolve dependencies) Tj ET")
    p2.append("BT /F1 9 Tf 46 468 Td (flutter pub get) Tj ET")
    p2.append("BT /F2 9 Tf 46 450 Td (# Run static code analysis) Tj ET")
    p2.append("BT /F1 9 Tf 46 438 Td (flutter analyze  --> [No issues found!]) Tj ET")
    p2.append("BT /F2 9 Tf 46 420 Td (# Execute unit and widget tests) Tj ET")
    p2.append("BT /F1 9 Tf 46 408 Td (flutter test     --> [All tests passed!]) Tj ET")

    # Section 5: GitHub Repository Summary
    p2.append("0.10 0.14 0.49 rg")
    p2.append("BT /F2 14 Tf 36 360 Td (5. GitHub Repository Information) Tj ET")

    p2.append("0.2 0.2 0.2 rg")
    p2.append("BT /F2 10 Tf 44 340 Td (Repository Link:) Tj /F1 10 Tf 150 340 Td (https://github.com/Rey2theewrld/attendance_pro_2) Tj ET")
    p2.append("BT /F2 10 Tf 44 322 Td (Main Branch:) Tj /F1 10 Tf 150 322 Td (master) Tj ET")
    p2.append("BT /F2 10 Tf 44 304 Td (Verified Code:) Tj /F1 10 Tf 150 304 Td (Clean build, all deprecated APIs updated, test cases passing.) Tj ET")

    # Footer
    p2.append("0.5 0.5 0.5 rg")
    p2.append("BT /F1 9 Tf 260 30 Td (Page 2 of 2  |  Attendance Pro Documentation) Tj ET")
    pages_content.append("\n".join(p2))

    # Constructing PDF Binary Objects
    objects = []

    # Obj 1: Catalog
    objects.append("1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj")

    # Obj 2: Pages
    objects.append("2 0 obj\n<< /Type /Pages /Count 2 /Kids [ 3 0 R 4 0 R ] >>\nendobj")

    # Obj 5: Font Helvetica
    objects.append("5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj")
    # Obj 6: Font Helvetica-Bold
    objects.append("6 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj")

    # Obj 3: Page 1
    stream1 = pages_content[0]
    objects.append(f"7 0 obj\n<< /Length {len(stream1)} >>\nstream\n{stream1}\nendstream\nendobj")
    objects.append("3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 7 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>\nendobj")

    # Obj 4: Page 2
    stream2 = pages_content[1]
    objects.append(f"8 0 obj\n<< /Length {len(stream2)} >>\nstream\n{stream2}\nendstream\nendobj")
    objects.append("4 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 8 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>\nendobj")

    # Assemble file
    pdf_header = "%PDF-1.4\n"
    offsets = []
    current_pos = len(pdf_header)

    body = ""
    # Ordering obj IDs: 1, 2, 5, 6, 7, 3, 8, 4
    obj_order = [1, 2, 5, 6, 7, 3, 8, 4]
    obj_map = {int(o.split()[0]): o for o in objects}

    ordered_objs = [obj_map[i] for i in obj_order]

    obj_offsets = {}
    for obj_str in ordered_objs:
        obj_id = int(obj_str.split()[0])
        obj_offsets[obj_id] = current_pos
        body += obj_str + "\n"
        current_pos += len(obj_str) + 1

    xref_pos = current_pos
    xref = "xref\n0 9\n0000000000 65535 f \n"
    for i in range(1, 9):
        xref += f"{obj_offsets[i]:010d} 00000 n \n"

    trailer = f"trailer\n<< /Size 9 /Root 1 0 R >>\nstartxref\n{xref_pos}\n%%EOF\n"

    with open(filename, "wb") as f:
        f.write((pdf_header + body + xref + trailer).encode('latin1'))

    print(f"Successfully generated {filename}")

if __name__ == "__main__":
    create_pdf("Attendance_Pro_Documentation.pdf")
