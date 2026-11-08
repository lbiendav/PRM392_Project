import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/branch_model.dart';
import '../../providers/catalog_provider.dart';
import '../../viewmodels/catalog_view_model.dart';

class StoreBranchScreen extends ConsumerStatefulWidget {
  const StoreBranchScreen({super.key});

  @override
  ConsumerState<StoreBranchScreen> createState() => _StoreBranchScreenState();
}

class _StoreBranchScreenState extends ConsumerState<StoreBranchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final branches = ref.watch(visibleBranchesProvider);
    final selection = ref.watch(selectedBranchProvider);
    final now = ref.watch(catalogClockProvider).value ?? DateTime.now();
    final filter = ref.watch(branchViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn cửa hàng')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: TextField(
              key: const Key('branch-search-field'),
              controller: _controller,
              onChanged: ref.read(branchViewModelProvider.notifier).setQuery,
              decoration: const InputDecoration(
                hintText: 'Tìm cửa hàng, quận...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SwitchListTile(
            key: const Key('open-branches-filter'),
            title: const Text('Chỉ cửa hàng đang mở'),
            value: filter.openOnly,
            onChanged: ref.read(branchViewModelProvider.notifier).setOpenOnly,
          ),
          Expanded(
            child: branches.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Không tải được cửa hàng'),
                    TextButton(
                      onPressed: () => ref.invalidate(branchListProvider),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (items) => items.isEmpty
                  ? const Center(child: Text('Không tìm thấy cửa hàng'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (_, index) => _BranchTile(
                        branch: items[index],
                        now: now,
                        selectedId: selection.asData?.value?.id,
                        onSelect: () async {
                          final selected = await ref
                              .read(branchViewModelProvider.notifier)
                              .select(items[index], now);
                          if (!context.mounted) return;
                          if (selected) {
                            Navigator.pop(context, true);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cửa hàng hiện đang đóng'),
                              ),
                            );
                          }
                        },
                        onCall: items[index].phone.isEmpty
                            ? null
                            : () async {
                                final opened = await ref
                                    .read(branchViewModelProvider.notifier)
                                    .callStore(items[index].phone);
                                if (!opened && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Không gọi được cửa hàng'),
                                    ),
                                  );
                                }
                              },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchTile extends StatelessWidget {
  final BranchModel branch;
  final DateTime now;
  final String? selectedId;
  final VoidCallback onSelect;
  final VoidCallback? onCall;
  const _BranchTile({
    required this.branch,
    required this.now,
    required this.selectedId,
    required this.onSelect,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = branch.isOpenAt(now);
    return Card(
      child: ListTile(
        key: ValueKey('branch-${branch.id}'),
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          branch.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(branch.address),
              const SizedBox(height: 4),
              Text('${branch.hours} · ${isOpen ? 'Đang mở' : 'Đã đóng'}'),
              if (branch.phone.isNotEmpty) Text(branch.phone),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (onCall != null)
                    TextButton.icon(
                      onPressed: onCall,
                      icon: const Icon(Icons.call_outlined),
                      label: const Text('Gọi'),
                    ),
                  TextButton(
                    onPressed: isOpen ? onSelect : null,
                    child: Text(
                      selectedId == branch.id ? 'Đã chọn' : 'Chọn cửa hàng',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: selectedId == branch.id
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.storefront_outlined),
      ),
    );
  }
}
