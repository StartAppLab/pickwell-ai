import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/_core.dart';
import '../../../app/app.dart';
import '../../../../config/_config.dart';
import '../../../auth/presentation/services/auth_actions.dart';
import '../blocs/_blocs.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key, required this.supabaseClient});

  final SupabaseClient supabaseClient;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late SupabaseClient _supabaseClient;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  final _firstNameFocusNode = FocusNode();
  final _lastNameFocusNode = FocusNode();

  String? _profilePictureUrl;
  String? _lastName;

  @override
  void initState() {
    super.initState();

    _supabaseClient = widget.supabaseClient;
    final user = _supabaseClient.auth.currentUser;
    _profilePictureUrl = user?.userMetadata?['avatar_url'];
    context.read<ProfileCubit>().setFirstName(user?.userMetadata?['first_name']);
    _lastName = user?.userMetadata?['last_name'];

    _firstNameController.text = user?.userMetadata?['first_name'] ?? '';
    _lastNameController.text = _lastName ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();

    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MaterialAppBar(title: Text(context.l10n.profile)),
      body: SafeArea(
        child: BlocListener<ProfileCubit, ProfileState>(
          listener: (context, state) {
            state.whenOrNull(
              success: (_) {},
              error: (error, _) {
                var message = 'Error Message';
                if (error.message?.isNotEmpty ?? false) {
                  message = error.message!;
                }
                AppWidgets.showErrorSnackBar(context, message);
              },
            );
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: context.themeData.edgeInsetsData.pagePadding,
                  child: Column(
                    children: [
                      // Profile Picture
                      BlocSelector<ProfileCubit, ProfileState, String?>(
                        selector: (state) => state.maybeWhen(
                          idle: (_, firstName) => firstName,
                          loading: (firstName) => firstName,
                          success: (firstName) => firstName,
                          error: (_, firstName) => firstName,
                          orElse: () => null,
                        ),
                        builder: (context, firstName) {
                          if (_profilePictureUrl != null) {
                            return CircleAvatar(
                              foregroundImage: CachedNetworkImageProvider(_profilePictureUrl!),
                              radius: 50,
                            );
                          }
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: context.colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                (firstName?.isNotEmpty ?? false)
                                    ? firstName![0]
                                    : getIt<AppConfig>().appName[0],
                                style: context.textTheme.displayMedium,
                              ),
                            ),
                          );
                        },
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // First Name Text Field
                      DataTextField(
                        controller: _firstNameController,
                        focusNode: _firstNameFocusNode,
                        hintText: context.l10n.firstName,
                        keyboardType: TextInputType.name,
                      ),
                      Gap(context.themeData.dimensionsData.smallSpacing),
                      // Last Name Text Field
                      DataTextField(
                        controller: _lastNameController,
                        focusNode: _lastNameFocusNode,
                        hintText: '${context.l10n.lastName} ${context.l10n.optional}',
                        keyboardType: TextInputType.name,
                      ),
                      Gap(context.themeData.dimensionsData.mediumSpacing),
                      // Save Profile Button
                      BlocListener<ProfileCubit, ProfileState>(
                        listener: (context, state) {
                          state.whenOrNull(
                            success: (_) {
                              AppWidgets.showSuccessSnackBar(
                                context,
                                'Profile updated successfully',
                              );
                            },
                            error: (error, _) {
                              AppWidgets.showErrorSnackBar(
                                context,
                                error.message ?? 'Failed to update profile',
                              );
                            },
                          );
                        },
                        child: BlocSelector<ProfileCubit, ProfileState, bool>(
                          selector: (state) =>
                              state.maybeWhen(loading: (_) => true, orElse: () => false),
                          builder: (context, loading) => ElevatedButton(
                            onPressed: loading ? null : () => _updateProfile(context),
                            child: loading
                                ? AppWidgets.loadingIndicator(context)
                                : const Text('Save Profile'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BlocSelector<ProfileCubit, ProfileState, bool>(
                selector: (state) => state.maybeWhen(loading: (_) => true, orElse: () => false),
                builder: (context, loading) => loading
                    ? Center(child: AppWidgets.loadingIndicator(context))
                    : const SizedBox.shrink(),
              ),
              BlocSelector<ProfileCubit, ProfileState, bool>(
                selector: (state) => state.maybeWhen(loading: (_) => true, orElse: () => false),
                builder: (context, loading) => SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: AbsorbPointer(absorbing: loading),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProfile(BuildContext context) async {
    final first = _firstNameController.text.trim();
    if (first.isEmpty) {
      AppWidgets.showErrorSnackBar(context, 'Enter your name.');
      return;
    }
    try {
      await AppWidgets.loadingDialog(
        context,
        loadingText: 'Updating profile...',
        onLoading: () async {
          await getIt<AuthActions>().updateProfile(
            firstName: first,
            lastName: _lastNameController.text,
          );
        },
      );
      if (!context.mounted) return;
      context.read<ProfileCubit>().setFirstName(first);
      AppWidgets.showSuccessSnackBar(context, 'Profile updated.');
    } catch (_) {
      if (context.mounted) {
        AppWidgets.showErrorSnackBar(context, 'Unable to update profile. Please try again.');
      }
    }
  }
}
