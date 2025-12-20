import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/subject_model.dart';
import '../../../services/subject_service.dart';

class SubjectFormScreen extends StatefulWidget {
  final Subject? subject; // Jika null = Add, jika ada = Edit

  const SubjectFormScreen({super.key, this.subject});

  @override
  State<SubjectFormScreen> createState() => _SubjectFormScreenState();
}

class _SubjectFormScreenState extends State<SubjectFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.subject != null) {
      _nameController.text = widget.subject!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final service = context.read<SubjectService>();
    final isEdit = widget.subject != null;

    try {
      if (isEdit) {
        await service.updateSubject(widget.subject!.id, _nameController.text);
      } else {
        await service.createSubject(_nameController.text);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data berhasil disimpan"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembali & trigger refresh
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
        title: Text(widget.subject != null ? "Edit Mapel" : "Tambah Mapel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Pelajaran',
                  hintText: 'Contoh: Matematika, Bahasa Indonesia',
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SIMPAN"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
