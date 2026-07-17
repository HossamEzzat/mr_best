import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/student_repository.dart';
import '../../groups/data/group_repository.dart';
import '../domain/student_model.dart';
import '../../groups/domain/group_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../groups/presentation/group_details_screen.dart'; // To invalidate students provider

class AddStudentScreen extends ConsumerStatefulWidget {
  final int? studentId;
  final int? groupId;

  const AddStudentScreen({super.key, this.studentId, this.groupId});

  @override
  ConsumerState<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends ConsumerState<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  final _schoolController = TextEditingController();

  List<GroupModel> _groupsList = [];
  int? _selectedGroupId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final groupRepo = ref.read(groupRepositoryProvider);
      final studentRepo = ref.read(studentRepositoryProvider);
      
      final groups = await groupRepo.getAllGroups();
      
      StudentModel? student;
      if (widget.studentId != null) {
        student = await studentRepo.getStudentById(widget.studentId!);
      }

      setState(() {
        _groupsList = groups;
        _isLoading = false;

        if (student != null) {
          _nameController.text = student.name;
          _phoneController.text = student.phone ?? '';
          _parentNameController.text = student.parentName ?? '';
          _parentPhoneController.text = student.parentPhone ?? '';
          _schoolController.text = student.school ?? '';
          _selectedGroupId = student.groupId;
        } else {
          // pre-select group if provided
          if (widget.groupId != null && groups.any((g) => g.id == widget.groupId)) {
            _selectedGroupId = widget.groupId;
          } else if (groups.isNotEmpty) {
            _selectedGroupId = groups.first.id;
          }
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحميل البيانات: $e'), backgroundColor: AppColors.absent),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _parentNameController.dispose();
    _parentPhoneController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.studentId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'تعديل بيانات الطالب' : 'إضافة طالب جديد'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _groupsList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'يجب إنشاء مجموعة دراسية أولاً قبل إضافة طلاب!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('رجوع'),
                          )
                        ],
                      ),
                    ),
                  )
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        DropdownButtonFormField<int>(
                          value: _selectedGroupId,
                          decoration: const InputDecoration(
                            labelText: 'المجموعة الدراسية',
                            prefixIcon: Icon(Icons.group),
                          ),
                          items: _groupsList.map((g) {
                            return DropdownMenuItem<int>(
                              value: g.id,
                              child: Text('${g.name} (${g.gradeLevel})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedGroupId = val;
                            });
                          },
                          validator: (val) => val == null ? 'يرجى اختيار المجموعة' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'الاسم بالكامل',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty ? 'يرجى إدخال اسم الطالب' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'رقم هاتف الطالب',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _parentNameController,
                          decoration: const InputDecoration(
                            labelText: 'اسم ولي الأمر',
                            prefixIcon: Icon(Icons.family_restroom),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _parentPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'رقم هاتف ولي الأمر',
                            prefixIcon: Icon(Icons.phone_android),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _schoolController,
                          decoration: const InputDecoration(
                            labelText: 'المدرسة',
                            prefixIcon: Icon(Icons.school),
                          ),
                        ),

                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveStudent,
                          child: Text(isEditMode ? 'حفظ التعديلات' : 'إضافة الطالب'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate() || _selectedGroupId == null) return;

    final student = StudentModel(
      id: widget.studentId,
      groupId: _selectedGroupId!,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      parentName: _parentNameController.text.trim().isEmpty ? null : _parentNameController.text.trim(),
      parentPhone: _parentPhoneController.text.trim().isEmpty ? null : _parentPhoneController.text.trim(),
      school: _schoolController.text.trim().isEmpty ? null : _schoolController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    final repo = ref.read(studentRepositoryProvider);
    try {
      if (widget.studentId != null) {
        await repo.updateStudent(student);
      } else {
        await repo.addStudent(student);
      }

      // Invalidate student lists
      ref.invalidate(groupStudentsProvider(_selectedGroupId!));
      ref.invalidate(groupsListProvider); // Updates student count in group list
      ref.invalidate(studentsSearchResultProvider); // Invalidate search cache if active

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.studentId != null ? 'تم تعديل بيانات الطالب بنجاح' : 'تم إضافة الطالب بنجاح'),
            backgroundColor: AppColors.present,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل الحفظ: $e'), backgroundColor: AppColors.absent),
        );
      }
    }
  }
}
