import 'package:flutter/material.dart';
import '../models/student.dart';
import '../models/student_status.dart';
import '../services/database_service.dart';

class LecturerDashboard extends StatefulWidget {
  const LecturerDashboard({super.key});

  @override
  State<LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<LecturerDashboard> {
  final DatabaseService _dbService = DatabaseService();
  bool hideFinancialHold = false;
  bool showOnlyUnexplained = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<List<Student>>(
              stream: _dbService.getStudents(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final students = snapshot.data!.where((s) {
                  if (hideFinancialHold && s.status == StudentStatus.financialHold) return false;
                  if (showOnlyUnexplained && s.status != StudentStatus.unexplainedAbsence) return false;
                  return true;
                }).toList();

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _buildStudentCard(student);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: student.status.color,
          child: Text(student.name[0], style: const TextStyle(color: Colors.white)),
        ),
        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${student.status.label} • ${student.attendancePercentage.toStringAsFixed(1)}%'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              onPressed: () => _dbService.markAttendance(student.id, true),
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              onPressed: () => _dbService.markAttendance(student.id, false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Hide Financial Hold'),
              selected: hideFinancialHold,
              onSelected: (val) => setState(() => hideFinancialHold = val),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Unexplained Only'),
              selected: showOnlyUnexplained,
              onSelected: (val) => setState(() => showOnlyUnexplained = val),
            ),
          ],
        ),
      ),
    );
  }
}
