import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

class UserFormScreen extends StatefulWidget {
  final User? user; // Null = Tambah, Not Null = Edit

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _nipController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _usernameController.text = widget.user!.username;
      _fullnameController.text = widget.user!.fullname;
      _nipController.text = widget.user!.nip ?? '';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _nipController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userService = context.read<UserService>();
    final isEditMode = widget.user != null;

    try {
      final Map<String, dynamic> userData = {
        "username": _usernameController.text,
        "fullname": _fullnameController.text,
        "nip": _nipController.text,
      };

      if (!isEditMode || _passwordController.text.isNotEmpty) {
        userData["password"] = _passwordController.text;
      }

      if (isEditMode) {
        await userService.updateUser(widget.user!.id, userData);
      } else {
        await userService.createUser(userData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data berhasil disimpan"), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
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
    final isEditMode = widget.user != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? "Edit Profil User" : "Tambah User Baru")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullnameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nipController,
                decoration: const InputDecoration(labelText: 'NIP (Opsional)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isEditMode ? 'Password (Opsional)' : 'Password',
                  helperText: isEditMode ? 'Isi hanya jika ingin mengubah password' : null,
                ),
                validator: (val) {
                  if (!isEditMode && (val == null || val.isEmpty)) {
                    return 'Password wajib untuk user baru';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN DATA"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}