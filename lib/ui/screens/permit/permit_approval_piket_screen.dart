import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/student_permit_model.dart';
import '../../../services/permit_service.dart';

class PermitApprovalPiketScreen extends StatefulWidget {
  const PermitApprovalPiketScreen({super.key});

  @override
  State<PermitApprovalPiketScreen> createState() =>
      _PermitApprovalPiketScreenState();
}

class _PermitApprovalPiketScreenState extends State<PermitApprovalPiketScreen> {
  late Future<List<StudentPermit>> _pendingFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      // [PERBEDAAN 1] Mengambil data Pending Piket
      _pendingFuture = context.read<PermitService>().getPendingPiket();
    });
  }

  Future<void> _processPermit(int id, bool isApproved) async {
    try {
      // [PERBEDAAN 2] Status menjadi APPROVED jika disetujui
      final status = isApproved ? 'APPROVED' : 'REJECTED';

      await context.read<PermitService>().processPermit(
        id: id,
        actionType: 'piket', // Menandakan ini approval dari Guru Piket
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApproved ? "Izin disetujui (Final)" : "Izin ditolak",
            ),
            backgroundColor: isApproved ? Colors.green : Colors.red,
          ),
        );
        _refresh(); // Reload list
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
      appBar: AppBar(title: const Text("Validasi Guru Piket")),
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
                    Icons.verified_user_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Tidak ada izin yang perlu divalidasi.",
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
                          Expanded(
                            child: Text(
                              permit.student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              permit.student.className ?? "-",
                              style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Body: Alasan & Guru Mapel
                      Text(
                        "Alasan: ${permit.reason}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      // Menampilkan info bahwa Guru Mapel sudah setuju
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Disetujui oleh: ${permit.mapel.fullname}",
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                            label: const Text("Izinkan Keluar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
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
