import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/coffee_bean.dart';
import '../../shared/widgets/shot_ui.dart';
import '../shots/shot_detail_page.dart';
import '../shots/shot_form_page.dart';

class BeansPage extends StatefulWidget {
  const BeansPage({super.key});

  @override
  State<BeansPage> createState() => _BeansPageState();
}

class _BeansPageState extends State<BeansPage> {
  String _query = '';
  BeanStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final beans = store.beans.where((bean) {
        final query = _query.trim().toLowerCase();
        final matchesQuery = query.isEmpty ||
            [
              bean.name,
              bean.roaster,
              bean.origin,
              bean.process,
              bean.roastLevel,
            ].whereType<String>().any(
                  (value) => value.toLowerCase().contains(query),
                );
        final matchesFilter = _filter == null || bean.status == _filter;
        return matchesQuery && matchesFilter;
      }).toList();

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
                        'Beans',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    ShotIconAction(
                      tooltip: 'Add Bean',
                      icon: Icons.add_rounded,
                      onPressed: () => showBeanFormSheet(context),
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
                    hintText: 'Cari beans...',
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
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      label: 'Active',
                      selected: _filter == BeanStatus.active,
                      onTap: () => setState(() => _filter = BeanStatus.active),
                    ),
                    const SizedBox(width: 8),
                    FilterPill(
                      label: 'Finished',
                      selected: _filter == BeanStatus.finished,
                      onTap: () =>
                          setState(() => _filter = BeanStatus.finished),
                    ),
                  ],
                ),
              ),
            ),
            if (store.beans.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.eco_outlined,
                  title: 'Tidak ada beans',
                  subtitle: 'Tambahkan beans pertama untuk mulai mencatat.',
                  ctaLabel: 'Add Bean',
                  onCta: () => showBeanFormSheet(context),
                ),
              )
            else if (beans.isEmpty)
              SliverToBoxAdapter(
                child: EmptyState(
                  icon: Icons.filter_alt_off_outlined,
                  title: 'Tidak ada beans',
                  subtitle:
                      'Coba ubah pencarian atau filter, atau tambah beans baru.',
                  ctaLabel: 'Clear filter',
                  onCta: () => setState(() {
                    _query = '';
                    _filter = null;
                  }),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList.separated(
                  itemCount: beans.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final bean = beans[index];
                    final shotCount = bean.id == null
                        ? 0
                        : store.shotsForBean(bean.id!).length;
                    return _BeanRow(
                      bean: bean,
                      shotCount: shotCount,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BeanDetailPage(beanId: bean.id!),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _BeanRow extends StatelessWidget {
  const _BeanRow({
    required this.bean,
    required this.shotCount,
    required this.onTap,
  });

  final CoffeeBean bean;
  final int shotCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.eco_rounded, color: colors.primary),
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
                          bean.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                      const SizedBox(width: 6),
                      StatusPill(bean.status),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      bean.roaster,
                      bean.roastLevel,
                    ].whereType<String>().join(' * '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Roasted ${formatHumanDate(bean.roastDate)} * $shotCount shots',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}

Future<void> showBeanFormSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const BeanFormSheet(),
  );
}

class BeanFormSheet extends StatefulWidget {
  const BeanFormSheet({super.key});

  @override
  State<BeanFormSheet> createState() => _BeanFormSheetState();
}

class _BeanFormSheetState extends State<BeanFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _roaster = TextEditingController();
  final _origin = TextEditingController();
  final _process = TextEditingController();
  final _notes = TextEditingController();
  String _roastLevel = 'Medium';

  @override
  void dispose() {
    _name.dispose();
    _roaster.dispose();
    _origin.dispose();
    _process.dispose();
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
                Text('Add Bean', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                LabeledTextField(
                  label: 'Nama beans',
                  controller: _name,
                  hint: 'mis. Sunrise Gesha',
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Roaster',
                  controller: _roaster,
                  hint: 'mis. Kawan Kopi',
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: LabeledTextField(
                        label: 'Origin',
                        controller: _origin,
                        hint: 'mis. Panama',
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LabeledTextField(
                        label: 'Process',
                        controller: _process,
                        hint: 'Washed',
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Roast level',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final level in [
                      'Light',
                      'Light-Medium',
                      'Medium',
                      'Medium-Dark',
                      'Dark',
                    ])
                      FilterPill(
                        label: level,
                        selected: _roastLevel == level,
                        onTap: () => setState(() => _roastLevel = level),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                LabeledTextField(
                  label: 'Bean notes',
                  controller: _notes,
                  hint: 'Tasting expectation, recipe target, or notes',
                  minLines: 2,
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Simpan Beans',
                  icon: Icons.check_rounded,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    await store.addBean(
                      name: _name.text,
                      roaster: _roaster.text,
                      origin: _origin.text,
                      process: _process.text,
                      roastLevel: _roastLevel,
                      roastDate: DateTime.now(),
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

class BeanDetailPage extends StatelessWidget {
  const BeanDetailPage({super.key, required this.beanId});

  final int beanId;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final bean = store.beanById(beanId);
      if (bean == null) {
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(title: const Text('Bean')),
          body: const EmptyState(
            icon: Icons.delete_outline_rounded,
            title: 'Bean tidak ditemukan',
            subtitle: 'Data bean ini tidak lagi tersedia.',
          ),
        );
      }

      final shots = store.shotsForBean(beanId);
      final bestShot = store.bestShotForBean(beanId);

      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(bean.name),
          actions: [
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: colors.textPrimary),
              onSelected: (value) async {
                if (value == 'archive') {
                  await store.markBeanFinished(bean);
                }
                if (value == 'delete') {
                  await store.deleteBeanOrArchive(bean);
                  if (context.mounted && store.beanById(beanId) == null) {
                    Navigator.of(context).pop();
                  }
                }
              },
              itemBuilder: (_) => [
                if (bean.status == BeanStatus.active)
                  const PopupMenuItem(
                    value: 'archive',
                    child: Text('Mark as finished'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Archive or delete'),
                ),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
          children: [
            ShotCard(
              radius: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          bean.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      StatusPill(bean.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (bean.roaster != null) UnitChip(bean.roaster!),
                      if (bean.origin != null) UnitChip(bean.origin!),
                      if (bean.process != null) UnitChip(bean.process!),
                      if (bean.roastLevel != null) UnitChip(bean.roastLevel!),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Roast date: ${formatHumanDate(bean.roastDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if ((bean.notes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(bean.notes!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            const SectionLabel('Best Shot'),
            if (bestShot == null)
              ShotCard(
                surfaceAlt: true,
                child: Text(
                  'Belum ada shot dengan rating untuk beans ini.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ShotDetailPage(shotId: bestShot.id!),
                  ),
                ),
                child: RecipeCard(shot: bestShot),
              ),
            SectionLabel('Shot History (${shots.length})'),
            if (shots.isEmpty)
              Text(
                'Belum ada riwayat shot.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final shot in shots)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ShotRow(
                    shot: shot,
                    beanName: bean.name,
                    showBeanName: false,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ShotDetailPage(shotId: shot.id!),
                      ),
                    ),
                  ),
                ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: PrimaryButton(
              label: 'New Shot untuk ${bean.name}',
              icon: Icons.add_rounded,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ShotFormPage(initialBeanId: bean.id),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
