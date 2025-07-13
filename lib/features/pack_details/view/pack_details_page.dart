// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:golden_moments/data/models/packs_index.dart';
// import 'package:golden_moments/design_system.dart';
// import 'package:golden_moments/features/pack_details/cubit/pack_details_cubit.dart';
// import 'package:golden_moments/game/view/game_page.dart';
// import 'package:golden_moments/shared/widgets/cached_image_widget.dart';
// import 'package:golden_moments/shared/widgets/download_progress_card.dart';
// import 'package:golden_moments/shared/widgets/offline_indicator.dart';

// /// Pack details page showing comprehensive pack information
// class PackDetailsPage extends StatelessWidget {
//   const PackDetailsPage({
//     super.key,
//     required this.packInfo,
//   });

//   final GitHubPackInfo packInfo;

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => PackDetailsCubit(packInfo)..initialize(),
//       child: PackDetailsView(packInfo: packInfo),
//     );
//   }
// }

// /// Pack details view widget
// class PackDetailsView extends StatelessWidget {
//   const PackDetailsView({
//     super.key,
//     required this.packInfo,
//   });

//   final GitHubPackInfo packInfo;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<PackDetailsCubit, PackDetailsState>(
//         builder: (context, state) {
//           return CustomScrollView(
//             slivers: [
//               // App bar with pack image
//               _buildSliverAppBar(context, state),
              
//               // Pack information content
//               SliverToBoxAdapter(
//                 child: _buildPackContent(context, state),
//               ),
//             ],
//           );
//         },
//       ),
//       bottomNavigationBar: _buildBottomActions(context),
//     );
//   }

//   Widget _buildSliverAppBar(BuildContext context, PackDetailsState state) {
//     final theme = Theme.of(context);
    
//     return SliverAppBar(
//       expandedHeight: 250,
//       pinned: true,
//       flexibleSpace: FlexibleSpaceBar(
//         title: Text(
//           packInfo.title,
//           style: theme.textTheme.titleLarge?.copyWith(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             shadows: [
//               Shadow(
//                 color: Colors.black.withValues(alpha: 0.7),
//                 blurRadius: 4,
//               ),
//             ],
//           ),
//         ),
//         background: Stack(
//           fit: StackFit.expand,
//           children: [
//             // Pack thumbnail or placeholder
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     theme.colorScheme.primaryContainer,
//                     theme.colorScheme.primary,
//                   ],
//                 ),
//               ),
//               child: packInfo.thumbnailUrl != null
//                   ? Image.network(
//                       packInfo.thumbnailUrl!,
//                       fit: BoxFit.cover,
//                       errorBuilder: (context, error, stackTrace) {
//                         return _buildPlaceholderImage(theme);
//                       },
//                     )
//                   : _buildPlaceholderImage(theme),
//             ),
            
//             // Gradient overlay
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.transparent,
//                     Colors.black.withValues(alpha: 0.7),
//                   ],
//                 ),
//               ),
//             ),
            
//             // Status badges
//             Positioned(
//               top: 60,
//               right: 16,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   if (packInfo.isPremium)
//                     _buildStatusBadge('PREMIUM', gmGold600),
//                   if (packInfo.isNew)
//                     _buildStatusBadge('NEW', gmGreen600),
//                   _buildStatusBadge(
//                     state.downloadStatus == PackDownloadStatus.cached
//                         ? 'CACHED'
//                         : 'AVAILABLE',
//                     state.downloadStatus == PackDownloadStatus.cached
//                         ? gmGreen600
//                         : gmGold600,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPlaceholderImage(ThemeData theme) {
//     return Center(
//       child: Icon(
//         Icons.photo_library,
//         size: 80,
//         color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String text, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: gmSpaceSm),
//       padding: const EdgeInsets.symmetric(
//         horizontal: gmSpaceSm,
//         vertical: 4,
//       ),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         text,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildPackContent(BuildContext context, PackDetailsState state) {
//     return Padding(
//       padding: const EdgeInsets.all(gmSpaceMd),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Offline indicator
//           const OfflineIndicator(compact: true),
//           const SizedBox(height: gmSpaceMd),
          
//           // Pack description
//           _buildPackDescription(context),
//           const SizedBox(height: gmSpaceLg),
          
//           // Pack statistics
//           _buildPackStatistics(context),
//           const SizedBox(height: gmSpaceLg),
          
//           // Cache status info
//           if (state.isDownloading) ...[
//             _buildCacheStatusInfo(context, state),
//             const SizedBox(height: gmSpaceLg),
//           ],
          
//           // Pack details
//           _buildPackDetails(context),
//           const SizedBox(height: gmSpaceLg),
          
//           // Preview images
//           _buildPreviewImages(context, state),
//           const SizedBox(height: gmSpaceLg),
          
//           // Tags
//           _buildTags(context),
          
//           // Bottom padding for floating action button
//           const SizedBox(height: 100),
//         ],
//       ),
//     );
//   }

//   Widget _buildPackDescription(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Description',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: gmSpaceSm),
//         Text(
//           packInfo.description ?? 'No description available.',
//           style: theme.textTheme.bodyMedium?.copyWith(
//             height: 1.5,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPackStatistics(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Container(
//       padding: const EdgeInsets.all(gmSpaceMd),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
//         borderRadius: BorderRadius.circular(gmRadiusMd),
//       ),
//       child: Row(
//         children: [
//           _buildStatItem(
//             context,
//             Icons.photo,
//             '${packInfo.imageCount}',
//             'Images',
//           ),
//           const SizedBox(width: gmSpaceLg),
//           _buildStatItem(
//             context,
//             Icons.storage,
//             packInfo.formattedSize,
//             'Size',
//           ),
//           const SizedBox(width: gmSpaceLg),
//           _buildStatItem(
//             context,
//             Icons.star,
//             packInfo.rating.toStringAsFixed(1),
//             'Rating',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(
//     BuildContext context,
//     IconData icon,
//     String value,
//     String label,
//   ) {
//     final theme = Theme.of(context);
    
