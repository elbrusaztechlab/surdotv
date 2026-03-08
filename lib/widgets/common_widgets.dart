import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:surdotv_app/core/constants/layout_constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 28,
    this.color,
  });

  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
      height: height,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

class AppTopHeader extends StatelessWidget {
  const AppTopHeader({
    super.key,
    this.title,
    this.trailing,
  });

  final String? title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          const AppLogo(height: 26),
          if (title != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title!,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ] else
            const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class SurdoLogoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SurdoLogoAppBar({
    super.key,
    this.backgroundColor,
    this.leading,
    this.actions,
  });

  final Color? backgroundColor;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      iconTheme: IconThemeData(
        color: backgroundColor == null
            ? Theme.of(context).colorScheme.primary
            : Colors.white,
      ),
      leading: leading,
      title: AppLogo(
        height: 24,
        color: backgroundColor == null ? null : Colors.white,
      ),
      actions: actions,
    );
  }
}

class SponsorStrip extends StatelessWidget {
  const SponsorStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _assetSvg('assets/images/emek_naz.svg', height: 60),
          Image.asset(
            'assets/images/logo_fond.png',
            height: 60,
            fit: BoxFit.contain,
          ),
          _assetSvg('assets/images/sos_agent.svg', height: 60),
        ],
      ),
    );
  }

  Widget _assetSvg(String path, {required double height}) {
    return SvgPicture.asset(path, height: height, fit: BoxFit.contain);
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onActionTap,
    this.actionLabel = 'Hamısına bax',
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onActionTap;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
              ],
            ),
          ),
          if (onActionTap != null)
            TextButton(
              onPressed: onActionTap,
              child: Text(actionLabel),
            ),
        ],
      ),
    );
  }
}

class OutlinePillButton extends StatefulWidget {
  const OutlinePillButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback onPressed;

  @override
  State<OutlinePillButton> createState() => _OutlinePillButtonState();
}

class _OutlinePillButtonState extends State<OutlinePillButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () async {
        setState(() {
          _isPressed = true;
        });
        await Future<void>.delayed(const Duration(milliseconds: 150));
        widget.onPressed();
        if (!mounted) return;
        setState(() {
          _isPressed = false;
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        side: BorderSide(
          width: 1,
          color: Theme.of(context).colorScheme.primary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        foregroundColor: _isPressed ? Colors.white : Colors.black,
        backgroundColor: _isPressed
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
      ),
      child: Text(widget.text),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Yenilə'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.borderRadius = LayoutConstants.cardRadius,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final double borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        child: const Center(
          child: Icon(Icons.image_outlined, size: 42),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (_, __) => Container(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          child:
              const Center(child: Icon(Icons.broken_image_outlined, size: 42)),
        ),
      ),
    );
  }
}
