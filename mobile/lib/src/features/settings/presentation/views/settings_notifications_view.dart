import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';

/// Local reminder preferences. Remote push is a separate optional integration.
class SettingsNotificationsView extends StatelessWidget {
  const SettingsNotificationsView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MaterialAppBar(title: Text(context.l10n.notifications)),
    body: SafeArea(
      child: BlocListener<SettingsNotificationsCubit, SettingsNotificationsState>(
        listener: (context, state) {
          state.whenOrNull(
            permissionDenied: (_) => AppWidgets.showInfoSnackBar(
              context,
              'Notifications are disabled in your system settings.',
            ),
            error: (_, message) => AppWidgets.showErrorSnackBar(context, message),
          );
        },
        child: BlocSelector<SettingsNotificationsCubit, SettingsNotificationsState, (bool?, bool)>(
          selector: (state) => state.maybeWhen(
            idle: (enabled) => (enabled, false),
            loading: () => (null, true),
            saving: (enabled) => (enabled, true),
            permissionDenied: (enabled) => (enabled, false),
            success: (enabled) => (enabled, false),
            error: (enabled, _) => (enabled, false),
            orElse: () => (null, true),
          ),
          builder: (context, selection) => selection.$1 == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    SwitchListTile.adaptive(
                      title: const Text('Local reminders'),
                      subtitle: const Text(
                        'Allow scheduled reminders on this device. Your system notification settings also apply.',
                      ),
                      value: selection.$1!,
                      onChanged: selection.$2 ? null : (value) => _toggle(context, value),
                    ),
                    if (selection.$2) const Center(child: CircularProgressIndicator()),
                  ],
                ),
        ),
      ),
    ),
  );

  Future<void> _toggle(BuildContext context, bool value) async {
    await context.read<SettingsNotificationsCubit>().toggle(value);
  }
}
