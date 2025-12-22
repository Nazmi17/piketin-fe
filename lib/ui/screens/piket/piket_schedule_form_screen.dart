import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/piket_schedule_model.dart';
import '../../../models/user_model.dart';
import '../../../services/piket_schedule_service.dart';
import '../../../services/user_service.dart';
import '../../widgets/searchable_selection_field.dart';

class PiketScheduleFormScreen extends StatefulWidget {
  final PiketSchedule? schedule; // Jika null = Mode Tambah

  const PiketScheduleFormScreen({super.key, this.schedule});

  @override
  State<PiketScheduleFormScreen> createState() =>
      _PiketScheduleFormScreenState();
}

class _PiketScheduleFormScreenState extends State<PiketScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInitLoading = true;

  // Data Source
  List<User> _teachers = [];

  // Form Values
  User? _selectedTeacher;
  int? _selectedDay;

  // Opsi Hari (Sesuaikan dengan backend, biasanya 1=Senin, dst)
  final Map<int, String> _days = {
    1: "Senin",
    2: "Selasa",
    3: "Rabu",
    4: "Kamis",
    5: "Jumat",
    6: "Sabtu",
    0: "Minggu",
  };

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    try {
      // Ambil data guru (User Mapel) untuk dropdown
      final users = await context.read<UserService>().getMapelUsers();

      setState(() {
        _teachers = users;
        _isInitLoading = false;

        // Jika mode edit, set initial value
        if (widget.schedule != null) {
          _selectedDay = widget.schedule!.dayOfWeek;

          // Cari object User yang match dengan ID teacher di schedule
          try {
            _selectedTeacher = _teachers.firstWhere(
              (u) => u.id == widget.schedule!.teacher.id,
            );
          } catch (e) {
            // Jika user tidak ditemukan (mungkin sudah dihapus), biarkan null
          }
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isInitLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data guru: $e")));
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTeacher == null || _selectedDay == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Mohon lengkapi data")));
      return;
    }

    setState(() => _isLoading = true);
    final service = context.read<PiketScheduleService>();
    final isEdit = widget.schedule != null;

    try {
      if (isEdit) {
        await service.updateSchedule(
          id: widget.schedule!.id,
          teacherId: _selectedTeacher!.id,
          dayOfWeek: _selectedDay!,
        );
      } else {
        await service.createSchedule(
          teacherId: _selectedTeacher!.id,
          dayOfWeek: _selectedDay!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Jadwal berhasil disimpan"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali dengan success signal
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.schedule != null ? "Edit Jadwal Piket" : "Tambah Jadwal Piket",
        ),
      ),
      body: _isInitLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // 1. PILIH HARI
                    DropdownButtonFormField<int>(
                      initialValue: _selectedDay,
                      decoration: const InputDecoration(
                        labelText: "Hari",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      items: _days.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedDay = val),
                      validator: (val) => val == null ? 'Wajib dipilih' : null,
                    ),
                    const SizedBox(height: 16),

                    // 2. PILIH GURU (Searchable)
                    SearchableSelectionField<User>(
                      label: "Guru Piket",
                      icon: Icons.person_outline,
                      items: _teachers,
                      value: _selectedTeacher,
                      itemLabel: (u) => "${u.fullname} (${u.username})",
                      onChanged: (val) =>
                          setState(() => _selectedTeacher = val),
                    ),

                    const SizedBox(height: 32),

                    // BUTTON SIMPAN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("SIMPAN JADWAL"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
