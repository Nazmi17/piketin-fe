import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/student_permit_model.dart';
import '../../../services/permit_service.dart';

class PermitApprovalMapelScreen extends StatefulWidget {
  const PermitApprovalMapelScreen({super.key});

  @override
  State<PermitApprovalMapelScreen> createState() =>
      _PermitApprovalMapelScreenState();
}

class _PermitApprovalMapelScreenState extends State<PermitApprovalMapelScreen> {
  late Future<List<StudentPermit>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _pendingFuture = context.read<PermitService>().getPendingMapel();
    });
  }

  Future<void> _processPermit(int id, bool isApproved) async {
    try {
      // Jika setuju, lempar ke Guru Piket (PENDING_PIKET)
      // Jika tolak, langsung REJECTED
      final status = isApproved ? 'PENDING_PIKET' : 'REJECTED';

      await context.read<PermitService>().processPermit(
        id: id,
        actionType: 'mapel', // Menandakan ini approval dari Guru Mapel
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isApproved ? "Izin disetujui" : "Izin ditolak"),
            backgroundColor: isApproved ? Colors.green : Colors.red,
          ),
        );
        _refresh(); // Reload list setelah aksi
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Persetujuan Guru Mapel")),
      body: FutureBuilder<List<StudentPermit>>(
        future: _pendingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final permits = snapshot.data ?? [];

          if (permits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.assignment_turned_in,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tidak ada izin yang perlu diproses.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: permits.length,
            itemBuilder: (context, index) {
              final permit = permits[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Nama Siswa & Kelas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // [FIX] Menggunakan Expanded agar teks tidak menabrak batas kanan
                          Expanded(
                            child: Text(
                              permit.student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow
                                  .ellipsis, // Potong jika kepanjangan
                              maxLines: 1, // Batasi 1 baris
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Badge Kelas
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              permit.student.className ?? "-",
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Body: Alasan & Waktu
                      Text(
                        "Alasan: ${permit.reason}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Waktu: Jam ke-${permit.hoursStart}${permit.hoursEnd != null
                                ? " s/d ${permit.hoursEnd}"
                                : ""}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const Divider(height: 24),

                      // Footer: Tombol Aksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _processPermit(permit.id, false),
                            icon: const Icon(Icons.close, color: Colors.red),
                            label: const Text(
                              "Tolak",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => _processPermit(permit.id, true),
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text("Setuju"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
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
    );
  }
}
