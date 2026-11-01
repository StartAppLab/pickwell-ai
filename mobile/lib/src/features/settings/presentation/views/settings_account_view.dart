import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/_config.dart';
import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../blocs/_blocs.dart';

class SettingsAccountView extends StatelessWidget {
  const SettingsAccountView({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: MaterialAppBar(title: Text(context.l10n.account)),
    body: SafeArea(
      child: BlocListener<SettingsAccountCubit, SettingsAccountState>(
        listener: (context, state) {
          state.whenOrNull(
            success: (message) => AppWidgets.showSuccessSnackBar(context, message),
            error: (message) => AppWidgets.showErrorSnackBar(context, message),
          );
        },
        child: BlocSelector<SettingsAccountCubit, SettingsAccountState, bool>(
          selector: (state) => state is SettingsAccountStateLoading,
          builder: (context, busy) => AbsorbPointer(
            absorbing: busy,
            child: ListView(
              children: [
                ListTile(title: Text(context.l10n.changeEmail), onTap: () => _changeEmail(context)),
                ListTile(
                  title: Text(context.l10n.changePassword),
                  onTap: () => context.pushNamed(AppRouter.changePasswordRoute),
                ),
                ListTile(
                  title: Text(context.l10n.deleteAccount),
                  textColor: context.colorScheme.error,
                  onTap: () => _deleteAccount(context),
                ),
                if (busy) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _changeEmail(BuildContext context) async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.changeEmail),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(labelText: 'New email'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (StringValidator().forEmail.test(controller.text.trim()).valid) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    // The dialog's exit animation can still access its controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (email == null || !context.mounted) return;
    await context.read<SettingsAccountCubit>().changeEmail(email);
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteAccount),
        content: const Text(
          'Your account and its data will be permanently deleted. '
          'Deleting your account does not cancel an App Store or Google Play subscription. '
          'Manage your subscription in the store before deleting your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await context.read<SettingsAccountCubit>().deleteAccount();
  }
}
