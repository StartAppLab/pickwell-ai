import 'package:flutter/material.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../domain/entities/app_release.dart';

class SettingsChangelogView extends StatelessWidget {
  const SettingsChangelogView({super.key, this.releases = AppRelease.releases});
  final List<AppRelease> releases;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: const Text('Changelog')),
      body: SafeArea(
        child: releases.isEmpty
            ? const Center(child: Text('No release notes yet'))
            : ListView.separated(
                padding: context.themeData.edgeInsetsData.pagePadding,
                itemCount: releases.length,
                separatorBuilder: (_, index) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final release = releases[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('v${release.version}', style: context.textTheme.titleLarge),
                      Text(release.title, style: context.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      for (final note in release.notes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  '),
                              Expanded(child: Text(note)),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