//     return Expanded(
//       child: Column(
//         children: [
//           Icon(
//             icon,
//             size: 24,
//             color: theme.colorScheme.primary,
//           ),
//           const SizedBox(height: gmSpaceSm),
//           Text(
//             value,
//             style: theme.textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.bold,
//               color: theme.colorScheme.primary,
//             ),
//           ),
//           Text(
//             label,
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCacheStatusInfo(BuildContext context, PackDetailsState state) {
//     final theme = Theme.of(context);

//     return Container(
//       padding: const EdgeInsets.all(gmSpaceMd),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
//         borderRadius: BorderRadius.circular(gmRadiusMd),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.download,
//             color: theme.colorScheme.primary,
//           ),
//           const SizedBox(width: gmSpaceMd),
//           Expanded(
//             child: Text(
//               'Caching images for offline play...',
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.primary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPackDetails(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Details',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: gmSpaceSm),
//         _buildDetailRow('Theme', packInfo.theme),
//         _buildDetailRow('Category', packInfo.category),
//         _buildDetailRow('Difficulty', packInfo.difficultyDisplayName),
//         _buildDetailRow('Version', packInfo.version),
//         _buildDetailRow('Updated', _formatDate(packInfo.updatedAt)),
//         if (packInfo.isPremium)
//           _buildDetailRow('Type', 'Premium'),
//       ],
//     );
//   }

//   Widget _buildDetailRow(String label, String value) {
//     return Builder(
//       builder: (context) {
//         final theme = Theme.of(context);

//         return Padding(
//           padding: const EdgeInsets.only(bottom: gmSpaceSm),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 80,
//                 child: Text(
//                   label,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: Text(
//                   value,
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPreviewImages(BuildContext context, PackDetailsState state) {
//     final theme = Theme.of(context);
    
//     if (packInfo.previewImages.isEmpty) {
//       return const SizedBox.shrink();
//     }
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Preview Images',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: gmSpaceSm),
//         SizedBox(
//           height: 100,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: packInfo.previewImages.length,
//             itemBuilder: (context, index) {
//               final imageUrl = packInfo.previewImages[index];
//               return Container(
//                 width: 100,
//                 margin: const EdgeInsets.only(right: gmSpaceSm),
//                 decoration: BoxDecoration(
//                   color: theme.colorScheme.primaryContainer,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Icon(
//                         Icons.image,
//                         color: theme.colorScheme.onPrimaryContainer,
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTags(BuildContext context) {
//     final theme = Theme.of(context);
    
//     if (packInfo.tags.isEmpty) {
//       return const SizedBox.shrink();
//     }
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Tags',
//           style: theme.textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: gmSpaceSm),
//         Wrap(
//           spacing: gmSpaceSm,
//           runSpacing: gmSpaceSm,
//           children: packInfo.tags.map((tag) {
//             return Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: gmSpaceSm,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color: theme.colorScheme.primaryContainer
//                     .withValues(alpha: 0.5),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 tag,
//                 style: theme.textTheme.bodySmall?.copyWith(
//                   color: theme.colorScheme.onPrimaryContainer,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomActions(BuildContext context) {
//     return BlocBuilder<PackDetailsCubit, PackDetailsState>(
//       builder: (context, state) {
//         return Container(
//           padding: const EdgeInsets.all(gmSpaceMd),
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surface,
//             boxShadow: [
//               BoxShadow(
//                 color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
//                 blurRadius: 8,
//                 offset: const Offset(0, -2),
//               ),
//             ],
//           ),
//           child: SafeArea(
//             child: Row(
//               children: [
//                 if (state.canPlay) ...[
//                   Expanded(
//                     child: GmPrimaryButton(
//                       label: 'Play Now',
//                       onTap: () {
//                         _navigateToGame(context, state);
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: gmSpaceMd),
//                 ],
//                 Expanded(
//                   child: _buildDownloadButton(context, state),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDownloadButton(BuildContext context, PackDetailsState state) {
//     switch (state.downloadStatus) {
//       case PackDownloadStatus.available:
//         return GmOutlineButton(
//           label: 'Download',
//           onTap: () {
//             context.read<PackDetailsCubit>().startDownload();
//           },
//         );
//       case PackDownloadStatus.downloading:
//         return const GmOutlineButton(
//           label: 'Caching...',
//         );
//       case PackDownloadStatus.cached:
//         return const GmOutlineButton(
//           label: 'Cached',
//         );
//       case PackDownloadStatus.expired:
//         return GmOutlineButton(
//           label: 'Update',
//           onTap: () {
//             context.read<PackDetailsCubit>().startDownload();
//           },
//         );
//       case PackDownloadStatus.failed:
//         return GmOutlineButton(
//           label: 'Retry Download',
//           onTap: () {
//             context.read<PackDetailsCubit>().startDownload();
//           },
//         );
//     }
//   }

//   void _navigateToGame(BuildContext context, PackDetailsState state) {
//     if (state.gamePack != null) {
//       Navigator.of(context).push(
//         MaterialPageRoute<void>(
//           builder: (context) => GamePage(gamePack: state.gamePack!),
//         ),
//       );
//     }
//   }

//   String _formatDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays < 1) {
//       return 'Today';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays} days ago';
//     } else if (difference.inDays < 30) {
//       return '${(difference.inDays / 7).round()} weeks ago';
//     } else {
//       return '${date.day}/${date.month}/${date.year}';
//     }
//   }
// }
