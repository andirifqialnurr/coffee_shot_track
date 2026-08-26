import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/coffee_menu.dart';
import '../../shared/widgets/shot_ui.dart';

class MenusPage extends StatefulWidget {
  const MenusPage({super.key});

  @override
  State<MenusPage> createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> {
  String _query = '';
  String? _category;
  MenuStatus? _status;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final categories = store.menus
          .map((menu) => menu.category)
          .whereType<String>()
          .toSet()
          .toList()
        ..sort();
      final menus = store.menus.where(_matchesMenu).toList();

      return Scaffold(
        backgroundColor: colors.background,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Menus',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    ShotIconAction(
                      tooltip: 'Add Menu',
                      icon: Icons.add_rounded,
                      onPressed: () => showMenuFormSheet(context),
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
                    hintText: 'Cari menu...',
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
                      selected: _status == null && _category == null,
                      onTap: () => setState(() {
                        _status = null;
                        _category = null;
                      }),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      label: 'Active',
                      selected: _status == MenuStatus.active,
                      onTap: () =>
                          setState(() => _status = MenuStatus.active),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      label: 'Archived',
                      selected: _status == MenuStatus.archived,
                      onTap: () =>
                          setState(() => _status = MenuStatus.archived),
                    ),
                    for (final category in categories) ...[
                      const SizedBox(width: 8),
                      FilterPill(
                        label: category,
                        selected: _category == category,
                        onTap: () => setState(() {
                          _category = _category == category ? null : category;
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (store.menus.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.local_cafe_outlined,
                  title: 'Tidak ada menu',
                  subtitle: 'Tambahkan menu kopi pertama untuk mulai mencatat.',
                  ctaLabel: 'Add Menu',
                  onCta: () => showMenuFormSheet(context),
                ),
              )
            else if (menus.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'Tidak ada menu',
                  subtitle: 'Coba ubah pencarian atau filter menu.',
                  ctaLabel: 'Clear filter',
                  onCta: () => setState(() {
                    _query = '';
                    _category = null;
                    _status = null;
                  }),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList.separated(
                  itemCount: menus.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    return _MenuRow(
                      menu: menu,
                      onArchive: menu.status == MenuStatus.active
                          ? () => store.archiveMenu(menu)
                          : null,
                      onDelete: () => store.deleteMenuOrArchive(menu),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }

  bool _matchesMenu(CoffeeMenu menu) {
    final query = _query.trim().toLowerCase();
    final matchesQuery = query.isEmpty ||
        [
          menu.name,
          menu.category,
          menu.description,
          menu.notes,
        ].whereType<String>().any(
              (value) => value.toLowerCase().contains(query),
            );
    final matchesCategory = _category == null || menu.category == _category;
    final matchesStatus = _status == null || menu.status == _status;
    return matchesQuery && matchesCategory && matchesStatus;
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.menu,
    required this.onDelete,
    this.onArchive,
  });

  final CoffeeMenu menu;
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
            label: menu.name,
            icon: Icons.local_cafe_outlined,
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
                        menu.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _MenuStatusPill(menu.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  menu.category ?? 'Custom menu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if ((menu.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    menu.description!,
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

class _MenuStatusPill extends StatelessWidget {
  const _MenuStatusPill(this.status);

  final MenuStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    final active = status == MenuStatus.active;
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

Future<void> showMenuFormSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const MenuFormSheet(),
  );
}

class MenuFormSheet extends StatefulWidget {
  const MenuFormSheet({super.key});

  @override
  State<MenuFormSheet> createState() => _MenuFormSheetState();
}

class _MenuFormSheetState extends State<MenuFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  String _category = 'Espresso-based';

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
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
                Text('Add Menu', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 14),
                ShotImagePlaceholder(
                  label: 'Menu photo',
                  icon: Icons.local_cafe_outlined,
                  height: 82,
                  radius: 16,
                ),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Nama menu',
                  controller: _name,
                  hint: 'mis. Iced Americano',
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final category in [
                      'Espresso-based',
                      'Milk-based',
                      'Manual brew',
                      'Signature',
                      'Other',
                    ])
                      FilterPill(
                        label: category,
                        selected: _category == category,
                        onTap: () => setState(() => _category = category),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Description',
                  controller: _description,
                  hint: 'Short display description',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Menu notes',
                  controller: _notes,
                  hint: 'Personal notes about this menu',
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Simpan Menu',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    await store.addMenu(
                      name: _name.text,
                      category: _category,
                      description: _description.text,
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
