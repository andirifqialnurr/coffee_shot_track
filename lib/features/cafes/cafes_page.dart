import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/cafe.dart';
import '../../shared/widgets/shot_ui.dart';

class CafesPage extends StatefulWidget {
  const CafesPage({super.key});

  @override
  State<CafesPage> createState() => _CafesPageState();
}

class _CafesPageState extends State<CafesPage> {
  String _query = '';
  CafeStatus? _status;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final cafes = store.cafes.where(_matchesCafe).toList();

      return Scaffold(
        backgroundColor: colors.background,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    if (Navigator.of(context).canPop()) ...[
                      ShotIconAction(
                        tooltip: 'Back',
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        'Cafes',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    ShotIconAction(
                      tooltip: 'Add Cafe',
                      icon: Icons.add_rounded,
                      onPressed: () => showCafeFormSheet(context),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: const InputDecoration(
                    hintText: 'Cari cafe...',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 58,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  children: [
                    FilterPill(
                      label: 'Semua',
                      selected: _status == null,
                      onTap: () => setState(() => _status = null),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      label: 'Active',
                      selected: _status == CafeStatus.active,
                      onTap: () =>
                          setState(() => _status = CafeStatus.active),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      label: 'Archived',
                      selected: _status == CafeStatus.archived,
                      onTap: () =>
                          setState(() => _status = CafeStatus.archived),
                    ),
                  ],
                ),
              ),
            ),
            if (store.cafes.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.storefront_outlined,
                  title: 'Tidak ada cafe',
                  subtitle: 'Tambahkan cafe atau gunakan default Home.',
                  ctaLabel: 'Add Cafe',
                  onCta: () => showCafeFormSheet(context),
                ),
              )
            else if (cafes.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'Tidak ada cafe',
                  subtitle: 'Coba ubah pencarian atau filter cafe.',
                  ctaLabel: 'Clear filter',
                  onCta: () => setState(() {
                    _query = '';
                    _status = null;
                  }),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList.separated(
                  itemCount: cafes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cafe = cafes[index];
                    return _CafeRow(
                      cafe: cafe,
                      onArchive: cafe.status == CafeStatus.active
                          ? () => store.archiveCafe(cafe)
                          : null,
                      onDelete: () => store.deleteCafeOrArchive(cafe),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }

  bool _matchesCafe(Cafe cafe) {
    final query = _query.trim().toLowerCase();
    final matchesQuery = query.isEmpty ||
        [
          cafe.name,
          cafe.area,
          cafe.address,
          cafe.notes,
        ].whereType<String>().any(
              (value) => value.toLowerCase().contains(query),
            );
    final matchesStatus = _status == null || cafe.status == _status;
    return matchesQuery && matchesStatus;
  }
}

class _CafeRow extends StatelessWidget {
  const _CafeRow({
    required this.cafe,
    required this.onDelete,
    this.onArchive,
  });

  final Cafe cafe;
  final VoidCallback? onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return ShotCard(
      padding: const EdgeInsets.all(12),
      radius: 16,
      child: Row(
        children: [
          ShotImagePlaceholder(
            label: cafe.name,
            icon: Icons.storefront_outlined,
            width: 62,
            height: 62,
            radius: 13,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        cafe.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _CafeStatusPill(cafe.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cafe.area ?? 'Coffee place',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if ((cafe.address ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    cafe.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary),
            onSelected: (value) {
              if (value == 'archive') {
                onArchive?.call();
              }
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (_) => [
              if (onArchive != null)
                const PopupMenuItem(
                  value: 'archive',
                  child: Text('Archive'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CafeStatusPill extends StatelessWidget {
  const _CafeStatusPill(this.status);

  final CafeStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final active = status == CafeStatus.active;
    final color = active ? colors.success : colors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        active ? 'Active' : 'Archived',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

Future<void> showCafeFormSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CafeFormSheet(),
  );
}

class CafeFormSheet extends StatefulWidget {
  const CafeFormSheet({super.key});

  @override
  State<CafeFormSheet> createState() => _CafeFormSheetState();
}

class _CafeFormSheetState extends State<CafeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _address = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final store = Get.find<ShotController>();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Add Cafe', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                ShotImagePlaceholder(
                  label: 'Cafe photo',
                  icon: Icons.storefront_outlined,
                  height: 82,
                  radius: 16,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Nama cafe',
                  controller: _name,
                  hint: 'mis. Kawan Kopi',
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Area',
                  controller: _area,
                  hint: 'mis. Bandung',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Address',
                  controller: _address,
                  hint: 'Optional address',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Cafe notes',
                  controller: _notes,
                  hint: 'Personal notes about this cafe',
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Simpan Cafe',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    await store.addCafe(
                      name: _name.text,
                      area: _area.text,
                      address: _address.text,
                      notes: _notes.text,
                    );
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
