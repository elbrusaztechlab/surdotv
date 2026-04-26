import 'package:flutter/material.dart';
import 'package:surdotv_app/core/theme/app_theme.dart';
import 'package:versionarte/versionarte.dart';

class AppUpdateBlockingScreen extends StatelessWidget {
  const AppUpdateBlockingScreen({
    super.key,
    required this.result,
  });

  final VersionarteResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messageAz = result.getMessageForLanguage('az');
    final messageEn = result.getMessageForLanguage('en');
    final message = (messageAz != null && messageAz.trim().isNotEmpty)
        ? messageAz
        : (messageEn?.trim().isNotEmpty ?? false)
            ? messageEn!
            : 'Yeni versiya movcuddur. Davam etmek ucun tetbiqi yenileyin.';
    final downloadUrls = result.downloadUrls;

    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.08),
                      blurRadius: 32,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(203, 33, 41, 0.12),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.system_update_alt,
                          color: AppTheme.primaryColor,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Yeniləmə tələb olunur',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1C1B1F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF49454F),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: downloadUrls == null
                              ? null
                              : () {
                                  Versionarte.launchDownloadUrl(downloadUrls);
                                },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('Yenilə'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
