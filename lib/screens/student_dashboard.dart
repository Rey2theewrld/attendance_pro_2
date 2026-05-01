import 'package:attendance_pro/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/student_status.dart';
import 'appeal_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // For now, we'll hardcode '1' as the logged-in student ID (John Doe)
    // In a real app, this would come from Firebase Auth
    const String loggedInStudentId = '1';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('students').doc(loggedInStudentId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }

          final student = Student.fromMap(snapshot.data!.data() as Map<String, dynamic>, snapshot.data!.id);
          final phase = student.penaltyPhase;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(context, student),
                
                // PERMANENT RECORD: Show alert as long as they have a skip history (phase > 0)
                if (phase > 0)
                  _buildPenaltyAlert(context, phase, student),
                
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'School Services',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildServiceGrid(context, student),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, Student student) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(student.name[0], style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Chip(
            label: Text(student.status.label),
            backgroundColor: student.status.color.withOpacity(0.2),
            labelStyle: TextStyle(color: student.status.color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(context, 'Skips', '${student.absentDates.length}'), // Show number of skips
              const SizedBox(width: 32),
              _buildStatItem(context, 'Appeals', '${student.appealCount}/3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildPenaltyAlert(BuildContext context, int phase, Student student) {
    String message = '';
    IconData icon = Icons.warning;
    Color color = Colors.orange;
    
    // The button only shows if they are currently locked (not pardoned)
    bool showAppealButton = student.status == StudentStatus.unexplainedAbsence;
    bool isPardoned = student.status == StudentStatus.active;

    // Calculate current status (Appeal 1, 2, or 3)
    final int nextAppealNum = student.appealCount + 1;
    final String appealInfo = student.appealCount < 3 ? ' [Next: Appeal #$nextAppealNum/3]' : '';
    final String pardonTag = isPardoned ? ' (PARDONED)' : '';

    if (student.appealCount >= 3) {
      message = 'MAX APPEALS REACHED. You are fully locked out. Please see the Lead Lecturer in person.';
      color = Colors.black;
      icon = Icons.lock_person;
      showAppealButton = false;
    } else if (phase == 1) {
      message = 'Phase 1: Warning issued. Learning Materials Locked.$appealInfo$pardonTag';
    } else if (phase == 2) {
      message = 'Phase 2: Total Lockdown active.$appealInfo$pardonTag';
      color = Colors.deepOrange;
    } else if (phase >= 3) {
      message = 'Phase 3: Final Restriction!$appealInfo$pardonTag';
      color = Colors.red;
      icon = Icons.block;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          if (showAppealButton)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppealScreen(
                      studentId: student.id,
                      currentAppealCount: student.appealCount,
                    ),
                  ),
                );
              },
              child: const Text('APPEAL'),
            ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context, Student student) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildServiceCard(context, 'Timetable', Icons.calendar_month, locked: student.isLocked(2), studentId: student.id),
        _buildServiceCard(context, 'Messages', Icons.message, locked: student.isLocked(2), studentId: student.id),
        _buildServiceCard(context, 'Learning Materials', Icons.book, locked: student.isLocked(1), studentId: student.id),
        _buildServiceCard(context, 'Exams', Icons.quiz, locked: student.isLocked(2, isCritical: true), studentId: student.id),
      ],
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, IconData icon, {bool locked = false, String? studentId}) {
    // If it's the messages card, we wrap the content in a StreamBuilder for the badge
    Widget cardContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              locked ? Icons.lock : icon,
              size: 40,
              color: locked ? Colors.grey : Theme.of(context).colorScheme.primary,
            ),
            if (!locked && title == 'Messages' && studentId != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('studentId', isEqualTo: studentId)
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox.shrink();
                  return Positioned(
                    right: -5,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${snapshot.data!.docs.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: locked ? Colors.grey : Colors.black,
          ),
        ),
      ],
    );

    return Card(
      elevation: locked ? 0 : 2,
      color: locked ? Colors.grey[200] : Colors.white,
      child: InkWell(
        onTap: locked ? null : () {
          if (title == 'Messages' && studentId != null) {
            _showMessages(context, studentId);
          }
        },
        child: cardContent,
      ),
    );
  }

  void _showMessages(BuildContext context, String studentId) {
    // Mark as read immediately when opened to stop the laggy feeling of the counter staying up
    DatabaseService().markMessagesAsRead(studentId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('messages')
              .where('studentId', isEqualTo: studentId)
              .snapshots(), // Temporarily removed orderBy to check if index is the issue
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Query Error: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No messages yet.'));
            }
            
            final messages = snapshot.data!.docs;

            return Column(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('My Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                Expanded(
                  child: messages.isEmpty 
                    ? const Center(child: Text('No messages yet.'))
                    : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isRead = msg['isRead'] ?? false;
                          return ListTile(
                            leading: Icon(
                              isRead ? Icons.notifications_none : Icons.notifications_active, 
                              color: isRead ? Colors.grey : Colors.blue
                            ),
                            title: Text(msg['title'], style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.bold)),
                            subtitle: Text(msg['body']),
                            trailing: Text(
                              msg['timestamp'] != null 
                                ? (msg['timestamp'] as Timestamp).toDate().toString().substring(5, 16)
                                : 'Just now',
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
