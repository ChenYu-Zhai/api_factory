import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../domain/entities/asset.dart';
import '../providers/dependency_injection.dart';

final assetLineageProvider = FutureProvider.family<List<Asset>, String>((ref, assetId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetLineage(assetId);
});

class AssetDetailsPage extends ConsumerWidget {
  final Asset asset;

  const AssetDetailsPage({super.key, required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineageAsync = ref.watch(assetLineageProvider(asset.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Asset Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Preview
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: AppColors.surfaceVariant,
                child: Center(child: Text('Preview: ${asset.filePath}', style: const TextStyle(color: AppColors.textSecondary))),
              ),
            ),
            const SizedBox(height: 16),

            // Metadata
            Text('Type: ${asset.type.toString().split('.').last}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary)),
            Text('Created: ${asset.createdAt}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            if (asset.isMasterReference)
              const Chip(label: Text('Master Reference', style: TextStyle(color: AppColors.textPrimary)), backgroundColor: AppColors.primary),
            const SizedBox(height: 24),

            // Lineage Section
            Text('Lineage', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            lineageAsync.when(
              data: (lineage) {
                if (lineage.isEmpty) return const Text('No lineage info available.', style: TextStyle(color: AppColors.textSecondary));
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lineage.length,
                  itemBuilder: (context, index) {
                    final item = lineage[index];
                    return ListTile(
                      leading: const Icon(Icons.image, color: AppColors.textSecondary),
                      title: Text(item.id == asset.id ? 'Current Asset' : 'Parent Asset', style: const TextStyle(color: AppColors.textPrimary)),
                      subtitle: Text(item.type.toString().split('.').last, style: const TextStyle(color: AppColors.textSecondary)),
                      onTap: () {
                        // Navigate to parent if needed
                      },
                    );
                  },
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (err, stack) => Text('Error loading lineage: $err', style: const TextStyle(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}
