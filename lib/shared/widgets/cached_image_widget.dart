import 'dart:io';

import 'package:flutter/material.dart';
import 'package:golden_moments/data/services/long_term_image_cache.dart';
import 'package:golden_moments/design_system.dart';

/// Widget that displays images with long-term caching
class CachedImageWidget extends StatefulWidget {
  const CachedImageWidget({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.showLoadingIndicator = true,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool showLoadingIndicator;

  @override
  State<CachedImageWidget> createState() => _CachedImageWidgetState();
}

class _CachedImageWidgetState extends State<CachedImageWidget> {
  final LongTermImageCache _cache = LongTermImageCache.instance;

  File? _cachedFile;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final cachedFile = await _cache.getCachedImage(widget.imageUrl);

      if (mounted) {
        setState(() {
          _cachedFile = cachedFile;
          _isLoading = false;
          _hasError = cachedFile == null;
          if (cachedFile == null) {
            _errorMessage = 'Failed to load image';
          }
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (_isLoading) {
      child = _buildLoadingWidget();
    } else if (_hasError || _cachedFile == null) {
      child = _buildErrorWidget();
    } else {
      child = _buildImageWidget();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(borderRadius: widget.borderRadius),
      clipBehavior: widget.borderRadius != null ? Clip.antiAlias : Clip.none,
      child: child,
    );
  }

  Widget _buildImageWidget() {
    return Image.file(
      _cachedFile!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget();
      },
    );
  }

  Widget _buildLoadingWidget() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      color: gmSurf200,
      child: widget.showLoadingIndicator
          ? Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height,
      // A missing picture is calm, not alarming: Oat well, Walnut outline
      // icon (DESIGN.md › Empty and error states).
      color: gmSurf200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 32,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: gmSpaceSm),
            Text(
              'Image failed to load',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Circular cached image widget for avatars and thumbnails
class CachedCircularImage extends StatelessWidget {
  const CachedCircularImage({
    required this.imageUrl,
    required this.radius,
    super.key,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedImageWidget(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}

/// Cached image with fade-in animation
class FadeInCachedImage extends StatefulWidget {
  const FadeInCachedImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.duration = const Duration(milliseconds: 300),
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Duration duration;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  @override
  State<FadeInCachedImage> createState() => _FadeInCachedImageState();
}

class _FadeInCachedImageState extends State<FadeInCachedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CachedImageWidget(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      borderRadius: widget.borderRadius,
      placeholder: widget.placeholder,
      errorWidget: widget.errorWidget,
      showLoadingIndicator: false,
    );
  }
}

/// Cached image grid for displaying multiple images
class CachedImageGrid extends StatelessWidget {
  const CachedImageGrid({
    required this.imageUrls,
    super.key,
    this.crossAxisCount = 2,
    this.aspectRatio = 1.0,
    this.spacing = gmSpaceSm,
    this.onImageTap,
  });

  final List<String> imageUrls;
  final int crossAxisCount;
  final double aspectRatio;
  final double spacing;
  final void Function(String imageUrl, int index)? onImageTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        final imageUrl = imageUrls[index];
        return GestureDetector(
          onTap: onImageTap != null ? () => onImageTap!(imageUrl, index) : null,
          child: CachedImageWidget(
            imageUrl: imageUrl,
            borderRadius: BorderRadius.circular(gmRadiusLg),
          ),
        );
      },
    );
  }
}

/// Cached image carousel for preview images
class CachedImageCarousel extends StatelessWidget {
  const CachedImageCarousel({
    required this.imageUrls,
    super.key,
    this.height = 200,
    this.onImageTap,
  });

  final List<String> imageUrls;
  final double height;
  final void Function(String imageUrl, int index)? onImageTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];
          return Container(
            width: height, // Square aspect ratio
            margin: const EdgeInsets.only(right: gmSpaceSm),
            child: GestureDetector(
              onTap: onImageTap != null
                  ? () => onImageTap!(imageUrl, index)
                  : null,
              child: CachedImageWidget(
                imageUrl: imageUrl,
                borderRadius: BorderRadius.circular(gmRadiusLg),
              ),
            ),
          );
        },
      ),
    );
  }
}
