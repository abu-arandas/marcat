// lib/presentation/shared/widgets/marcat_image_viewer.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import 'marcat_app_bar.dart';

class MarcatImageViewer extends StatelessWidget {
  const MarcatImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  final List<String> imageUrls;
  final int initialIndex;

  static Future<void> show(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MarcatImageViewer(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.marcatBlack,
      appBar: const MarcatAppBar(
        title: '',
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: CachedNetworkImageProvider(imageUrls[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
          );
        },
        itemCount: imageUrls.length,
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(color: AppColors.marcatGold),
        ),
        backgroundDecoration: const BoxDecoration(
          color: AppColors.marcatBlack,
        ),
        pageController: PageController(initialPage: initialIndex),
      ),
      bottomNavigationBar: imageUrls.length > 1
          ? Container(
              color: AppColors.marcatBlack,
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    imageUrls.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space4),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.marcatGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
