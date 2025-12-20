import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/subject_model.dart';
import '../../../services/subject_service.dart';
import 'subject_form_screen.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Subject> _subjects = [];

  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  final int _limit = 15; // Limit per page

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMoreData) {
        _fetchSubjects();
      }
    });
  }

  Future<void> _fetchSubjects() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final newItems = await context.read<SubjectService>().getSubjects(
        page: _currentPage,
        limit: _limit,
      );

      setState(() {
        _currentPage++;
        _subjects.addAll(newItems);
        if (newItems.length < _limit) _hasMoreData = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _subjects.clear();
      _currentPage = 1;
      _hasMoreData = true;
    });
    await _fetchSubjects();
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Mapel?"),
        content: Text("Yakin ingin menghapus ${subject.name}?"),
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
        await context.read<SubjectService>().deleteSubject(subject.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
        _refresh();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Mata Pelajaran")),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _subjects.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                controller: _scrollController,
                itemCount: _subjects.length + (_hasMoreData ? 1 : 0),
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  if (index == _subjects.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final subject = _subjects[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.book, color: Colors.blue),
                      ),
                      title: Text(subject.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final bool? success = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SubjectFormScreen(subject: subject),
                                ),
                              );
                              if (success == true) _refresh();
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSubject(subject),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final bool? success = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SubjectFormScreen()),
          );
          if (success == true) _refresh();
        },
      ),
    );
  }
}
