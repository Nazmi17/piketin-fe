import 'package:flutter/material.dart';
import 'package:piketin_fe/ui/screens/guru/guru_tugas_screen.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../admin/user_management_screen.dart';
import '../permit/permit_screen.dart';
// [BARU] Import screen approval
import '../permit/permit_approval_mapel_screen.dart';
import '../permit/permit_approval_piket_screen.dart';
import '../admin/subject_management_screen.dart';
import '../piket/piket_schedule_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    // --- LOGIKA PENGECEKAN ROLE ---
    // Pastikan string 'ADMIN', 'GURU', 'PIKET' sesuai dengan data di database kamu
    final bool isAdmin =
        user?.roles.any((r) => r.toUpperCase() == 'ADMIN') ?? false;
    final bool isGuru =
        user?.roles.any((r) => r.toUpperCase() == 'MAPEL') ?? false;
    final bool isPiket =
        user?.roles.any((r) => r.toUpperCase() == 'PIKET') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: "Keluar",
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Konfirmasi Keluar"),
                  content: const Text("Apakah Anda yakin ingin keluar?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("Batal"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthProvider>().logout();
                      },
                      child: const Text(
                        "Keluar",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER USER INFO ---
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullname ?? "Pengguna",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.nip ?? "Tanpa NIP",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Role: ${user?.roles.join(', ') ?? '-'}",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              "Menu Utama",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // --- GRID MENU ---
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                // 1. MENU UMUM: IZIN SISWA (Semua user bisa lihat list, tapi create dibatasi di dalamnya jika perlu)
                if (isPiket)
                  _MenuCard(
                    icon: Icons.assignment_ind_rounded,
                    label: "Izin Siswa",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PermitScreen()),
                      );
                    },
                  ),

                // 2. MENU KHUSUS ADMIN: MANAJEMEN USER
                if (isAdmin)
                  _MenuCard(
                    icon: Icons.manage_accounts_rounded,
                    label: "Manajemen User",
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserManagementScreen(),
                        ),
                      );
                    },
                  ),

                  if (isAdmin)
                  _MenuCard(
                    icon: Icons.menu_book_rounded,
                    label: "Mata Pelajaran",
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SubjectManagementScreen(),
                        ),
                      );
                    },
                  ),

                // 3. MENU KHUSUS GURU MAPEL: APPROVAL
                // Hanya muncul jika user punya role 'GURU'
                if (isGuru)
                  _MenuCard(
                    icon: Icons.approval_rounded,
                    label: "Persetujuan Izin",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PermitApprovalMapelScreen(),
                        ),
                      );
                    },
                  ),

                if (isGuru)
                  _MenuCard(
                    icon: Icons.task,
                    label: "Tugas Guru",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GuruTugasScreen(),
                        ),
                      );
                    },
                  ),

                // 4. MENU KHUSUS GURU PIKET: VALIDASI
                // Hanya muncul jika user punya role 'PIKET'
                if (isPiket)
                  _MenuCard(
                    icon: Icons.verified_user_rounded,
                    label: "Validasi Izin",
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PermitApprovalPiketScreen(),
                        ),
                      );
                    },
                  ),

                // 5. MENU UMUM LAINNYA
                if (isAdmin)
                _MenuCard(
                  icon: Icons.calendar_month_rounded,
                  label: "Jadwal Piket",
                  color: Colors.green,
                  onTap: () {
                    // [UBAH BAGIAN INI]
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PiketScheduleScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.grey.withOpacity(0.2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
