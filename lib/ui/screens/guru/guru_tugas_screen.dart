import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/teacher_assignment_model.dart';
import '../../../services/teacher_assignment_service.dart';
import 'guru_tugas_form_screen.dart';

class GuruTugasScreen extends StatefulWidget {
  const GuruTugasScreen({super.key});

  @override
  State<GuruTugasScreen> createState() => _GuruTugasScreenState();
}

class _GuruTugasScreenState extends State<GuruTugasScreen> {
  late Future<List<TeacherAssignment>> _tugasFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshTugas();
  }

  void _refreshTugas() {
    setState(() {
      _tugasFuture = context.read<TeacherAssignmentService>().getAssignments();
    });
  }

  Color _getStatusColor(DateTime? dueDate) {
    if (dueDate == null) return Colors.grey;
    final now = DateTime.now();
    if (now.isAfter(dueDate)) return Colors.red;
    if (now.add(const Duration(days: 3)).isAfter(dueDate)) return Colors.orange;
    return Colors.green;
  }

  String _getStatusText(DateTime? dueDate) {
    if (dueDate == null) return 'TANPA BATAS';
    final now = DateTime.now();
    if (now.isAfter(dueDate)) return 'TERLAMBAT';
    if (now.add(const Duration(days: 3)).isAfter(dueDate)) return 'SEGERA';
    return 'AKTIF';
  }

  void _navigateToForm(TeacherAssignment? assignment) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GuruTugasFormScreen(assignment: assignment),
      ),
    );
    if (result == true) {
      _refreshTugas();
    }
  }

  Future<void> _confirmDelete(int taskId) async {
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
      try {
        await context.read<TeacherAssignmentService>().deleteAssignment(taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tugas berhasil dihapus')),
          );
          _refreshTugas();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Tugas Guru"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTugas,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToForm(null),
            tooltip: 'Tambah Tugas Baru',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari tugas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                _refreshTugas();
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<TeacherAssignment>>(
              future: _tugasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final tugasList = snapshot.data ?? [];
                if (tugasList.isEmpty) {
                  return const Center(child: Text('Tidak ada tugas tersedia'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: tugasList.length,
                  itemBuilder: (context, index) {
                    final tugas = tugasList[index];
                    final statusColor = _getStatusColor(tugas.dueDate);
                    final statusText = _getStatusText(tugas.dueDate);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with status
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tugas.subject.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Kelas: ${tugas.classInfo.className}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            // Assignment details
                            const SizedBox(height: 12),
                            Text(
                              tugas.assignmentDetails,
                              style: const TextStyle(fontSize: 14),
                            ),
                            
                            // Due date and actions
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Batas: ${tugas.dueDate?.toLocal().toString().substring(0, 16) ?? 'Tidak ada batas'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _navigateToForm(tugas),
                                      color: Colors.blue,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20),
                                      onPressed: () => _confirmDelete(tugas.id),
                                      color: Colors.red,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}