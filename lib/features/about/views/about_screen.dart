import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:surdotv_app/features/about/viewmodels/about_viewmodel.dart';
import 'package:surdotv_app/widgets/common_widgets.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AboutViewModel>();
      if (vm.viewState.valueOrNull == null && !vm.viewState.isLoading) {
        vm.fetchAbout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aboutVm = context.watch<AboutViewModel>();

    return Scaffold(
      appBar: const SurdoLogoAppBar(),
      body: aboutVm.viewState.when(
        loading: () => const LoadingView(),
        error: (message) => ErrorStateView(
          message: message,
          onRetry: aboutVm.fetchAbout,
        ),
        success: (text) => RefreshIndicator(
          onRefresh: aboutVm.fetchAbout,
          child: ListView(
            children: [
              _AboutContent(text: text),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final splitIndex = text.indexOf('Müxtəlif');
    final firstPart =
        splitIndex > 0 ? text.substring(0, splitIndex).trim() : text;
    final secondPart = splitIndex > 0 ? text.substring(splitIndex).trim() : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              firstPart,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ),
          const SponsorStrip(),
          if (secondPart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                secondPart,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.justify,
              ),
            ),
        ],
      ),
    );
  }
}
