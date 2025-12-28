import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/teacher_assignment_model.dart';
import '../../../models/subject_model.dart';
import '../../../models/class_model.dart';
import '../../../services/teacher_assignment_service.dart';
import '../../../services/subject_service.dart';
import '../../../services/class_service.dart';
import '../../../providers/auth_provider.dart'; // [PENTING] Import AuthProvider
import '../../../ui/widgets/searchable_selection_field.dart';

class GuruTugasFormScreen extends StatefulWidget {
  final TeacherAssignment? assignment;

  const GuruTugasFormScreen({super.key, this.assignment});

  @override
  State<GuruTugasFormScreen> createState() => _GuruTugasFormScreenState();
}

class _GuruTugasFormScreenState extends State<GuruTugasFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Data Source
  List<Subject> _subjects = [];
  List<ClassModel> _classes = [];

  bool _isLoadingInitial = true;
  bool _isSubmitting = false;

  // Form Values
  // [HAPUS] User? _selectedTeacher; -> Tidak butuh variabel ini lagi
  ClassModel? _selectedClass;
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
      // [UBAH] Kita tidak perlu lagi load daftar guru (getMapelUsers)
      final results = await Future.wait([
        context.read<SubjectService>().getSubjects(limit: 100),
        context.read<ClassService>().getClasses(),
      ]);

      if (mounted) {
        setState(() {
          _subjects = results[0] as List<Subject>;
          _classes = results[1] as List<ClassModel>;
          _isLoadingInitial = false;
        });

        // Set initial selection for edit mode
        if (widget.assignment != null) {
          // Cari Class
          if (_classes.isNotEmpty) {
            try {
              _selectedClass = _classes.firstWhere(
                (c) => c.id == widget.assignment!.classInfo.id,
              );
            } catch (_) {}
          }

          // Cari Subject
          if (_subjects.isNotEmpty) {
            try {
              _selectedSubject = _subjects.firstWhere(
                (s) => s.id == widget.assignment!.subject.id,
              );
            } catch (_) {}
          }
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
        _selectedClass == null ||
        _selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi Kelas dan Mata Pelajaran'),
        ),
      );
      return;
    }

    // [BARU] Ambil user yang sedang login dari AuthProvider
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi anda telah berakhir, silakan login ulang'),
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
          teacherUserId: currentUser.id, // [FIX] Gunakan ID user login
          classId: _selectedClass!.id,
          subjectId: _selectedSubject!.id,
          details: _detailsController.text,
          reason: _reasonController.text,
          dueDate: _dueDate,
        );
      } else {
        // Update existing assignment
        await service.updateAssignment(
          id: widget.assignment!.id,
          teacherUserId: currentUser.id, // [FIX] Gunakan ID user login
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
              // [HAPUS] Dropdown Guru Pengajar dihapus dari sini

              // Kelas Dropdown
              SearchableSelectionField<ClassModel>(
                label: "Kelas",
                icon: Icons.class_,
                items: _classes,
                value: _selectedClass,
                itemLabel: (cls) => cls.name,
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
