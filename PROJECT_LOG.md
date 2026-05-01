# Project: Attendance Pro
## Status Report - Phase 1: The Foundation

### 1. The Core Vision (The "Strict" System)
We moved away from a simple "Absent/Present" list and built a system based on **Accountability**:
- **Phased Penalties**: Phase 1 (Warning), Phase 2 (Limited Access), and Phase 3 (Full Restriction).
- **Smarter Appeals**: Predefined categories (Financial, Medical, etc.) to keep data clean.
- **Pattern Detection**: Automatically flags "Sneaky Fridays" and suspicious patterns.

### 2. Technical Steps Taken
- **Project Initialization**: Wiped default template, set up **Deep Indigo** school theme.
- **Model Architecture**:
    - `StudentStatus`: Handles 5 distinct student states.
    - `Student`: Logic for calculating penalty phases.
    - `Appeal`: Structure for the 5 appeal categories.
- **UI Implementation**:
    - `LoginScreen`: Dual entry for Students and Lecturers.
    - `LecturerDashboard`: "One-Click" marking with custom filters.
    - `StudentDashboard`: "Soft Lock" system for service access.
- **Cloud Setup (Firebase)**:
    - Integrated `firebase_core`, `auth`, and `firestore`.
    - Configured via FlutterFire CLI.
    - Initialized Firebase in `main.dart`.

### 3. Database Service
- Created `database_service.dart` to handle cloud syncing.
- Implemented **Friday Pattern Detection** logic.
- Implemented **Limited Appeals** tracker (Max 3/semester).
