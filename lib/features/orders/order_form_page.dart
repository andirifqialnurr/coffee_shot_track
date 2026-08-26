import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../domain/cafe.dart';
import '../../domain/coffee_bean.dart';
import '../../domain/coffee_menu.dart';
import '../../domain/coffee_order.dart';
import '../../shared/widgets/shot_ui.dart';
import '../cafes/cafes_page.dart';
import '../menus/menus_page.dart';

class OrderFormPage extends StatefulWidget {
  const OrderFormPage({
    super.key,
    this.initialOrder,
  });

  final CoffeeOrder? initialOrder;

  @override
  State<OrderFormPage> createState() => _OrderFormPageState();
}

class _OrderFormPageState extends State<OrderFormPage> {
  final _price = TextEditingController();
  final _notes = TextEditingController();
  final _dose = TextEditingController();
  final _yield = TextEditingController();
  final _time = TextEditingController();
  final _grind = TextEditingController();
  final _temperature = TextEditingController();

  int? _menuId;
  int? _cafeId;
  int? _beanId;
  int _rating = 0;
  bool _showAdvanced = false;
  bool _initialized = false;

  bool get _isEditing => widget.initialOrder?.id != null;

  @override
  void initState() {
    super.initState();
    final order = widget.initialOrder;
    if (order != null) {
      _menuId = order.menuId;
      _cafeId = order.cafeId;
      _beanId = order.beanId;
      _price.text = _formatInputNumber(order.price);
      _notes.text = order.tastingNotes ?? '';
      _dose.text = _formatInputNumber(order.doseG);
      _yield.text = _formatInputNumber(order.yieldG);
      _time.text = order.extractionSec?.toString() ?? '';
      _grind.text = order.grindSetting ?? '';
      _temperature.text = _formatInputNumber(order.temperatureC);
      _rating = order.rating ?? 0;
      _showAdvanced = order.doseG != null ||
          order.yieldG != null ||
          order.extractionSec != null ||
          order.grindSetting != null ||
          order.temperatureC != null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final store = Get.find<ShotController>();
    _menuId ??= store.activeMenus.isNotEmpty ? store.activeMenus.first.id : null;
    _cafeId ??= store.activeCafes.isNotEmpty ? store.activeCafes.first.id : null;
    _initialized = true;
  }

  @override
  void dispose() {
    _price.dispose();
    _notes.dispose();
    _dose.dispose();
    _yield.dispose();
    _time.dispose();
    _grind.dispose();
    _temperature.dispose();
    super.dispose();
  }

  double? get _doseValue => _parseDouble(_dose.text);
  double? get _yieldValue => _parseDouble(_yield.text);

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final menus = store.activeMenus;
      final cafes = store.activeCafes;
      final beans = store.activeBeans;

      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Order' : 'New Order'),
          actions: [
            ShotIconAction(
              tooltip: 'Menus',
              icon: Icons.local_cafe_outlined,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const MenusPage()),
              ),
            ),
            ShotIconAction(
              tooltip: 'Cafes',
              icon: Icons.storefront_outlined,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const CafesPage()),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
          children: [
            const SectionLabel('Menu'),
            if (menus.isEmpty)
              EmptyState(
                icon: Icons.local_cafe_outlined,
                title: 'Belum ada menu',
                subtitle: 'Tambahkan menu sebelum membuat order.',
                ctaLabel: 'Add Menu',
                onCta: () => showMenuFormSheet(context),
              )
            else
              _OrderSelector<CoffeeMenu>(
                value: _menuId,
                items: menus,
                labelOf: (menu) => menu.name,
                valueOf: (menu) => menu.id!,
                onChanged: (id) => setState(() => _menuId = id),
              ),
            const SectionLabel('Cafe'),
            if (cafes.isEmpty)
              EmptyState(
                icon: Icons.storefront_outlined,
                title: 'Belum ada cafe',
                subtitle: 'Tambahkan cafe atau gunakan default Home.',
                ctaLabel: 'Add Cafe',
                onCta: () => showCafeFormSheet(context),
              )
            else
              _OrderSelector<Cafe>(
                value: _cafeId,
                items: cafes,
                labelOf: (cafe) => cafe.name,
                valueOf: (cafe) => cafe.id!,
                onChanged: (id) => setState(() => _cafeId = id),
              ),
            const SectionLabel('Bean Optional'),
            _OrderSelector<CoffeeBean>(
              value: _beanId,
              items: beans,
              labelOf: (bean) => bean.name,
              valueOf: (bean) => bean.id!,
              emptyLabel: 'Bean tidak diketahui',
              allowEmpty: true,
              onChanged: (id) => setState(() => _beanId = id),
            ),
            const SectionLabel('Photo'),
            ShotImagePlaceholder(
              label: 'Order photo',
              icon: Icons.photo_camera_outlined,
              height: 92,
              radius: 16,
            ),
            const SectionLabel('Price'),
            TextField(
              controller: _price,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              style: TextStyle(color: colors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Optional price',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
            ),
            const SectionLabel('Rating'),
            ShotCard(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                child: StarRatingInput(
                  rating: _rating,
                  onChanged: (value) => setState(() => _rating = value),
                ),
              ),
            ),
            const SectionLabel('Tasting Notes'),
            TextField(
              controller: _notes,
              maxLines: 4,
              style: TextStyle(color: colors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'mis. Creamy, nutty, aftertaste bersih...',
              ),
            ),
            const SizedBox(height: 14),
            FilterPill(
              label: 'Advanced brewing parameters',
              selected: _showAdvanced,
              icon: Icons.tune_rounded,
              onTap: () => setState(() => _showAdvanced = !_showAdvanced),
            ),
            if (_showAdvanced) ...[
              const SectionLabel('Advanced Brewing'),
              LabeledTextField(
                label: 'Dose in (g)',
                controller: _dose,
                hint: '18',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              LabeledTextField(
                label: 'Yield out (g)',
                controller: _yield,
                hint: '36',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              LabeledTextField(
                label: 'Extraction time',
                controller: _time,
                hint: '28 sec',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              LabeledTextField(
                label: 'Grind setting',
                controller: _grind,
                hint: '12 clicks',
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              LabeledTextField(
                label: 'Temperature',
                controller: _temperature,
                hint: '92 C',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              if (_doseValue != null &&
                  _yieldValue != null &&
                  _doseValue! > 0) ...[
                const SizedBox(height: 12),
                ShotCard(
                  surfaceAlt: true,
                  child: MiniStat(
                    label: 'Ratio',
                    value:
                        '1 : ${(_yieldValue! / _doseValue!).toStringAsFixed(2)}',
                  ),
                ),
              ],
            ],
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
            decoration: BoxDecoration(
              color: colors.background,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: PrimaryButton(
              label: _isEditing ? 'Simpan Perubahan' : 'Save Order',
              icon: Icons.check_rounded,
              onPressed:
                  menus.isEmpty || cafes.isEmpty ? null : () => _save(context),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _save(BuildContext context) async {
    if (_menuId == null || _cafeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Menu dan cafe wajib dipilih.')),
      );
      return;
    }

    final store = Get.find<ShotController>();
    final now = DateTime.now();
    final source = widget.initialOrder;
    final order = CoffeeOrder(
      id: source?.id,
      menuId: _menuId!,
      cafeId: _cafeId!,
      beanId: _beanId,
      imagePath: source?.imagePath,
      price: _parseDouble(_price.text),
      rating: _rating == 0 ? null : _rating,
      tastingNotes: _blankToNull(_notes.text),
      doseG: _showAdvanced ? _parseDouble(_dose.text) : null,
      yieldG: _showAdvanced ? _parseDouble(_yield.text) : null,
      extractionSec: _showAdvanced ? _parseInt(_time.text) : null,
      temperatureC: _showAdvanced ? _parseDouble(_temperature.text) : null,
      grindSetting: _showAdvanced ? _blankToNull(_grind.text) : null,
      isFavorite: source?.isFavorite ?? false,
      orderedAt: _isEditing ? source!.orderedAt : now,
      createdAt: _isEditing ? source!.createdAt : now,
      updatedAt: now,
    );

    if (_isEditing) {
      await store.saveOrder(order);
    } else {
      await store.addOrder(order);
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Order updated.' : 'Order saved.')),
    );
    Navigator.of(context).pop();
  }
}

class _OrderSelector<T> extends StatelessWidget {
  const _OrderSelector({
    required this.value,
    required this.items,
    required this.labelOf,
    required this.valueOf,
    required this.onChanged,
    this.emptyLabel,
    this.allowEmpty = false,
  });

  final int? value;
  final List<T> items;
  final String Function(T item) labelOf;
  final int Function(T item) valueOf;
  final ValueChanged<int?> onChanged;
  final String? emptyLabel;
  final bool allowEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = shotColors(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colors.textSecondary,
          ),
          dropdownColor: colors.surface,
          style: Theme.of(context).textTheme.titleSmall,
          items: [
            if (allowEmpty)
              DropdownMenuItem<int?>(
                value: null,
                child: Text(emptyLabel ?? '-'),
              ),
            for (final item in items)
              DropdownMenuItem<int?>(
                value: valueOf(item),
                child: Text(labelOf(item)),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

double? _parseDouble(String value) {
  final trimmed = value.trim().replaceAll(',', '.');
  if (trimmed.isEmpty) {
    return null;
  }
  return double.tryParse(trimmed);
}

int? _parseInt(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return int.tryParse(trimmed);
}

String? _blankToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _formatInputNumber(double? value) {
  if (value == null) {
    return '';
  }
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}
