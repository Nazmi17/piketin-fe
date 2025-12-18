import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import 'user_form_screen.dart';
import 'manage_roles_screen.dart'; // Pastikan file ini sudah ada

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<User> _users = [];

  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMoreData) {
        _fetchUsers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final newUsers = await context.read<UserService>().getUsers(
        page: _currentPage,
        limit: _limit,
      );

      setState(() {
        _currentPage++;
        _users.addAll(newUsers);
        if (newUsers.length < _limit) _hasMoreData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _users.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
    await _fetchUsers();
  }

  // --- LOGIKA DELETE ---
  Future<void> _confirmDelete(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus User?"),
        content: Text("Apakah Anda yakin ingin menghapus ${user.fullname}?"),
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

    if (confirmed == true && mounted) {
      try {
        await context.read<UserService>().deleteUser(user.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User berhasil dihapus")));
        _refresh(); // Refresh list setelah hapus
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal hapus: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- LOGIKA NAVIGASI KE FORM (ADD/EDIT) ---
  Future<void> _navigateToForm({User? user}) async {
    final bool? isSuccess = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
    );

    // Jika kembali membawa nilai true (sukses simpan), refresh list
    if (isSuccess == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen User")),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _users.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _users.length + (_hasMoreData ? 1 : 0),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  if (index == _users.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final user = _users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          user.username.isNotEmpty
                              ? user.username[0].toUpperCase()
                              : "?",
                        ),
                      ),
                      title: Text(user.fullname),
                      // Menampilkan role user sebagai subtitle
                      subtitle: Text(user.roles.join(', ')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // [BARU] Tombol Manage Role
                          IconButton(
                            icon: const Icon(
                              Icons.person_add_alt_1_outlined,
                              color: Colors.blue,
                            ),
                            tooltip: "Atur Role",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManageRolesScreen(user: user),
                                ),
                              ).then((_) {
                                // Refresh saat kembali agar tampilan role di list update
                                _refresh();
                              });
                            },
                          ),

                          // Tombol Edit Profil
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: "Edit Profil",
                            onPressed: () => _navigateToForm(user: user),
                          ),

                          // Tombol Delete User
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: "Hapus User",
                            onPressed: () => _confirmDelete(user),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      // Tombol Tambah User (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(), // Tanpa parameter = Add Mode
        child: const Icon(Icons.add),
      ),
    );
  }
}
