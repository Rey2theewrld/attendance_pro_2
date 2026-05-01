import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/appeal.dart';
import '../services/database_service.dart';

class AppealScreen extends StatefulWidget {
  final String studentId;
  final int currentAppealCount;

  const AppealScreen({
    super.key,
    required this.studentId,
    required this.currentAppealCount,
  });

  @override
  State<AppealScreen> createState() => _AppealScreenState();
}

class _AppealScreenState extends State<AppealScreen> {
  final DatabaseService _dbService = DatabaseService();
  AppealCategory _selectedCategory = AppealCategory.other;
  final _explanationController = TextEditingController();
  bool _isSubmitting = false;
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    final int appealNumber = widget.currentAppealCount + 1;
    final bool requiresEvidence = appealNumber >= 3;
    final bool canProvideAttachment = appealNumber >= 2;

    return Scaffold(
      appBar: AppBar(title: Text('Appeal #$appealNumber')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(appealNumber),
            const SizedBox(height: 24),
            const Text(
              'Select Reason for Absence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppealCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: AppealCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 24),
            const Text(
              'Detailed Explanation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _explanationController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: requiresEvidence 
                  ? 'Please provide a full explanation as this is your final appeal...'
                  : 'Briefly explain your situation...',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            
            if (canProvideAttachment) ...[
              const Text(
                'Evidence / Attachments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.attach_file, color: requiresEvidence ? Colors.red : Colors.blue),
                title: Text(_fileName ?? (requiresEvidence ? 'Required: Upload Evidence' : 'Optional: Upload Attachment')),
                subtitle: const Text('PDF, Images, or Medical Docs'),
                tileColor: Colors.grey[100],
                trailing: _fileName != null ? const Icon(Icons.check_circle, color: Colors.green) : null,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                onTap: _pickFile,
              ),
              if (requiresEvidence && _fileName == null)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    '* Final appeal requires verified documentation.',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitAppeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT TO ADMINISTRATOR'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickFile() async {
    try {
      // THE "BYPASS" - Using dynamic to tell the compiler to ignore the 'platform' check
      // This will work at runtime because the library DOES have the member.
      final dynamicPicker = FilePicker.platform as dynamic;
      final result = await dynamicPicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        setState(() {
          _fileName = result.files.single.name;
        });
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Widget _buildInfoCard(int num) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              num >= 3 
                ? 'WARNING: This is your final appeal. Strict evidence is required.'
                : 'Your appeal will be reviewed by the course administrator.',
              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  void _submitAppeal() async {
    final int appealNumber = widget.currentAppealCount + 1;
    
    if (_explanationController.text.isEmpty) {
      _showError('Please provide an explanation.');
      return;
    }

    if (appealNumber >= 3 && _fileName == null) {
      _showError('Documentation is required for the final appeal.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _dbService.submitAppeal(
        widget.studentId,
        _selectedCategory.name,
        _explanationController.text,
        attachmentName: _fileName, // PASS THE FILE NAME HERE
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appeal submitted! Penalties will remain until review.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
