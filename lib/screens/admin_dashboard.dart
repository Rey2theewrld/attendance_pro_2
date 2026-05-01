import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/appeal.dart';
import '../services/database_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: [
            _buildTab(Icons.warning_amber, 'Flags', 'flags'),
            _buildTab(Icons.mail_outline, 'Appeals', 'appeals', whereField: 'status', whereValue: 'pending'),
            _buildTab(Icons.verified_user, 'Probation', 'students', isProbation: true),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _FlaggedListView(),
          const _AppealsListView(),
          const _ProbationWatchView(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _resetAllData(),
        label: const Text('Reset Testing Data'),
        icon: const Icon(Icons.refresh),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, String collection, {String? whereField, String? whereValue, bool isProbation = false}) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
          const SizedBox(width: 4),
          StreamBuilder<QuerySnapshot>(
            stream: isProbation 
              ? FirebaseFirestore.instance.collection('students').where('status', isEqualTo: 'active').snapshots()
              : (whereField != null 
                  ? FirebaseFirestore.instance.collection(collection).where(whereField, isEqualTo: whereValue).snapshots()
                  : FirebaseFirestore.instance.collection(collection).snapshots()),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              
              int count = snapshot.data!.docs.length;
              
              // Special filtering for probation badge (only count those with 5+ streak and not cleared)
              if (isProbation) {
                count = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final streak = data['consecutiveDaysAttended'] ?? 0;
                  final isCleared = data['probationCleared'] ?? false;
                  final hasSkips = (data['absentDates'] as List? ?? []).isNotEmpty;
                  return streak >= 5 && !isCleared && hasSkips;
                }).length;
              }

              if (count == 0) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _resetAllData() async {
    await DatabaseService().seedInitialData();
  }
}

class _ProbationWatchView extends StatelessWidget {
  const _ProbationWatchView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('students')
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final probationStudents = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final absentDates = data['absentDates'] as List? ?? [];
          return absentDates.isNotEmpty && !(data['probationCleared'] ?? false);
        }).toList();

        if (probationStudents.isEmpty) {
          return const Center(child: Text('No students currently on probation.'));
        }

        return ListView.builder(
          itemCount: probationStudents.length,
          itemBuilder: (context, index) {
            final studentDoc = probationStudents[index];
            final data = studentDoc.data() as Map<String, dynamic>;
            final streak = data['consecutiveDaysAttended'] ?? 0;
            final phase = (data['absentDates'] as List? ?? []).length;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange,
                  child: Text('$phase', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Current Streak: $streak / 5 Days 🔥'),
                trailing: streak >= 5
                    ? ElevatedButton(
                        onPressed: () => DatabaseService().clearProbation(studentDoc.id),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                        child: const Text('UNLOCK ALL'),
                      )
                    : const Icon(Icons.timer_outlined, color: Colors.grey),
              ),
            );
          },
        );
      },
    );
  }
}

class _FlaggedListView extends StatelessWidget {
  const _FlaggedListView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('flags').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No suspicious patterns detected.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var flag = snapshot.data!.docs[index];
            return Card(
              color: Colors.red[50],
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.flag, color: Colors.white)),
                title: Text(flag['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(flag['reason']),
                trailing: Text(
                  flag['severity'],
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _AppealsListView extends StatelessWidget {
  const _AppealsListView();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appeals').where('status', isEqualTo: 'pending').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No pending appeals.'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var appealData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            var appealId = snapshot.data!.docs[index].id;
            
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('students').doc(appealData['studentId']).snapshots(),
              builder: (context, studentSnap) {
                int streak = 0;
                if (studentSnap.hasData && studentSnap.data!.exists) {
                  streak = studentSnap.data!['consecutiveDaysAttended'] ?? 0;
                }

                return Card(
                  child: ExpansionTile(
                    title: Text('Appeal: ${appealData['category'].toString().toUpperCase()}'),
                    subtitle: Text('Student Streak: $streak Days 🔥'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Explanation:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(appealData['explanation']),
                            const SizedBox(height: 16),
                            
                            if (appealData['attachmentName'] != null) ...[
                              _buildAttachmentBox(appealData['attachmentName']),
                              const SizedBox(height: 16),
                            ],

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _handleAppeal(appealId, 'rejected', appealData['studentId']),
                                  child: const Text('REJECT', style: TextStyle(color: Colors.red)),
                                ),
                                ElevatedButton(
                                  onPressed: () => _handleAppeal(appealId, 'approved', appealData['studentId']),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  child: const Text('APPROVE & PARDON'),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }
            );
          },
        );
      },
    );
  }

  Widget _buildAttachmentBox(String fileName) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text('Proof: $fileName', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
          const Icon(Icons.open_in_new, size: 16, color: Colors.blue),
        ],
      ),
    );
  }

  void _handleAppeal(String id, String status, String studentId) async {
    await FirebaseFirestore.instance.collection('appeals').doc(id).update({'status': status});
    
    if (status == 'approved') {
      await FirebaseFirestore.instance.collection('students').doc(studentId).update({
        'status': 'active',
        'probationCleared': false, 
      });
      
      // SEND APPROVAL MESSAGE
      await DatabaseService().sendMessage(
        studentId, 
        'Appeal Approved!', 
        'Your appeal has been approved. You are now on probation. Maintain a 5-day streak to unlock all services.'
      );
    } else if (status == 'rejected') {
      // SEND REJECTION MESSAGE
      await DatabaseService().sendMessage(
        studentId, 
        'Appeal Rejected', 
        'Your appeal was rejected. Please visit the Lead Lecturer\'s office for a manual admin review.'
      );
    }
  }
}
