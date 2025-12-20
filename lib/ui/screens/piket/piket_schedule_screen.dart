import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart'; // Untuk grouping (groupBy)
import '../../../models/piket_schedule_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/piket_schedule_service.dart';
import 'piket_schedule_form_screen.dart';

class PiketScheduleScreen extends StatefulWidget {
  const PiketScheduleScreen({super.key});

  @override
  State<PiketScheduleScreen> createState() => _PiketScheduleScreenState();
}

class _PiketScheduleScreenState extends State<PiketScheduleScreen> {
  late Future<List<PiketSchedule>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _schedulesFuture = context.read<PiketScheduleService>().getSchedules();
    });
  }

  Future<void> _deleteSchedule(PiketSchedule item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Jadwal?"),
        content: Text(
          "Hapus ${item.teacher.fullname} dari hari ${item.dayName}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<PiketScheduleService>().deleteSchedule(item.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Jadwal dihapus")));
        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek Role: Hanya ADMIN yang boleh Add/Edit/Delete
    final user = context.watch<AuthProvider>().user;
    final isAdmin = user?.roles.any((r) => r.toUpperCase() == 'ADMIN') ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text("Jadwal Piket Guru")),
      body: FutureBuilder<List<PiketSchedule>>(
        future: _schedulesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("Belum ada jadwal piket."));
          }

          // Grouping berdasarkan dayOfWeek agar tampilan rapi
          // Menggunakan package:collection atau manual
          final grouped = groupBy(list, (obj) => obj.dayOfWeek);
          // Sort keys (0=Minggu, 1=Senin...)
          final sortedKeys = grouped.keys.toList()..sort();

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedKeys.length,
              itemBuilder: (context, index) {
                final dayKey = sortedKeys[index];
                final schedulesOfDay = grouped[dayKey]!;
                final dayName = schedulesOfDay
                    .first
                    .dayName; // Ambil nama hari dari item pertama

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Hari
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4,
                      ),
                      child: Text(
                        dayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    // List Guru di Hari Tersebut
                    ...schedulesOfDay.map(
                      (schedule) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Text(
                              schedule.teacher.fullname[0],
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          title: Text(schedule.teacher.fullname),
                          subtitle: Text(
                            "Username: ${schedule.teacher.username}",
                          ),
                          trailing: isAdmin
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () async {
                                        final refresh = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PiketScheduleFormScreen(
                                                  schedule: schedule,
                                                ),
                                          ),
                                        );
                                        if (refresh == true) _refresh();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          _deleteSchedule(schedule),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final refresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PiketScheduleFormScreen(),
                  ),
                );
                if (refresh == true) _refresh();
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
