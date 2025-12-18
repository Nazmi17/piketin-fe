import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/student_permit_model.dart';
import '../../../services/permit_service.dart';
import 'permit_form_screen.dart';

class PermitScreen extends StatefulWidget {
  const PermitScreen({super.key});

  @override
  State<PermitScreen> createState() => _PermitScreenState();
}

class _PermitScreenState extends State<PermitScreen> {
  late Future<List<StudentPermit>> _permitsFuture;

  @override
  void initState() {
    super.initState();
    _refreshPermits();
  }

  void _refreshPermits() {
    setState(() {
      _permitsFuture = context.read<PermitService>().getPermits();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
      case 'CANCELED':
        return Colors.red;
      case 'PENDING_MAPEL':
      case 'PENDING_PIKET':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Helper untuk memformat status agar lebih enak dibaca (misal: PENDING_MAPEL -> PENDING MAPEL)
  String _formatStatus(String status) {
    return status.replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Izin Siswa")),
      body: FutureBuilder<List<StudentPermit>>(
        future: _permitsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Gagal memuat: ${snapshot.error}"));
          }

          final permits = snapshot.data ?? [];
          if (permits.isEmpty) {
            return const Center(child: Text("Tidak ada data izin."));
          }

          return ListView.builder(
            itemCount: permits.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final permit = permits[index];

              // [FIX] Mengakses data sesuai Model yang benar
              final studentName = permit.student.name;
              final className = permit.student.className ?? '-';

              // Format Jam: "Jam ke-1" atau "Jam ke-1 s/d 3"
              final String hoursText = permit.hoursEnd != null
                  ? "Jam ke-${permit.hoursStart} s/d ${permit.hoursEnd}"
                  : "Jam ke-${permit.hoursStart}";

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris 1: Nama Siswa & Badge Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  studentName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Kelas: $className", // Tampilkan Kelas
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                permit.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(permit.status),
                              ),
                            ),
                            child: Text(
                              _formatStatus(permit.status),
                              style: TextStyle(
                                color: _getStatusColor(permit.status),
                                fontSize: 10, // Font lebih kecil agar muat
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Baris 2: Alasan
                      Text("Alasan: ${permit.reason}"),

                      const SizedBox(height: 8),
                      const Divider(),

                      // Baris 3: Info Waktu & Guru
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                hoursText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Guru: ${permit.mapel.fullname}", // Tampilkan Guru Mapel
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Navigasi ke Form dan tunggu hasilnya
          final bool? shouldRefresh = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PermitFormScreen()),
          );

          // Jika sukses membuat izin (shouldRefresh == true), refresh list
          if (shouldRefresh == true) {
            _refreshPermits();
          }
        },
      ),
    );
  }
}
