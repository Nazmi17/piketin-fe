import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../models/role_model.dart';
import '../../../services/user_service.dart';

class ManageRolesScreen extends StatefulWidget {
  final User user;

  const ManageRolesScreen({super.key, required this.user});

  @override
  State<ManageRolesScreen> createState() => _ManageRolesScreenState();
}

class _ManageRolesScreenState extends State<ManageRolesScreen> {
  List<Role> _masterRoles = [];
  List<Role> _userRoles = [];
  bool _isLoading = true;
  Role? _selectedRoleToAdd;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userService = context.read<UserService>();
    try {
      // Load Master Roles & User Roles secara paralel
      final results = await Future.wait([
        userService.getMasterRoles(),
        userService.getUserRoles(widget.user.id),
      ]);

      setState(() {
        _masterRoles = results[0];
        _userRoles = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal memuat data role")));
      }
    }
  }

  Future<void> _addRole() async {
    if (_selectedRoleToAdd == null) return;

    try {
      await context.read<UserService>().addUserRole(
        widget.user.id,
        _selectedRoleToAdd!.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Role berhasil ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
      _loadData(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteRole(int roleId) async {
    try {
      await context.read<UserService>().removeUserRole(widget.user.id, roleId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Role dihapus"),
          backgroundColor: Colors.orange,
        ),
      );
      _loadData(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter master roles agar yang sudah dimiliki user tidak muncul di dropdown
    final availableRoles = _masterRoles.where((master) {
      return !_userRoles.any((userRole) => userRole.id == master.id);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Role: ${widget.user.username}")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Role Saat Ini",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),

                  // LIST ROLE USER
                  _userRoles.isEmpty
                      ? const Text(
                          "User ini belum memiliki role.",
                          style: TextStyle(color: Colors.grey),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _userRoles.map((role) {
                            return Chip(
                              label: Text(role.name.toUpperCase()),
                              backgroundColor: Colors.blue.shade100,
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _deleteRole(role.id),
                            );
                          }).toList(),
                        ),

                  const Divider(height: 40),

                  // FORM TAMBAH ROLE
                  const Text(
                    "Tambah Role Baru",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Role>(
                          initialValue: null, // Selalu reset setelah add
                          hint: const Text("Pilih Role"),
                          items: availableRoles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() => _selectedRoleToAdd = val);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _selectedRoleToAdd == null ? null : _addRole,
                        child: const Text("Tambah"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
