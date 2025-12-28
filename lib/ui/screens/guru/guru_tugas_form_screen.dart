import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/teacher_assignment_model.dart';
import '../../../models/user_model.dart';
import '../../../models/subject_model.dart';
import '../../../models/class_model.dart'; // Import ClassModel
import '../../../services/teacher_assignment_service.dart';
import '../../../services/user_service.dart';
import '../../../services/subject_service.dart';
import '../../../services/class_service.dart'; // Import ClassService
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
  List<Subject> _subjects = [];
  List<ClassModel> _classes = []; // Menggunakan List<ClassModel>

  bool _isLoadingInitial = true;
  bool _isSubmitting = false;

  // Form Controllers & Values
  User? _selectedTeacher;
  ClassModel? _selectedClass; // Simpan objek ClassModel, bukan int ID saja
  Subject? _selectedSubject;
  final _detailsController = TextEditingController();
  final _reasonController = TextEditingController();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _loadMasterData();

    if (widget.assignment != null) {
      _detailsController.text = widget.assignment!.assignmentDetails;
      _reasonController.text = widget.assignment!.reason;
      _dueDate = widget.assignment!.dueDate;
    }
  }

  Future<void> _loadMasterData() async {
    try {
      // Load Teachers, Subjects, dan Classes secara paralel
      // Kita TIDAK LAGI butuh StudentService di sini
      final results = await Future.wait([
        context.read<UserService>().getMapelUsers(),
        context.read<SubjectService>().getSubjects(
          limit: 100,
        ), // Ambil banyak subject
        context.read<ClassService>().getClasses(), // <--- Ambil Kelas langsung
      ]);

      if (mounted) {
        setState(() {
          _teachers = results[0] as List<User>;
          _subjects = results[1] as List<Subject>;
          _classes =
              results[2] as List<ClassModel>; // Parsing ke List<ClassModel>
          _isLoadingInitial = false;
        });

        // Set initial selection for edit mode
        if (widget.assignment != null) {
          // Cari Teacher
          _selectedTeacher = _teachers.firstWhere(
            (t) => t.id == widget.assignment!.teacher.id,
            orElse: () => _teachers.first,
          );

          // Cari Class berdasarkan ID
          if (_classes.isNotEmpty) {
            try {
              _selectedClass = _classes.firstWhere(
                (c) => c.id == widget.assignment!.classInfo.id,
              );
            } catch (_) {
              // Jika kelas lama sudah dihapus/tidak ditemukan
            }
          }

          // Cari Subject
          if (_subjects.isNotEmpty) {
            try {
              _selectedSubject = _subjects.firstWhere(
                (s) => s.id == widget.assignment!.subject.id,
              );
            } catch (_) {}
          }
        } else {
          // Default values for new assignment (optional)
          // _selectedTeacher = _teachers.isNotEmpty ? _teachers.first : null;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data referensi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ... _selectDate sama seperti sebelumnya ...
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
        _selectedClass == null || // Cek object class
        _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi semua data (Guru, Kelas, Mapel)'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final service = context.read<TeacherAssignmentService>();

      if (widget.assignment == null) {
        // Create new assignment
        await service.createAssignment(
          teacherUserId: _selectedTeacher!.id,
          classId: _selectedClass!.id, // Ambil ID dari object ClassModel
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
          classId: _selectedClass!.id,
          subjectId: _selectedSubject!.id,
          details: _detailsController.text,
          reason: _reasonController.text,
          dueDate: _dueDate,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
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
                onChanged: (val) => setState(() => _selectedTeacher = val),
              ),
              const SizedBox(height: 16),

              // Kelas Dropdown (UPDATED)
              SearchableSelectionField<ClassModel>(
                label: "Kelas",
                icon: Icons.class_,
                items: _classes, // List<ClassModel>
                value: _selectedClass, // ClassModel?
                itemLabel: (cls) => cls.name, // Menampilkan nama kelas
                onChanged: (val) => setState(() => _selectedClass = val),
              ),
              const SizedBox(height: 16),

              // Mata Pelajaran Dropdown
              SearchableSelectionField<Subject>(
                label: "Mata Pelajaran",
                icon: Icons.menu_book,
                items: _subjects,
                value: _selectedSubject,
                itemLabel: (subject) => subject.name,
                onChanged: (val) => setState(() => _selectedSubject = val),
              ),
              const SizedBox(height: 16),

              // ... Detail Tugas, Alasan, Date, Button (Sama seperti sebelumnya) ...
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

              // Tanggal Deadline (Sama)
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

  // ... _confirmDelete sama seperti sebelumnya ...
  Future<void> _confirmDelete() async {
    // ... Copy logic confirm delete dari file lama ...
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
        await context.read<TeacherAssignmentService>().deleteAssignment(
          widget.assignment!.id,
        );
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
