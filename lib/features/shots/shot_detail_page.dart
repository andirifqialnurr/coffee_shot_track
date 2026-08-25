import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/shot_store.dart';
import '../../shared/widgets/shot_ui.dart';
import 'shot_form_page.dart';

class ShotDetailPage extends StatelessWidget {
  const ShotDetailPage({super.key, required this.shotId});

  final int shotId;

  @override
  Widget build(BuildContext context) {
    final store = Get.find<ShotController>();

    return Obx(() {
      final colors = shotColors(context);
      final shot = store.shots.where((item) => item.id == shotId).firstOrNull;
      if (shot == null) {
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(title: const Text('Shot')),
          body: const EmptyState(
            icon: Icons.delete_outline_rounded,
            title: 'Shot sudah dihapus',
            subtitle: 'Data shot ini tidak lagi tersedia.',
          ),
        );
      }
      final bean = store.beanById(shot.beanId);

      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: const Text('Shot Detail'),
          actions: [
            ShotIconAction(
              tooltip: shot.isFavorite ? 'Remove Favorite' : 'Set Favorite',
              onPressed: () => store.toggleFavorite(shot),
              icon: shot.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              selected: shot.isFavorite,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
          children: [
            Text(
              formatDateTime(shot.brewedAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            RecipeCard(shot: shot, beanName: bean?.name),
            const SectionLabel('Rating & Notes'),
            ShotCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shot.rating != null)
                    StarRating(rating: shot.rating!, size: 22)
                  else
                    Text(
                      'Belum diberi rating',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if ((shot.tastingNotes ?? '').isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      shot.tastingNotes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
            decoration: BoxDecoration(
              color: colors.background,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PrimaryButton(
                  label: 'Brew Again',
                  icon: Icons.replay_rounded,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ShotFormPage(
                        initialShot: shot.duplicateForBrewAgain(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Edit',
                        icon: Icons.edit_outlined,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ShotFormPage(initialShot: shot),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        danger: true,
                        onPressed: () => _confirmDelete(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final store = Get.find<ShotController>();
    final colors = shotColors(context);
    final shot = store.shots.where((item) => item.id == shotId).firstOrNull;
    if (shot == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus shot ini?'),
        content: const Text(
          'Tindakan ini tidak dapat dibatalkan. Data shot akan hilang permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Hapus', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await store.deleteShot(shot);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
