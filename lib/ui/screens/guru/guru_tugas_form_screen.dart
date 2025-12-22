import 'package:flutter/material.dart';
import 'package:piketin_fe/services/user_service.dart';
import 'package:provider/provider.dart';
import '../../../models/teacher_assignment_model.dart';
import '../../../models/student_model.dart';
import '../../../models/user_model.dart';
import '../../../models/subject_model.dart';
import '../../../services/teacher_assignment_service.dart';
import '../../../services/student_service.dart';
import '../../../services/subject_service.dart';
import '../../../ui/widgets/searchable_selection_field.dart';

class GuruTugasFormScreen extends StatefulWidget {
  final TeacherAssignment? assignment;

  const GuruTugasFormScreen({super.key, this.assignment});

  @override
  State<GuruTugasFormScreen> createState() => _GuruTugasFormScreenState();
}

class _GuruTugasFormScreenState extends State<GuruTugasFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Data Source untuk Dropdown
  List<User> _teachers = [];
  List<Student> _students = [];
  List<Subject> _subjects = [];
  Map<int, String> _classes = {}; // Map of classId to className

  bool _isLoadingInitial = true; // Loading saat ambil data awal
  bool _isSubmitting = false; // Loading saat tombol simpan ditekan

  // Form Controllers & Values
  User? _selectedTeacher;
  int? _selectedClassId;
  Subject? _selectedSubject;
  final _detailsController = TextEditingController();
  final _reasonController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _loadMasterData();

    // Set initial values if editing
    if (widget.assignment != null) {
      _detailsController.text = widget.assignment!.assignmentDetails;
      _reasonController.text = widget.assignment!.reason;
      _dueDate = widget.assignment!.dueDate;
    }
  }

  // Load all necessary data
  Future<void> _loadMasterData() async {
    try {
      // First load teachers and students in parallel
      final teachersFuture = context.read<UserService>().getMapelUsers();
      final studentsFuture = context.read<StudentService>().getStudents();

      // Try to load subjects, but handle potential 403 error
      Future<List<Subject>> subjectsFuture;
      try {
        subjectsFuture = context.read<SubjectService>().getSubjects();
      } catch (e) {
        // If we can't load subjects, show a warning but continue
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tidak dapat memuat daftar mata pelajaran. Anda mungkin tidak memiliki izin.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        subjectsFuture = Future.value(<Subject>[]);
      }

      final results = await Future.wait([
        teachersFuture,
        subjectsFuture,
        studentsFuture,
      ]);

      if (mounted) {
        final students = results[2] as List<Student>;
        final classMap = <int, String>{};

        // Extract unique classes from students
        for (var student in students) {
          if (student.classId != null &&
              !classMap.containsKey(student.classId)) {
            classMap[student.classId!] =
                student.className ?? 'Kelas ${student.classId}';
          }
        }

        setState(() {
          _teachers = results[0] as List<User>;
          _subjects = results[1] as List<Subject>;
          _students = students;
          _classes = classMap;
          _isLoadingInitial = false;
        });

        // Set initial selection for edit mode
        if (widget.assignment != null) {
          _selectedTeacher = _teachers.firstWhere(
            (t) => t.id == widget.assignment!.teacher.id,
            orElse: () => _teachers.first,
          );

          _selectedClassId = widget.assignment!.classInfo.id;

          if (_subjects.isNotEmpty) {
            _selectedSubject = _subjects.firstWhere(
              (s) => s.id == widget.assignment!.subject.id,
              orElse: () => _subjects.first,
            );
          }
        } else {
          // Set default selections for new assignment
          _selectedTeacher = _teachers.isNotEmpty ? _teachers.first : null;
          _selectedClassId = _classes.keys.isNotEmpty
              ? _classes.keys.first
              : null;
          _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _selectedTeacher == null ||
        _selectedClassId == null ||
        _selectedSubject == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final service = context.read<TeacherAssignmentService>();

      if (widget.assignment == null) {
        // Create new assignment
        await service.createAssignment(
          teacherUserId: _selectedTeacher!.id,
          classId: _selectedClassId!,
          subjectId: _selectedSubject!.id,
          details: _detailsController.text,
          reason: _reasonController.text,
          dueDate: _dueDate,
        );
      } else {
        // Update existing assignment
        await service.updateAssignment(
          id: widget.assignment!.id,
          teacherUserId: _selectedTeacher!.id,
          classId: _selectedClassId!,
          subjectId: _selectedSubject!.id,
          details: _detailsController.text,
          reason: _reasonController.text,
          dueDate: _dueDate,
        );
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingInitial) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignment == null ? 'Tambah Tugas' : 'Edit Tugas'),
        actions: [
          if (widget.assignment != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isSubmitting ? null : _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guru Pengajar Dropdown
              SearchableSelectionField<User>(
                label: "Guru Pengajar",
                icon: Icons.person,
                items: _teachers,
                value: _selectedTeacher,
                itemLabel: (user) => user.fullname,
                onChanged: (val) {
                  setState(() {
                    _selectedTeacher = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Kelas Dropdown
              SearchableSelectionField<int>(
                label: "Kelas",
                icon: Icons.class_,
                items: _classes.keys.toList(), // This gives you List<int>
                value: _selectedClassId,
                itemLabel: (classId) => _classes[classId] ?? 'Kelas $classId',
                onChanged: (val) {
                  setState(() {
                    _selectedClassId = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Mata Pelajaran Dropdown
              SearchableSelectionField<Subject>(
                label: "Mata Pelajaran",
                icon: Icons.menu_book,
                items: _subjects,
                value: _selectedSubject,
                itemLabel: (subject) => subject.name,
                onChanged: (val) {
                  setState(() {
                    _selectedSubject = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Detail Tugas
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(
                  labelText: 'Detail Tugas',
                  hintText: 'Masukkan detail tugas...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Alasan Tugas
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Tugas',
                  hintText: 'Masukkan alasan tugas...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              // Tanggal Deadline
              ListTile(
                title: const Text('Tanggal Deadline'),
                subtitle: Text(
                  _dueDate == null
                      ? 'Pilih tanggal'
                      : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(widget.assignment == null ? 'SIMPAN' : 'UPDATE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Tugas'),
        content: const Text('Apakah Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('BATAL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('HAPUS'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isSubmitting = true);
      try {
        // await context.read<TeacherAssignmentService>()
        //     .deleteAssignment(widget.assignment!.id);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }
}
