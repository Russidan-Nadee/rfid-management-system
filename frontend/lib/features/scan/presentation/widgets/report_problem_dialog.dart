import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../di/injection.dart';

class ReportProblemDialog extends StatefulWidget {
  final String assetNo;
  final String assetDescription;

  const ReportProblemDialog({
    super.key,
    required this.assetNo,
    required this.assetDescription,
  });

  @override
  State<ReportProblemDialog> createState() => _ReportProblemDialogState();
}

class _ReportProblemDialogState extends State<ReportProblemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedProblemType = ProblemType.assetDamage;
  String _selectedPriority = NotificationPriority.normal;
  bool _isSubmitting = false;

  final List<Map<String, String>> _problemTypes = [
    {'value': ProblemType.assetDamage, 'label': 'Asset Damage'},
    {'value': ProblemType.assetMissing, 'label': 'Asset Missing'},
    {'value': ProblemType.locationIssue, 'label': 'Location Issue'},
    {'value': ProblemType.dataError, 'label': 'Data Error'},
    {'value': ProblemType.urgentIssue, 'label': 'Critical Issue'},
    {'value': ProblemType.other, 'label': 'Other'},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': NotificationPriority.low, 'label': 'Low', 'color': Colors.blue},
    {'value': NotificationPriority.normal, 'label': 'Normal', 'color': Colors.green},
    {'value': NotificationPriority.high, 'label': 'High', 'color': Colors.orange},
    {'value': NotificationPriority.urgent, 'label': 'Critical', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    print('🔍 Dialog: Report Problem Dialog opened');
    print('🔍 Dialog: Asset No: ${widget.assetNo}');
    print('🔍 Dialog: Asset Description: ${widget.assetDescription}');
    print('🔍 Dialog: Initial Problem Type: $_selectedProblemType');
    print('🔍 Dialog: Initial Priority: $_selectedPriority');
    print('🔍 Dialog: Available Problem Types: ${_problemTypes.map((e) => e['value']).toList()}');
    print('🔍 Dialog: Available Priorities: ${_priorities.map((e) => e['value']).toList()}');
  }

  @override
  void dispose() {
    print('🔍 Dialog: Report Problem Dialog disposed');
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.report_problem,
                  color: isDark ? AppColors.darkText : theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Report Problem',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Asset: ${widget.assetNo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: isDark ? AppColors.darkText : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Problem Type
                      Text(
                        'Problem Type *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : theme.colorScheme.outline,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedProblemType,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: _problemTypes.map((type) {
                            return DropdownMenuItem(
                              value: type['value'],
                              child: Text(type['label']!),
                            );
                          }).toList(),
                          onChanged: (value) {
                            print('🔍 Dialog: Problem Type changed from $_selectedProblemType to $value');
                            setState(() {
                              _selectedProblemType = value!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Priority
                      Text(
                        'Priority *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _priorities.map((priority) {
                          final isSelected = _selectedPriority == priority['value'];
                          return ChoiceChip(
                            label: Text(
                              priority['label'],
                              style: TextStyle(
                                color: isSelected 
                                    ? Colors.white 
                                    : (isDark ? AppColors.darkText : theme.colorScheme.onSurface),
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              print('🔍 Dialog: Priority changed from $_selectedPriority to ${priority['value']}');
                              setState(() {
                                _selectedPriority = priority['value'];
                              });
                            },
                            selectedColor: priority['color'],
                            backgroundColor: isDark ? AppColors.darkBorder : theme.colorScheme.surface,
                            side: BorderSide(
                              color: isSelected 
                                  ? priority['color'] 
                                  : (isDark ? AppColors.darkBorder : theme.colorScheme.outline),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Subject
                      Text(
                        'Subject *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _subjectController,
                        decoration: InputDecoration(
                          hintText: 'Brief description of the problem',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface.withValues(alpha: 0.3) : theme.colorScheme.surface,
                        ),
                        maxLength: 255,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Subject is required';
                          }
                          if (value.trim().length < 5) {
                            return 'Subject must be at least 5 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'Description *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Detailed description of the problem...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurface.withValues(alpha: 0.3) : theme.colorScheme.surface,
                        ),
                        maxLines: 4,
                        maxLength: 1000,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          if (value.trim().length < 10) {
                            return 'Description must be at least 10 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Submitting...'),
                          ],
                        )
                      : const Text('Submit Report'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport() async {
    print('🔍 Dialog: Submit Report button pressed');
    print('🔍 Dialog: Starting form validation...');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Dialog: Form validation FAILED');
      return;
    }
    
    print('✅ Dialog: Form validation PASSED');
    print('🔍 Dialog: Form data to submit:');
    print('  - Asset No: ${widget.assetNo.isNotEmpty ? widget.assetNo : 'null'}');
    print('  - Problem Type: $_selectedProblemType');
    print('  - Priority: $_selectedPriority');
    print('  - Subject: "${_subjectController.text.trim()}" (${_subjectController.text.trim().length} chars)');
    print('  - Description: "${_descriptionController.text.trim()}" (${_descriptionController.text.trim().length} chars)');

    setState(() {
      _isSubmitting = true;
    });
    print('🔍 Dialog: Set submitting state to true');

    try {
      print('🔍 Dialog: Getting NotificationService from DI...');
      final notificationService = getIt<NotificationService>();
      print('✅ Dialog: NotificationService obtained successfully');
      
      print('🔍 Dialog: Calling reportProblem API...');
      final response = await notificationService.reportProblem(
        assetNo: widget.assetNo.isNotEmpty ? widget.assetNo : null,
        problemType: _selectedProblemType,
        priority: _selectedPriority,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      
      print('🔍 Dialog: API call completed');
      print('🔍 Dialog: Response success: ${response.success}');
      print('🔍 Dialog: Response message: ${response.message}');
      print('🔍 Dialog: Response data: ${response.data}');

      if (mounted) {
        if (response.success) {
          print('✅ Dialog: Success - closing dialog and showing success message');
          Navigator.of(context).pop();
          final notificationId = response.data?['notification_id'];
          final successMessage = notificationId != null 
              ? 'Problem reported successfully (ID: $notificationId)'
              : 'Problem reported successfully';
          Helpers.showSuccess(context, successMessage);
        } else {
          print('❌ Dialog: Failed - showing error message');
          Helpers.showError(context, response.message);
        }
      } else {
        print('⚠️ Dialog: Widget not mounted, skipping UI updates');
      }
    } catch (error) {
      print('💥 Dialog: Exception caught: $error');
      print('💥 Dialog: Exception type: ${error.runtimeType}');
      if (mounted) {
        Helpers.showError(context, 'Failed to submit report: $error');
      }
    } finally {
      print('🔍 Dialog: Cleanup - setting submitting state to false');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}