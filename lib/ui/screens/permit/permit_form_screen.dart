import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/student_model.dart';
import '../../../models/user_model.dart';
import '../../../services/permit_service.dart';
import '../../../services/student_service.dart';
import '../../../services/user_service.dart';
import '../../widgets/searchable_selection_field.dart';

class PermitFormScreen extends StatefulWidget {
  const PermitFormScreen({super.key});

  @override
  State<PermitFormScreen> createState() => _PermitFormScreenState();
}

class _PermitFormScreenState extends State<PermitFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Data Source untuk Dropdown
  List<Student> _students = [];
  List<User> _teachers = [];

  bool _isLoadingInitial = true; // Loading saat ambil data awal
  bool _isSubmitting = false; // Loading saat tombol simpan ditekan

  // Form Controllers & Values
  Student? _selectedStudent;
  User? _selectedTeacher;
  final _reasonController = TextEditingController();
  final _hoursStartController = TextEditingController();
  final _hoursEndController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _hoursStartController.dispose();
    _hoursEndController.dispose();
    super.dispose();
  }

  // Ambil data Siswa & Guru sekaligus
  Future<void> _loadMasterData() async {
    try {
      final results = await Future.wait([
        context.read<StudentService>().getStudents(),
        context.read<UserService>().getMapelUsers(),
      ]);

      if (mounted) {
        setState(() {
          _students = results[0] as List<Student>;
          _teachers = results[1] as List<User>;
          _isLoadingInitial = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingInitial = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validasi manual untuk dropdown
    if (_selectedStudent == null || _selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pilih Siswa dan Guru Mapel terlebih dahulu"),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final int start = int.parse(_hoursStartController.text);
      final int? end = _hoursEndController.text.isNotEmpty
          ? int.parse(_hoursEndController.text)
          : null;

      await context.read<PermitService>().createPermit(
        studentNis: _selectedStudent!.nis,
        mapelUserId: _selectedTeacher!.id,
        reason: _reasonController.text,
        hoursStart: start,
        hoursEnd: end,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Izin berhasil dibuat"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali dengan hasil 'true'
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Izin Baru")),
      body: _isLoadingInitial
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === PILIH SISWA (SEARCHABLE) ===
                    SearchableSelectionField<Student>(
                      label: "Siswa",
                      icon: Icons.person,
                      items: _students,
                      value: _selectedStudent,
                      itemLabel: (student) =>
                          "${student.name} (${student.className ?? '-'})",
                      onChanged: (val) {
                        setState(() {
                          _selectedStudent = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // === PILIH GURU MAPEL (SEARCHABLE) ===
                    SearchableSelectionField<User>(
                      label: "Guru Pengajar",
                      icon: Icons.school,
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

                    // === JAM MULAI & SELESAI ===
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _hoursStartController,
                            decoration: const InputDecoration(
                              labelText: "Jam Mulai (Ke-)",
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (val) =>
                                (val == null || val.isEmpty) ? 'Wajib' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _hoursEndController,
                            decoration: const InputDecoration(
                              labelText: "Sampai (Opsional)",
                              prefixIcon: Icon(Icons.access_time_filled),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // === ALASAN ===
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: "Alasan Izin",
                        prefixIcon: Icon(Icons.assignment),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 32),

                    // === TOMBOL SIMPAN ===
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("AJUKAN IZIN"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
