import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movestreak/providers/auth_provider.dart';
import 'package:movestreak/providers/activity_provider.dart';
import 'package:intl/intl.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({Key? key}) : super(key: key);

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _activitySuggestions = [
    'Walk',
    'Jog',
    'Run',
    'Gym Workout',
    'Yoga',
    'Cycling',
    'Swimming',
    'Dancing',
    'Sports',
    'Stretching',
    'Hiking',
    'Pilates',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Activity'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'What activity did you do today?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Activity Suggestions (Above home button)
                  Text(
                    'Select an activity:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _activitySuggestions
                        .map(
                          (suggestion) => ActionChip(
                            label: Text(suggestion),
                            onPressed: () {
                              _nameController.text = suggestion;
                            },
                            backgroundColor: Colors.green[100],
                            labelStyle: TextStyle(color: Colors.green[800]),
                          ),
                        )
                        .toList(),
                  ),
                  SizedBox(height: 24),

                  // Home Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Back to Home',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 32),

                  // Activity Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Activity Name',
                      hintText: 'e.g., Walk, Gym, Yoga',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.directions_walk),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an activity name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Duration Field
                  TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: 'Duration (minutes) - Optional',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.schedule),
                      suffixText: 'min',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Notes Field
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'How did it feel? Any details?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 4,
                  ),
                  SizedBox(height: 32),

                  // Log Button
                  Consumer2<AuthProvider, ActivityProvider>(
                    builder: (context, authProvider, activityProvider, _) {
                      return ElevatedButton(
                        onPressed: activityProvider.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  if (authProvider.user != null) {
                                    int? duration;
                                    if (_durationController.text.isNotEmpty) {
                                      duration = int.parse(
                                        _durationController.text,
                                      );
                                    }

                                    await activityProvider.logActivity(
                                      userId: authProvider.user!.id,
                                      name: _nameController.text,
                                      notes: _notesController.text.isEmpty
                                          ? null
                                          : _notesController.text,
                                      durationMinutes: duration,
                                    );

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Activity logged! You showed up today! 🎉',
                                          ),
                                          backgroundColor: Colors.green,
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: activityProvider.isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Log Activity',
                                style: TextStyle(fontSize: 16),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
