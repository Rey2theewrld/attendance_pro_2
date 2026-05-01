import 'package:flutter/material.dart';
import 'lecturer_dashboard.dart';
import 'student_dashboard.dart';
import 'admin_dashboard.dart';
import '../services/database_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school, size: 80, color: Color(0xFF1A237E)),
                    const SizedBox(height: 16),
                    Text(
                      'Attendance Pro',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A237E),
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Student Accountability System'),
                    const SizedBox(height: 32),
                    _buildLoginButton(
                      context,
                      label: 'Lecturer Login',
                      icon: Icons.assignment_ind,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LecturerDashboard()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLoginButton(
                      context,
                      label: 'Student Login',
                      icon: Icons.person,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StudentDashboard()),
                      ),
                      isSecondary: true,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminDashboard()),
                      ),
                      child: const Text('Admin Console (Staff Only)', style: TextStyle(color: Color(0xFF1A237E))),
                    ),
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () async {
                        await DatabaseService().seedInitialData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cloud Seeded! Students added to Firebase.')),
                        );
                      },
                      icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                      label: const Text('Setup Development Data', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool isSecondary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary ? Colors.white : const Color(0xFF1A237E),
          foregroundColor: isSecondary ? const Color(0xFF1A237E) : Colors.white,
          side: isSecondary ? const BorderSide(color: Color(0xFF1A237E)) : null,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
