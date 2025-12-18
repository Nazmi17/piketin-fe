import 'package:flutter/material.dart';

class SearchableSelectionField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel; // Fungsi untuk ambil teks dari object T
  final void Function(T) onChanged;
  final IconData? icon;

  const SearchableSelectionField({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final T? result = await showModalBottomSheet<T>(
          context: context,
          isScrollControlled: true, // Agar bisa full screen/tinggi
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => _SearchableBottomSheet<T>(
            items: items,
            itemLabel: itemLabel,
            label: label,
          ),
        );

        if (result != null) {
          onChanged(result);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon) : null,
          suffixIcon: const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          value != null ? itemLabel(value as T) : "Pilih $label",
          style: TextStyle(
            color: value != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

// --- Internal Widget untuk Bottom Sheet Pencarian ---
class _SearchableBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final String label;

  const _SearchableBottomSheet({
    required this.items,
    required this.itemLabel,
    required this.label,
  });

  @override
  State<_SearchableBottomSheet<T>> createState() =>
      _SearchableBottomSheetState<T>();
}

class _SearchableBottomSheetState<T> extends State<_SearchableBottomSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterList(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final label = widget.itemLabel(item).toLowerCase();
          return label.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mengatur tinggi sheet agar 80% layar
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            // Handle Bar (Garis kecil di atas)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true, // Keyboard langsung muncul
                decoration: InputDecoration(
                  hintText: "Cari ${widget.label}...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                ),
                onChanged: _filterList,
              ),
            ),

            // List Items
            Expanded(
              child: _filteredItems.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ditemukan '${_searchController.text}'",
                      ),
                    )
                  : ListView.separated(
                      controller: controller, // Penting agar scroll menyatu
                      itemCount: _filteredItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          title: Text(widget.itemLabel(item)),
                          onTap: () {
                            Navigator.pop(
                              context,
                              item,
                            ); // Kembali membawa data
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
